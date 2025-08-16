import Blackbird
import SwiftUI
import os

private let logger = Logger(subsystem: "OMGScene", category: "scene-events")

public struct OMGScene: View {
    
    @AppStorage("lol.auth")         var authKey: String = ""
    @AppStorage("lol.terms")        var acceptedTerms: TimeInterval = 0
    @AppStorage("lol.onboarding")   var showOnboarding: Bool = false
    
    @Environment(\.webAuthenticationSession) var webAuthSession
    
    @Environment(\.profileCache)var cache
    @Environment(\.privateCache)var privateCache
    
    @StateObject var globalDirectoryFetcher: GlobalAddressDirectoryFetcher
    @StateObject var globalGardenFetcher: GlobalNowGardenFetcher
    @StateObject var globalStatusFetcher: GlobalStatusLogFetcher
    
    @StateObject var appSupportFetcher: AppSupportFetcher
    @StateObject var appLatestFetcher: AppLatestFetcher
    
    @StateObject var appBlockedFetcher: AddressBlockListDataFetcher
    @StateObject var localBlockedFetcher: LocalBlockListDataFetcher
    @StateObject var pinnedFetcher: PinnedListDataFetcher
    
    @StateObject var addressFetcher: AccountAddressDataFetcher
    
    @StateObject var addressFollowingFetcher: AddressFollowingDataFetcher
    @StateObject var addressFollowersFetcher: AddressFollowersDataFetcher
    @StateObject var addressBlockedFetcher: AddressBlockListDataFetcher
    
    @StateObject var directoryFetcher: AddressDirectoryDataFetcher
    @StateObject var gardenFetcher: NowGardenDataFetcher
    @StateObject var statusFetcher: StatusLogDataFetcher
    
    @SceneStorage("lol.address") var actingAddress: AddressName = ""
    
    @State var confirmLogout = false
    @State var destinationConstructor: DestinationConstructor = .init(addressBook: .init())
    
    let dataInterface: DataInterface
    var addressBook: AddressBook { destinationConstructor.addressBook }
    
    var accountFetcher: AccountAuthDataFetcher {
        return .init(
            session: webAuthSession,
            client: AppClient.info,
            interface: dataInterface,
            authenticate: {
                Task { @MainActor [cred = $0] in
                    authenticate(cred)
                }
            }
        )
    }
    
    var sceneModel: SceneModel? {
        guard !showOnboarding else {
            return nil
        }
        return .init(
            addressBook: addressBook,
            interface: AppClient.interface,
            database: AppClient.database
        )
    }
    
    init(_ interface: DataInterface) {
        dataInterface = interface
        
        _appSupportFetcher = .init(wrappedValue: .init())
        _appLatestFetcher = .init(wrappedValue: .init(addressName: "app"))
        
        _addressFetcher = .init(wrappedValue: .init(credential: ""))
        
        _pinnedFetcher = .init(wrappedValue: .init())
        
        _globalDirectoryFetcher = .init(wrappedValue: .init())
        _globalGardenFetcher = .init(wrappedValue: .init())
        _globalStatusFetcher = .init(wrappedValue: .init())
        
        _addressFollowingFetcher = .init(wrappedValue: .init(address: "", credential: ""))
        _addressFollowersFetcher = .init(wrappedValue: .init(address: "", credential: ""))
        _addressBlockedFetcher = .init(wrappedValue: .init(address: "", credential: ""))
        
        _statusFetcher = .init(wrappedValue: .init(addressBook: .init()))
        _gardenFetcher = .init(wrappedValue: .init(addressBook: .init()))
        
        _appBlockedFetcher = .init(wrappedValue: .init(address: "app", credential: ""))
        
        _localBlockedFetcher = .init(wrappedValue: .init())
        
        _directoryFetcher = .init(wrappedValue: .init(addressBook: .init()))
        
        #if canImport(UIKit)
        UITabBar.appearance().unselectedItemTintColor = UIColor.white
        #endif
    }
    
    public var body: some View {
        appState
            .environment(accountFetcher)
            .environment(\.globalDirectoryFetcher, globalDirectoryFetcher)
            .environment(\.globalGardenFetcher, globalGardenFetcher)
            .environment(\.globalStatusLogFetcher, globalStatusFetcher)
        
            .environment(\.appLatestFetcher, appLatestFetcher)
            .environment(\.appSupportFetcher, appSupportFetcher)
            .environment(\.globalBlocklist, appBlockedFetcher)
            .environment(\.localBlocklist, localBlockedFetcher)
        
            .environment(\.addressFetcher, addressFetcher)
            .environment(\.addressDirectoryFetcher, directoryFetcher)
            .environment(\.nowGardenFetcher, gardenFetcher)
            .environment(\.statusLogFetcher, statusFetcher)
        
            .environment(\.addressFollowingFetcher, addressFollowingFetcher)
            .environment(\.addressFollowersFetcher, addressFollowersFetcher)
            .environment(\.addressBlockListFetcher, addressBlockedFetcher)
        
            .task { performFirstRun() }
            .sheet(isPresented: $showOnboarding) { OnboardingView() }
            .alert("log out?", isPresented: $confirmLogout, actions: {
                Button("cancel", role: .cancel) { }
                Button(
                    "yes",
                    role: .destructive,
                    action: {
                        authenticate("")
                    }
                )
            }, message: {
                Text("are you sure you want to sign out of omg.lol?")
            })
    }
    
    @ViewBuilder
    private var appState: some View {
        TabBar()
            .tint(Color.lolPink)
            .background(NavigationDestination.community.gradient)
        
            .environment(\.addressBook, addressBook)
            .environment(\.credentialFetcher, credential(for:))
        
            .environment(\.addressSummaryFetcher, { appropriateFetcher(for: $0) })
        
            .environment(\.destinationConstructor, destinationConstructor)
        
            .environment(\.setAddress,      { updateAddress($0) })
            .environment(\.authenticate,    { authenticate($0) })
            .environment(\.pinAddress,      { pin($0) })
            .environment(\.unpinAddress,    { removePin($0) })
        
            .environment(\.followAddress,       { Task { [address = $0] in await follow(address) } })
            .environment(\.unfollowAddress,     { Task { [address = $0] in await unfollow(address) } })
            .environment(\.blockAddress,        { Task { [address = $0] in await block(address) } })
            .environment(\.unblockAddress,      { Task { [address = $0] in await unblock(address) } })
        
            .onChange(of: addressFetcher.results, { handleAddressesResults($1.map(\.owner)) })
            .onChange(of: appBlockedFetcher.results) { handleAddressFetcherChanged() }
            .onChange(of: localBlockedFetcher.results) { handleAddressFetcherChanged() }
            .onChange(of: pinnedFetcher.results) { handleAddressFetcherChanged(forceChange: true) }
            .onChange(of: addressFollowersFetcher.results) { handleAddressFetcherChanged() }
            .onChange(of: addressBlockedFetcher.results) { handleAddressFetcherChanged() }
            .onChange(of: addressFollowingFetcher.results) { handleAddressFetcherChanged() }
    }
    
    private func performFirstRun() {
        logger.debug("First run")
        if acceptedTerms < appDOTlolApp.termsUpdated.timeIntervalSince1970 {
            showOnboarding = true
        }
        configureAddressBook()
        addressFetcher.configure(credential: authKey)
        Task { [
            weak addressFetcher,
            weak appSupportFetcher,
            weak pinnedFetcher,
            weak appLatestFetcher,
            weak addressFollowersFetcher,
            weak addressFollowingFetcher,
            weak globalDirectoryFetcher,
            weak globalGardenFetcher,
            weak globalStatusFetcher,
            weak statusFetcher,
            weak gardenFetcher,
            weak appBlockedFetcher,
            weak localBlockedFetcher,
            weak addressBlockedFetcher,
            weak directoryFetcher
        ] in
            await addressFetcher?.updateIfNeeded(forceReload: true)
            logger.debug("addressFetcher updated")
            await appSupportFetcher?.updateIfNeeded(forceReload: true)
            logger.debug("appSupportFetcher updated")
            await pinnedFetcher?.updateIfNeeded(forceReload: true)
            logger.debug("pinnedFetcher updated")
            await globalDirectoryFetcher?.updateIfNeeded(forceReload: true)
            logger.debug("globalDirectoryFetcher updated")
            await globalGardenFetcher?.updateIfNeeded(forceReload: true)
            logger.debug("globalGardenFetcher updated")
            await globalStatusFetcher?.updateIfNeeded(forceReload: true)
            logger.debug("globalStatusFetcher updated")
            await addressFollowersFetcher?.updateIfNeeded(forceReload: true)
            logger.debug("addressFollowersFetcher updated")
            await addressFollowingFetcher?.updateIfNeeded(forceReload: true)
            logger.debug("addressFollowingFetcher updated")
            await statusFetcher?.updateIfNeeded(forceReload: true)
            logger.debug("statusFetcher updated")
            await gardenFetcher?.updateIfNeeded(forceReload: true)
            logger.debug("gardenFetcher updated")
            await appBlockedFetcher?.updateIfNeeded(forceReload: true)
            logger.debug("appBlockedFetcher updated")
            await localBlockedFetcher?.updateIfNeeded(forceReload: true)
            logger.debug("localBlockedFetcher updated")
            await addressBlockedFetcher?.updateIfNeeded(forceReload: true)
            logger.debug("addressBlockedFetcher updated")
            await directoryFetcher?.updateIfNeeded(forceReload: true)
            logger.debug("directoryFetcher updated")
            await appLatestFetcher?.updateIfNeeded(forceReload: true)
            logger.debug("appLatestFetcher updated")
        }
    }

    private func authenticate(_ credential: APICredential) {
        guard credential != authKey else { return }
        logger.debug("Authenticated")
        authKey = credential
        addressFetcher.configure(credential: credential)
        
        privateCache.removeAllObjects()
        updateAddress("")
        
        Task { [addressFetcher] in
            await addressFetcher.updateIfNeeded(forceReload: true)
        }
    }
    
    private func handleAddressesResults(_ results: [AddressName]) {
        logger.debug("Received addresses")
        if results.sorted() != addressBook.mine.sorted() || actingAddress.isEmpty {
            if actingAddress.isEmpty, let address = results.first {
                updateAddress(address)
            } else if !actingAddress.isEmpty, results.isEmpty {
                updateAddress("")
            } else {
                configureAddressBook()
            }
            if !results.isEmpty {
                applyAddressesToCache()
                Task { [weak database = AppClient.database, results = addressFetcher.results] in
                    guard let database else { return }
                    for model in results {
                        try await model.write(to: database)
                    }
                }
            }
        } else if addressBook.signedIn {
            addressFollowersFetcher.configure(address: actingAddress, credential: authKey)
            addressFollowingFetcher.configure(address: actingAddress, credential: authKey)
        }
    }
    
    private func applyAddressesToCache() {
        addressFetcher.results.forEach({
            let name = NSString(string: $0.addressName)
            if privateCache.object(forKey: name) == nil, let privateSummary = privateSummary(for: $0.addressName) {
                privateCache.setObject(privateSummary, forKey: name)
            }
        })
        let resultsToCache = addressFetcher.results + addressFollowersFetcher.results + addressFollowingFetcher.results
        let names = resultsToCache.map({ $0.addressName }).filter { privateCache.object(forKey: NSString(string: $0)) == nil }
        names.forEach({
            let name = NSString(string: $0)
            if cache.object(forKey: name) == nil {
                cache.setObject(addressSummary($0), forKey: name)
            }
        })
        applyPinnedAddressesToCache()
    }
    
    private func applyPinnedAddressesToCache() {
        pinnedFetcher.results.forEach({
            let name = NSString(string: $0.addressName)
            if cache.object(forKey: name) == nil {
                cache.setObject(addressSummary($0.addressName), forKey: name)
            }
        })
    }
    
    private func updateAddress(_ address: AddressName) {
        logger.debug("Configuring fetcher for \(address.isEmpty ? "n/a" : address)")
        guard self.actingAddress != address else { return }
        actingAddress = address
        addressFollowersFetcher.configure(address: address, credential: authKey)
        addressFollowingFetcher.configure(address: address, credential: authKey)
        addressBlockedFetcher.configure(address: address, credential: authKey)
        
        Task { [
            weak addressFollowersFetcher,
            weak addressFollowingFetcher,
            weak addressBlockedFetcher,
            weak localBlockedFetcher,
            weak directoryFetcher,
            weak gardenFetcher
        ] in
            await addressFollowersFetcher?.updateIfNeeded(forceReload: true)
            await addressFollowingFetcher?.updateIfNeeded(forceReload: true)
            await addressBlockedFetcher?.updateIfNeeded(forceReload: true)
            await localBlockedFetcher?.updateIfNeeded(forceReload: true)
            await directoryFetcher?.updateIfNeeded(forceReload: true)
            await gardenFetcher?.updateIfNeeded(forceReload: true)
        }
        
        handleAddressFetcherChanged(forceChange: true)
    }
    
    private func handleAddressFetcherChanged(forceChange: Bool = false) {
        let latest = createAddressBook()
        var changeToApply = forceChange
        if directoryFetcher.addressBook != latest {
            changeToApply = true
            directoryFetcher.configure(addressBook: latest)
        }
        if gardenFetcher.addressBook != latest {
            changeToApply = true
            gardenFetcher.configure(addressBook: latest)
        }
        if statusFetcher.addressBook != latest {
            changeToApply = true
            statusFetcher.configure(addressBook: latest)
        }
        if changeToApply {
            logger.debug("Updating core fetchers")
            configureAddressBook(latest)
            Task { [weak directoryFetcher, weak gardenFetcher, weak statusFetcher] in
                await directoryFetcher?.updateIfNeeded(forceReload: true)
                await gardenFetcher?.updateIfNeeded(forceReload: true)
                await statusFetcher?.updateIfNeeded(forceReload: true)
            }
        }
    }
    
    private func configureAddressBook(_ book: AddressBook? = nil) {
        let book = book ?? createAddressBook()
        self.destinationConstructor = .init(addressBook: book)
    }
    
    private func createAddressBook() -> AddressBook {
        .init(
            auth: authKey,
            me: actingAddress,
            mine: addressFetcher.myAddresses,
            following: addressFollowingFetcher.results.map(\.addressName),
            followers: addressFollowersFetcher.results.map(\.addressName),
            pinned: pinnedFetcher.results.map(\.addressName),
            blocked: Set(addressBlockedFetcher.results + localBlockedFetcher.results).map(\.addressName),
            appliedBlocked: Set(addressBlockedFetcher.results + appBlockedFetcher.results + localBlockedFetcher.results).map(\.addressName)
        )
    }
}

extension OMGScene {
    
    // MARK: Summaries
    
    func credential(for address: AddressName) -> APICredential? {
        guard addressBook.mine.contains(address) else {
            return nil
        }
        return authKey
    }
    
    func appropriateFetcher(for address: AddressName) -> AddressSummaryDataFetcher {
        if addressBook.mine.contains(address) {
            do {
                return try addressPrivateSummary(address)
            } catch {
                return addressSummary(address)
            }
        }
        return addressSummary(address)
    }
    func constructFetcher(for address: AddressName) -> AddressSummaryDataFetcher {
        AddressSummaryDataFetcher(name: address, addressBook: addressBook, interface: dataInterface)
    }
    func privateSummary(for address: AddressName) -> AddressPrivateSummaryDataFetcher? {
        guard credential(for: address) != nil else {
            return nil
        }
        return AddressPrivateSummaryDataFetcher(name: address, addressBook: addressBook, interface: dataInterface)
    }
    func addressSummary(_ address: AddressName) -> AddressSummaryDataFetcher {
        let mine = addressBook.mine.contains(where: { $0.lowercased() == address.lowercased() })
        let cachedProfile = cache.object(forKey: NSString(string: address))
        let privateCachedProfile = privateCache.object(forKey: NSString(string: address))
        if let model = cachedProfile ?? (mine ? privateCachedProfile : nil) {
            return model
        } else {
            let model = constructFetcher(for: address)
            cache.setObject(model, forKey: NSString(string: address))
            return model
        }
    }
    func addressPrivateSummary(_ address: AddressName) throws -> AddressPrivateSummaryDataFetcher {
        if let model = privateCache.object(forKey: NSString(string: address)) {
            return model
        } else {
            guard let model = privateSummary(for: address) else {
                throw AppClient.Error.notYourAddress
            }
            privateCache.setObject(model, forKey: NSString(string: address))
            return model
        }
    }
}

extension OMGScene {
    
    func pin(_ address: AddressName) {
        Task { [weak pinnedFetcher] in
            await pinnedFetcher?.pin(address.lowercased())
        }
    }
    func removePin(_ address: AddressName) {
        Task { [weak pinnedFetcher] in
            await pinnedFetcher?.removePin(address)
        }
    }
    func block(_ address: AddressName) async {
        let credential = credential(for: actingAddress)
        if addressBook.pinned.contains(address) {
            removePin(address)
        }
        Task { [weak addressBlockedFetcher, weak localBlockedFetcher] in
            if let credential {
                await addressBlockedFetcher?.block(address, credential: credential)
            }
            await localBlockedFetcher?.insert(address)
        }
    }
    func unblock(_ address: AddressName) async {
        let credential = credential(for: actingAddress)
        Task { [weak addressBlockedFetcher, weak localBlockedFetcher] in
            if let credential {
                await addressBlockedFetcher?.unBlock(address, credential: credential)
            }
            await localBlockedFetcher?.remove(address)
        }
    }
    
    func follow(_ address: AddressName) async {
        guard let credential = credential(for: actingAddress) else { return }
        Task { [weak addressFollowingFetcher] in
            await addressFollowingFetcher?.follow(address, credential: credential)
        }
    }
    func unfollow(_ address: AddressName) async {
        guard let credential = credential(for: actingAddress) else { return }
        Task { [weak addressFollowingFetcher] in
            await addressFollowingFetcher?.unFollow(address, credential: credential)
        }
    }
}


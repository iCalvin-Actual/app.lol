import Blackbird
import SwiftUI

public struct OMGScene: View {
    
    @AppStorage("app.lol.auth")
    var authKey: String = ""
    
    let termsUpdated: Date = .init(timeIntervalSince1970: 1727921377)
    @AppStorage("app.lol.terms")
    var acceptedTerms: TimeInterval = 0
    
    @AppStorage("app.lol.onboarding")
    var showOnboarding: Bool = false
    
    @Environment(\.webAuthenticationSession)
    var webAuthSession
    @Environment(\.apiInterface)
    var interface
    @Environment(\.blackbird)
    var database
    
    @Environment(\.profileCache)
    var cache
    @Environment(\.privateCache)
    var privateCache
    
    @Environment(\.omgClient)
    var clientInfo: ClientInfo
    @Environment(\.apiInterface)
    var dataInterface: DataInterface
    @Environment(\.addressFetcher)
    var accountAddressesFetcher: AccountAddressDataFetcher
    @Environment(\.globalBlocklist)
    var globalBlocklistFetcher: AddressBlockListDataFetcher
    @Environment(\.localBlocklist)
    var localBlocklistFetcher: LocalBlockListDataFetcher
    @Environment(\.pinnedFetcher)
    var pinnedFetcher: PinnedListDataFetcher
    
    @Environment(\.appSupportFetcher)
    var appSupportFetcher: AppSupportFetcher?
    @Environment(\.appLatestFetcher)
    var appLatestFetcher: AppLatestFetcher?
    
    @StateObject
    var addressFollowingFetcher: AddressFollowingDataFetcher
    @StateObject
    var addressFollowersFetcher: AddressFollowersDataFetcher
    @StateObject
    var addressBlockedFetcher: AddressBlockListDataFetcher
    
    @StateObject
    var directoryFetcher: AddressDirectoryDataFetcher
    @StateObject
    var gardenFetcher: NowGardenDataFetcher
    @StateObject
    var statusFetcher: StatusLogDataFetcher
    
    @SceneStorage("app.lol.address")
    var actingAddress: AddressName = ""
    
    @State
    var addressBook: AddressBook?
    
    public init(client: ClientInfo, interface: DataInterface, db: Blackbird.Database) {
        #if canImport(UIKit)
        UITabBar.appearance().unselectedItemTintColor = UIColor.white
        #endif
        self._addressFollowingFetcher = StateObject(wrappedValue: .init(address: "", credential: nil, interface: interface))
        self._addressFollowersFetcher = StateObject(wrappedValue: .init(address: "", credential: nil, interface: interface))
        self._addressBlockedFetcher = StateObject(wrappedValue: .init(address: "", credential: nil, interface: interface))
        self._directoryFetcher = StateObject(wrappedValue: .init(addressBook: .init(), interface: interface, db: db))
        self._gardenFetcher = StateObject(wrappedValue: .init(addressBook: .init(), interface: interface, db: db))
        self._statusFetcher = StateObject(wrappedValue: .init(addressBook: .init(), interface: interface, db: db))
    }
    
    func login() {
        guard let url = interface.authURL() else { return }
        Task { [webAuthSession] in
            do {
                let token = try await webAuthSession.authenticate(using: url, callback: .customScheme(clientInfo.urlScheme), additionalHeaderFields: [:])
                print("token: \(token)")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func logout() {
        authKey = ""
    }
    
    var sceneModel: SceneModel? {
        guard !showOnboarding, let addressBook else {
            return nil
        }
        return .init(
            addressBook: addressBook.scribble,
            interface: accountAddressesFetcher.interface,
            database: database
        )
    }
    
    public var body: some View {
        appState
            .tint(Color.black)
            .environment(\.login, login)
            .environment(\.logout, logout)
            .sheet(isPresented: $showOnboarding) {
                OnboardingView()
            }
    }
    
    var accountFetcher: AccountAuthDataFetcher? {
        guard addressBook != nil else { return nil }
        return .init(
            authKey: $authKey,
            session: webAuthSession,
            client: clientInfo,
            interface: interface
        )
    }
    
    @ViewBuilder
    private var appState: some View {
        if let accountFetcher {
            AuthenticationView(accountAuthDataFetcher: accountFetcher)
                .environment(accountFetcher)
                .environment(\.setAddress, { newAddress in
                    actingAddress = newAddress
                })
                .environment(\.addressBook, addressBook)
                .environment(\.destinationConstructor, addressBook?.destinationConstructor)
                .onChange(of: authKey, { oldValue, newValue in
                    if oldValue != newValue {
                        privateCache.removeAllObjects()
                        actingAddress = ""
                    }
                    accountAddressesFetcher.configure(credential: newValue)
                    Task { [accountAddressesFetcher] in
                        await accountAddressesFetcher.updateIfNeeded(forceReload: true)
                    }
                })
                .onChange(of: actingAddress, { oldValue, newValue in
                    if !oldValue.isEmpty, !newValue.isEmpty, oldValue != newValue {
                        handleAddressChange()
                    }
                })
                .onReceive(accountAddressesFetcher.results.publisher, perform: { _ in
                    Task { [results = accountAddressesFetcher.results] in
                        for model in results {
                            let database = database
                            try await model.write(to: database)
                        }
                    }
                    if actingAddress.isEmpty, let address = accountAddressesFetcher.results.first {
                        actingAddress = address.addressName
                    }
                    applyAddressesToCache()
                })
                .onReceive(globalBlocklistFetcher.results.publisher) { _ in
                    handleAddressFetcherChanged()
                }
                .onReceive(localBlocklistFetcher.results.publisher) { _ in
                    handleAddressFetcherChanged()
                }
                .onReceive(pinnedFetcher.results.publisher) { _ in
                    handleAddressFetcherChanged()
                }
                .onReceive(addressFollowersFetcher.results.publisher) { _ in
                    handleAddressFetcherChanged()
                }
                .onReceive(addressFollowingFetcher.results.publisher) { _ in
                    handleAddressFetcherChanged()
                }
                .onReceive(addressBlockedFetcher.results.publisher) { _ in
                    handleAddressFetcherChanged()
                }
        } else {
            LoadingView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.lolPink)
                .task {
                    if acceptedTerms < termsUpdated.timeIntervalSince1970 {
                        showOnboarding = true
                    }
                    accountAddressesFetcher.configure(credential: authKey)
                    configureAddressBook()
                }
        }
    }
    
    private func applyAddressesToCache() {
        guard let addressBook = addressBook else { return }
        accountAddressesFetcher.results.forEach({
            let name = NSString(string: $0.addressName)
            if privateCache.object(forKey: name) == nil, let privateSummary = addressBook.privateSummary(for: $0.addressName) {
                privateCache.setObject(privateSummary, forKey: name)
            }
        })
        let namesToCache = accountAddressesFetcher.results + addressFollowersFetcher.results + addressFollowingFetcher.results
        namesToCache.forEach({
            let name = NSString(string: $0.addressName)
            if cache.object(forKey: name) == nil {
                cache.setObject(addressBook.addressSummary($0.addressName), forKey: name)
            }
        })
    }
    
    private func applyPinnedAddressesToCache() {
        guard let addressBook = addressBook else { return }
        pinnedFetcher.results.forEach({
            let name = NSString(string: $0.addressName)
            if cache.object(forKey: name) == nil {
                cache.setObject(addressBook.addressSummary($0.addressName), forKey: name)
            }
        })
    }
    
    private func handleAddressChange() {
        addressFollowersFetcher.configure(address: actingAddress, credential: authKey)
        addressFollowingFetcher.configure(address: actingAddress, credential: authKey)
        addressBlockedFetcher.configure(address: actingAddress, credential: authKey)
        
        handleAddressFetcherChanged(forceChange: true)
    }
    
    private func handleAddressFetcherChanged(forceChange: Bool = false) {
        let fallback = AddressBook.Scribbled(
            auth: authKey,
            me: actingAddress,
            mine: accountAddressesFetcher.results.map({ $0.addressName }),
            following: addressFollowingFetcher.results.map({ $0.addressName }),
            followers: addressFollowersFetcher.results.map({ $0.addressName }),
            pinned: pinnedFetcher.results.map({ $0.addressName }),
            blocked: localBlocklistFetcher.results.map({ $0.addressName }),
            appliedBlocked: globalBlocklistFetcher.results.map({ $0.addressName }) + localBlocklistFetcher.results.map({ $0.addressName })
        )
        let latest = addressBook?.scribble ?? fallback
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
            configureAddressBook()
        }
    }
    
    private func configureAddressBook() {
        print("Making address book")
        self.addressBook = .init(
            authKey: authKey,
            interface: interface,
            database: database,
            actingAddress: actingAddress,
            accountAddressesFetcher: accountAddressesFetcher,
            globalBlocklistFetcher: globalBlocklistFetcher,
            localBlocklistFetcher: localBlocklistFetcher,
            addressBlocklistFetcher: addressBlockedFetcher,
            addressFollowingFetcher: addressFollowingFetcher,
            addressFollowersFetcher: addressFollowersFetcher,
            pinnedAddressFetcher: pinnedFetcher,
            appSupportFetcher: appSupportFetcher ?? .init(interface: interface, db: database),
            appStatusFetcher: appLatestFetcher ?? .`init`(interface: interface, db: database),
            directoryFetcher: directoryFetcher,
            gardenFetcher: gardenFetcher,
            statusFetcher: statusFetcher,
            publicCache: cache,
            privateCache: privateCache
        )
        Task { @MainActor [addressBook] in
            await addressBook?.autoFetch()
        }
    }
}


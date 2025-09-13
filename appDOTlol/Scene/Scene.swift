import Blackbird
import SwiftUI
import os

private let logger = Logger(subsystem: "OMGScene", category: "scene-events")

public struct OMGScene: View {
    
    @SceneStorage("lol.address") var actingAddress: AddressName = ""
    
    @Environment(\.credentialFetcher) var credential
    
    @Environment(\.profileCache) var cache
    @Environment(\.privateCache) var privateCache
    @Environment(\.unpinAddress) var removePin
    
    @Environment(\.webAuthenticationSession)
    private var webAuthSession
    var accountFetcher: AccountAuthFetcher {
        return .init(
            session: webAuthSession,
            client: AppClient.info,
            interface: AppClient.interface,
            authenticate: {
                Task { @MainActor [cred = $0] in
                    appModel.authenticate(cred)
                }
            }
        )
    }
    
    @State var sceneModel: SceneModel = .init(addressBook: .init())
    
    @Bindable var appModel: AppModel
    
    public var body: some View {
        TabBar()
            .tint(Color.lolAccent)
        
            .task { configureAddressBook() }
        
            .environment(accountFetcher)
            .environment(\.destinationConstructor, sceneModel)
            .environment(\.addressBook, sceneModel.addressBook)
            .environment(\.addressSummaryFetcher, { appropriateFetcher(for: $0) })
        
            .environment(\.setAddress,      { updateAddress($0) })
        
            .environment(\.followAddress,       { Task { [address = $0] in await follow(address) } })
            .environment(\.unfollowAddress,     { Task { [address = $0] in await unfollow(address) } })
            .environment(\.blockAddress,        { Task { [address = $0] in await block(address) } })
            .environment(\.unblockAddress,      { Task { [address = $0] in await unblock(address) } })
        
            .onChange(of: appModel.addressFetcher.results) {
                handleAddressesResults($1.map(\.addressName))
            }
        
            .onChange(of: appModel.appBlockedFetcher.results)   { configureAddressBook() }
            .onChange(of: appModel.localBlockedFetcher.results) { configureAddressBook() }
            .onChange(of: appModel.pinnedFetcher.results)       { configureAddressBook() }
        
            .onChange(of: sceneModel.addressFollowersFetcher.results)   { configureAddressBook() }
            .onChange(of: sceneModel.addressBlockedFetcher.results)     { configureAddressBook() }
            .onChange(of: sceneModel.addressFollowingFetcher.results)   { configureAddressBook() }
    }
}

extension OMGScene {
    private func updateAddress(_ address: AddressName) {
        logger.debug("Configuring fetcher for \(address.isEmpty ? "n/a" : address)")
        guard self.actingAddress != address else { return }
        actingAddress = address
        configureAddressBook()
    }
    
    private func handleAddressesResults(_ results: [AddressName]) {
        logger.debug("Received addresses")
        let addressBook = sceneModel.addressBook
        if results.sorted() != addressBook.mine.sorted() || actingAddress.isEmpty || addressBook.auth.isEmpty {
            if actingAddress.isEmpty, let address = results.first {
                updateAddress(address)
            } else if !actingAddress.isEmpty, results.isEmpty {
                updateAddress("")
            } else {
                configureAddressBook()
            }
            if !results.isEmpty {
                applyAddressesToCache()
                Task { [weak database = AppClient.database, results = appModel.addressFetcher.results] in
                    guard let database else { return }
                    for model in results {
                        try await model.write(to: database)
                    }
                }
            }
        }
    }
}

// MARK: Address Book Configuration

extension OMGScene {
    private func configureAddressBook() {
        let book = createAddressBook()
        if book != sceneModel.addressBook {
            sceneModel.configure(book)
        }
    }
    
    private func createAddressBook() -> AddressBook {
        let visibleBlocklist = Set(
            sceneModel
                .addressBlockedFetcher
                .results +
            appModel.localBlockedFetcher
                .results
        ).map(\.addressName)
        let appliedBlocklist = Set(
            appModel.appBlockedFetcher
                .results
                .map(\.addressName) +
            visibleBlocklist
        )
        
        return .init(
            auth: credential(actingAddress) ?? "",
            me: actingAddress,
            mine: appModel.addressFetcher.results.map({ $0.addressName }),
            following: sceneModel
                .addressFollowingFetcher
                .results
                .map(\.addressName),
            followers: sceneModel
                .addressFollowersFetcher
                .results
                .map(\.addressName),
            pinned: appModel.pinnedFetcher
                .results
                .map(\.addressName),
            blocked: visibleBlocklist,
            appliedBlocked: .init(appliedBlocklist)
        )
    }
}

// MARK: Actions on Address

extension OMGScene {
    
    func block(_ address: AddressName) async {
        let credential = credential(actingAddress)
        if sceneModel.addressBook.pinned.contains(address) {
            removePin(address)
        }
        Task { [weak addressBlockedFetcher = sceneModel.addressBlockedFetcher, weak localBlockedFetcher = appModel.localBlockedFetcher] in
            if let credential {
                await addressBlockedFetcher?.block(address, credential: credential)
            }
            await localBlockedFetcher?.insert(address)
        }
    }
    func unblock(_ address: AddressName) async {
        let credential = credential(actingAddress)
        Task { [
            weak addressBlockedFetcher = sceneModel.addressBlockedFetcher,
            weak localBlockedFetcher = appModel.localBlockedFetcher
        ] in
            if let credential {
                await addressBlockedFetcher?.unBlock(address, credential: credential)
            }
            await localBlockedFetcher?.remove(address)
        }
    }
    
    func follow(_ address: AddressName) async {
        guard let credential = credential(actingAddress) else { return }
        Task { [weak addressFollowingFetcher = sceneModel.addressFollowingFetcher] in
            await addressFollowingFetcher?.follow(address, credential: credential)
        }
    }
    func unfollow(_ address: AddressName) async {
        guard let credential = credential(actingAddress) else { return }
        Task { [weak addressFollowingFetcher = sceneModel.addressFollowingFetcher] in
            await addressFollowingFetcher?.unFollow(address, credential: credential)
        }
    }
}

// MARK: Address Caching

extension OMGScene {
    
    private func applyAddressesToCache() {
        let addressBook = sceneModel.addressBook
        addressBook.mine.forEach({
            let name = NSString(string: $0)
            if privateCache.object(forKey: name) == nil, let privateSummary = privateSummary(for: $0) {
                privateCache.setObject(privateSummary, forKey: name)
            }
        })
        let resultsToCache = appModel.addressFetcher.results + sceneModel.addressFollowersFetcher.results + sceneModel.addressFollowingFetcher.results
        let names = resultsToCache.map({ $0.addressName }).filter { privateCache.object(forKey: NSString(string: $0)) == nil }
        names.forEach({
            let name = NSString(string: $0)
            if cache.object(forKey: name) == nil {
                cache.setObject(addressSummary($0), forKey: name)
            }
        })
        
        appModel.pinnedFetcher.results.forEach({
            let name = NSString(string: $0.addressName)
            if cache.object(forKey: name) == nil {
                cache.setObject(addressSummary($0.addressName), forKey: name)
            }
        })
    }
    
    private var myAddresses: [AddressName] {
        return sceneModel.addressBook
            .mine
            .map({ $0.lowercased() })
    }
    
    func appropriateFetcher(for address: AddressName) -> AddressSummaryFetcher {
        if myAddresses.contains(address.lowercased()) {
            do {
                return try addressPrivateSummary(address)
            } catch {
                return addressSummary(address)
            }
        }
        return addressSummary(address)
    }
    func addressSummary(_ address: AddressName) -> AddressSummaryFetcher {
        let cachedProfile = cache.object(forKey: NSString(string: address))
        if let model = cachedProfile  {
            return model
        } else {
            let model = constructFetcher(for: address)
            cache.setObject(model, forKey: NSString(string: address))
            return model
        }
    }
    func addressPrivateSummary(_ address: AddressName) throws -> AddressPrivateSummaryFetcher {
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
    func privateSummary(for address: AddressName) -> AddressPrivateSummaryFetcher? {
        guard credential(address) != nil else {
            return nil
        }
        return AddressPrivateSummaryFetcher(name: address, addressBook: sceneModel.addressBook)
    }
    func constructFetcher(for address: AddressName) -> AddressSummaryFetcher {
        AddressSummaryFetcher(name: address, addressBook: sceneModel.addressBook)
    }
}


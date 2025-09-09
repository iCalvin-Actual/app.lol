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
    
    @Bindable
    var addressFetcher: AccountAddressDataFetcher
    
    let globalDirectoryFetcher: GlobalAddressDirectoryFetcher
    let globalStatusFetcher: GlobalStatusLogFetcher
    
    let appSupportFetcher: AppSupportFetcher
    let localBlockedFetcher: LocalBlockListDataFetcher
    let pinnedFetcher: PinnedListDataFetcher
    
    let appLatestFetcher: AppLatestFetcher
    let appBlockedFetcher: AddressBlockListDataFetcher
    
    let dataInterface: DataInterface
    
    @State var destinationConstructor: DestinationConstructor = .init(addressBook: .init())
    var addressBook: AddressBook { destinationConstructor.addressBook }
    
    public var body: some View {
        TabBar(addressBook: addressBook)
            .tint(Color.lolAccent)
        //            .background(NavigationDestination.community.gradient)
        
            .task {
                refreshLists()
            }
        
            .environment(\.addressBook, addressBook)
        
            .environment(\.addressSummaryFetcher, { appropriateFetcher(for: $0) })
        
            .environment(\.destinationConstructor, destinationConstructor)
        
            .environment(\.setAddress,      { updateAddress($0) })
        
            .environment(\.followAddress,       { Task { [address = $0] in await follow(address) } })
            .environment(\.unfollowAddress,     { Task { [address = $0] in await unfollow(address) } })
            .environment(\.blockAddress,        { Task { [address = $0] in await block(address) } })
            .environment(\.unblockAddress,      { Task { [address = $0] in await unblock(address) } })
        
            .onChange(of: addressFetcher.results) {
                handleAddressesResults(addressFetcher.results.map(\.addressName))
            }
        
            .onChange(of: appBlockedFetcher.results) {
                refreshLists()
            }
            .onChange(of: localBlockedFetcher.results) {
                refreshLists()
            }
            .onChange(of: pinnedFetcher.results) {
                refreshLists()
            }
        
            .onChange(of: destinationConstructor.addressFollowersFetcher.results) {
                refreshLists()
            }
            .onChange(of: destinationConstructor.addressBlockedFetcher.results) {
                refreshLists()
            }
            .onChange(of: destinationConstructor.addressFollowingFetcher.results) {
                refreshLists()
            }
    }
    
    private func refreshLists() {
        configureAddressBook()
    }
    
    private func handleAddressesResults(_ results: [AddressName]) {
        logger.debug("Received addresses")
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
                Task { [weak database = AppClient.database, results = addressFetcher.results] in
                    guard let database else { return }
                    for model in results {
                        try await model.write(to: database)
                    }
                }
            }
        }
    }
    
    private func applyAddressesToCache() {
        addressBook.mine.forEach({
            let name = NSString(string: $0)
            if privateCache.object(forKey: name) == nil, let privateSummary = privateSummary(for: $0) {
                privateCache.setObject(privateSummary, forKey: name)
            }
        })
        let resultsToCache = addressFetcher.results + destinationConstructor.addressFollowersFetcher.results + destinationConstructor.addressFollowingFetcher.results
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
        configureAddressBook()
    }
    
    private func configureAddressBook(_ book: AddressBook? = nil) {
        let book = book ?? createAddressBook()
        if book != addressBook {
            destinationConstructor.configure(book)
        }
    }
    
    private func createAddressBook() -> AddressBook {
        let visibleBlocklist = Set(
            destinationConstructor
                .addressBlockedFetcher
                .results +
            localBlockedFetcher
                .results
        ).map(\.addressName)
        let appliedBlocklist = Set(
            appBlockedFetcher
                .results
                .map(\.addressName) +
            visibleBlocklist
        )
        
        return .init(
            auth: credential(actingAddress) ?? "",
            me: actingAddress,
            mine: addressFetcher.myAddresses,
            following: destinationConstructor
                .addressFollowingFetcher
                .results
                .map(\.addressName),
            followers: destinationConstructor
                .addressFollowersFetcher
                .results
                .map(\.addressName),
            pinned: pinnedFetcher
                .results
                .map(\.addressName),
            blocked: visibleBlocklist,
            appliedBlocked: .init(appliedBlocklist)
        )
    }
}

extension OMGScene {
    
    func block(_ address: AddressName) async {
        let credential = credential(actingAddress)
        if addressBook.pinned.contains(address) {
            removePin(address)
        }
        Task { [weak addressBlockedFetcher = destinationConstructor.addressBlockedFetcher, weak localBlockedFetcher = localBlockedFetcher] in
            if let credential {
                await addressBlockedFetcher?.block(address, credential: credential)
            }
            await localBlockedFetcher?.insert(address)
        }
    }
    func unblock(_ address: AddressName) async {
        let credential = credential(actingAddress)
        Task { [
            weak addressBlockedFetcher = destinationConstructor.addressBlockedFetcher,
            weak localBlockedFetcher
        ] in
            if let credential {
                await addressBlockedFetcher?.unBlock(address, credential: credential)
            }
            await localBlockedFetcher?.remove(address)
        }
    }
    
    func follow(_ address: AddressName) async {
        guard let credential = credential(actingAddress) else { return }
        Task { [weak addressFollowingFetcher = destinationConstructor.addressFollowingFetcher] in
            await addressFollowingFetcher?.follow(address, credential: credential)
        }
    }
    func unfollow(_ address: AddressName) async {
        guard let credential = credential(actingAddress) else { return }
        Task { [weak addressFollowingFetcher = destinationConstructor.addressFollowingFetcher] in
            await addressFollowingFetcher?.unFollow(address, credential: credential)
        }
    }
}

extension OMGScene {
    
    private var myAddresses: [AddressName] {
        return addressBook
            .mine
            .map({ $0.lowercased() })
    }
    
    // MARK: Summaries
    
    func appropriateFetcher(for address: AddressName) -> AddressSummaryDataFetcher {
        if myAddresses.contains(address.lowercased()) {
            do {
                return try addressPrivateSummary(address)
            } catch {
                return addressSummary(address)
            }
        }
        return addressSummary(address)
    }
    func addressSummary(_ address: AddressName) -> AddressSummaryDataFetcher {
        let mine = myAddresses.contains(address.lowercased())
        let cachedProfile = cache.object(forKey: NSString(string: address))
        let privateCachedProfile = privateCache.object(forKey: NSString(string: address))
        if let model = (mine ? privateCachedProfile : nil) ?? cachedProfile  {
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
    func privateSummary(for address: AddressName) -> AddressPrivateSummaryDataFetcher? {
        guard credential(address) != nil else {
            return nil
        }
        return AddressPrivateSummaryDataFetcher(name: address, addressBook: .init(), interface: AppClient.interface)
    }
    func constructFetcher(for address: AddressName) -> AddressSummaryDataFetcher {
        AddressSummaryDataFetcher(name: address, addressBook: addressBook, interface: dataInterface)
    }
}


//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 9/18/24.
//

import Blackbird
import SwiftUI
import Foundation

@Observable
@MainActor
final class AddressBook {
    
    let apiKey: APICredential
    
    var actingAddress: AddressName
    
    let accountAddressesFetcher: AccountAddressDataFetcher
    
    let globalBlocklistFetcher: AddressBlockListDataFetcher
    let localBlocklistFetcher: LocalBlockListDataFetcher
    let addressBlocklistFetcher: AddressBlockListDataFetcher
    
    let appSupportFetcher: AppSupportFetcher
    let appStatusFetcher: AppLatestFetcher
    
    let addressFollowingFetcher: AddressFollowingDataFetcher
    let addressFollowersFetcher: AddressFollowersDataFetcher
    
    let pinnedAddressFetcher: PinnedListDataFetcher
    
    let directoryFetcher: AddressDirectoryDataFetcher
    let gardenFetcher: NowGardenDataFetcher
    let statusFetcher: StatusLogDataFetcher
    
    let interface: DataInterface
    let database: Blackbird.Database
    
    let publicCache: ProfileCache
    let privateCache: PrivateCache
    
    var destinationConstructor: DestinationConstructor {
        .init(addressBook: self, appSupportFetcher: appSupportFetcher, appLatestFetcher: appStatusFetcher)
    }
    
    init(
        authKey: APICredential,
        interface: DataInterface,
        database: Blackbird.Database,
        actingAddress: AddressName,
        accountAddressesFetcher: AccountAddressDataFetcher,
        globalBlocklistFetcher: AddressBlockListDataFetcher,
        localBlocklistFetcher: LocalBlockListDataFetcher,
        addressBlocklistFetcher: AddressBlockListDataFetcher,
        addressFollowingFetcher: AddressFollowingDataFetcher,
        addressFollowersFetcher: AddressFollowersDataFetcher,
        pinnedAddressFetcher: PinnedListDataFetcher,
        appSupportFetcher: AppSupportFetcher,
        appStatusFetcher: AppLatestFetcher,
        directoryFetcher: AddressDirectoryDataFetcher,
        gardenFetcher: NowGardenDataFetcher,
        statusFetcher: StatusLogDataFetcher,
        publicCache: ProfileCache,
        privateCache: PrivateCache
    ) {
        self.apiKey = authKey
        self.interface = interface
        self.database = database
        self.actingAddress = actingAddress
        self.accountAddressesFetcher = accountAddressesFetcher
        self.globalBlocklistFetcher = globalBlocklistFetcher
        self.localBlocklistFetcher = localBlocklistFetcher
        self.addressBlocklistFetcher = addressBlocklistFetcher
        self.addressFollowingFetcher = addressFollowingFetcher
        self.addressFollowersFetcher = addressFollowersFetcher
        self.pinnedAddressFetcher = pinnedAddressFetcher
        self.appSupportFetcher = appSupportFetcher
        self.appStatusFetcher = appStatusFetcher
        self.directoryFetcher = directoryFetcher
        self.gardenFetcher = gardenFetcher
        self.statusFetcher = statusFetcher
        self.publicCache = publicCache
        self.privateCache = privateCache
    }
    
    @MainActor
    func autoFetch() async {
        async let _ = appStatusFetcher.updateIfNeeded(forceReload: false)
        Task { [appSupportFetcher, accountAddressesFetcher, globalBlocklistFetcher, localBlocklistFetcher, pinnedAddressFetcher, addressBlocklistFetcher, addressFollowingFetcher, addressFollowersFetcher, directoryFetcher, gardenFetcher, statusFetcher] in
            async let _ = appSupportFetcher.updateIfNeeded(forceReload: false)
            async let _ = accountAddressesFetcher.updateIfNeeded(forceReload: true)
            async let _ = globalBlocklistFetcher.updateIfNeeded(forceReload: false)
            async let _ = localBlocklistFetcher.updateIfNeeded(forceReload: false)
            async let _ = pinnedAddressFetcher.updateIfNeeded(forceReload: false)
            async let _ = addressBlocklistFetcher.updateIfNeeded(forceReload: true)
            async let _ = addressFollowingFetcher.updateIfNeeded(forceReload: true)
            async let _ = addressFollowersFetcher.updateIfNeeded(forceReload: true)
            async let _ = directoryFetcher.updateIfNeeded(forceReload: true)
            async let _ = gardenFetcher.updateIfNeeded(forceReload: true)
            async let _ = statusFetcher.updateIfNeeded(forceReload: true)
        }
    }
    
    func credential(for address: AddressName) -> APICredential? {
        guard myAddresses.contains(address) else {
            return nil
        }
        return apiKey
    }
    
    var signedIn: Bool {
        !apiKey.isEmpty
    }
    
    @MainActor
    func updateActiveFetchers() {
        Task { [addressBlocklistFetcher, addressFollowingFetcher, addressFollowersFetcher] in
            await addressBlocklistFetcher.updateIfNeeded(forceReload: true)
            await addressFollowingFetcher.updateIfNeeded(forceReload: true)
            await addressFollowersFetcher.updateIfNeeded(forceReload: true)
        }
    }
    
    func pin(_ address: AddressName) {
        Task { [pinnedAddressFetcher] in
            await pinnedAddressFetcher.pin(address)
        }
    }
    func removePin(_ address: AddressName) {
        Task { [pinnedAddressFetcher] in
            await pinnedAddressFetcher.removePin(address)
        }
    }
    func block(_ address: AddressName) async {
        if let credential = credential(for: actingAddress) {
            Task { [addressBlocklistFetcher] in
                await addressBlocklistFetcher.block(address, credential: credential)
            }
        }
        Task { [localBlocklistFetcher] in
            await localBlocklistFetcher.insert(address)
        }
    }
    func unblock(_ address: AddressName) async {
        if let credential = credential(for: actingAddress) {
            Task { [addressBlocklistFetcher] in
                await addressBlocklistFetcher.unBlock(address, credential: credential)
            }
        }
        Task { [localBlocklistFetcher] in
            await localBlocklistFetcher.remove(address)
        }
    }
    
    func follow(_ address: AddressName) async {
        guard let credential = credential(for: actingAddress) else {
            return
        }
        await addressFollowingFetcher.follow(address, credential: credential)
    }
    func unFollow(_ address: AddressName) async {
        guard let credential = credential(for: actingAddress) else {
            return
        }
        await addressFollowingFetcher.unFollow(address, credential: credential)
    }
}

extension AddressBook {
    var myAddresses: [AddressName] {
        accountAddressesFetcher.results.map({ $0.addressName })
    }
    var myOtherAddresses: [AddressName] {
        myAddresses.filter({ $0 != actingAddress })
    }
    var globalBlocked: [AddressName] {
        globalBlocklistFetcher.results.map({ $0.addressName })
    }
    var addressBlocked: [AddressName] {
        addressBlocklistFetcher.results.map({ $0.addressName })
    }
    var localBlocked: [AddressName] {
        localBlocklistFetcher.results.map({ $0.addressName })
    }
    var following: [AddressName] {
        addressFollowingFetcher.results.map({ $0.addressName })
    }
    var followers: [AddressName] {
        addressFollowersFetcher.results.map({ $0.addressName })
    }
    var pinnedAddresses: [AddressName] {
        pinnedAddressFetcher.pinnedAddresses
    }
    var appliedBlocked: [AddressName] {
        Array(Set(globalBlocked + visibleBlocked))
    }
    var visibleBlocked: [AddressName] {
        Array(Set(addressBlocked + localBlocked))
    }
}

extension AddressBook {
    enum AddressBookError: Error {
        case notYourAddress
    }
    
    // MARK: Summaries
    
    func appropriateFetcher(for address: AddressName) -> AddressSummaryDataFetcher {
        let fallback = addressSummary(address)
        if myAddresses.contains(address) {
            do {
                return try addressPrivateSummary(address)
            } catch {
                return fallback
            }
        }
        return addressSummary(address)
    }
    func constructFetcher(for address: AddressName) -> AddressSummaryDataFetcher {
        AddressSummaryDataFetcher(name: address, addressBook: scribble, interface: interface, database: database)
    }
    func privateSummary(for address: AddressName) -> AddressPrivateSummaryDataFetcher? {
        guard credential(for: address) != nil else {
            return nil
        }
        return AddressPrivateSummaryDataFetcher(name: address, addressBook: scribble, interface: interface, database: database)
    }
    func addressSummary(_ address: AddressName) -> AddressSummaryDataFetcher {
        if let model = publicCache.object(forKey: NSString(string: address)) ?? (myAddresses.contains(where: { $0.lowercased() == address.lowercased() }) ? privateCache.object(forKey: NSString(string: address)) : nil) {
            return model
        } else {
            let model = constructFetcher(for: address)
            publicCache.setObject(model, forKey: NSString(string: address))
            return model
        }
    }
    func addressPrivateSummary(_ address: AddressName) throws -> AddressPrivateSummaryDataFetcher {
        if let model = privateCache.object(forKey: NSString(string: address)) {
            return model
        } else {
            guard let model = privateSummary(for: address) else {
                throw AddressBookError.notYourAddress
            }
            privateCache.setObject(model, forKey: NSString(string: address))
            return model
        }
    }
}

@MainActor
extension AddressBook {
    func isPinned(_ address: AddressName) -> Bool {
        pinnedAddresses.contains(address)
    }
    func isBlocked(_ address: AddressName) -> Bool {
        appliedBlocked.contains(address)
    }
    func canUnblock(_ address: AddressName) -> Bool {
        visibleBlocked.contains(address)
    }
    func isFollowing(_ address: AddressName) -> Bool {
        guard signedIn else {
            return false
        }
        return following.contains(address)
    }
    func canFollow(_ address: AddressName) -> Bool {
        guard signedIn else {
            return false
        }
        return !following.contains(address)
    }
    func canUnFollow(_ address: AddressName) -> Bool {
        guard signedIn else {
            return false
        }
        return following.contains(address)
    }
}

extension AddressBook {
    nonisolated
    struct Scribbled: Equatable {
        let auth: APICredential
        let me: AddressName
        let mine: [AddressName]
        let following: [AddressName]
        let followers: [AddressName]
        let pinned: [AddressName]
        let blocked: [AddressName]
        let appliedBlocked: [AddressName]
        
        static func ==(lhs: Scribbled, rhs: Scribbled) -> Bool {
            func namedEqual(lhs: [AddressName], rhs: [AddressName]) -> Bool {
                lhs.sorted() == rhs.sorted()
            }
            
            return lhs.auth == rhs.auth &&
            lhs.me == rhs.me &&
            namedEqual(lhs: lhs.mine, rhs: rhs.mine) &&
            namedEqual(lhs: lhs.following, rhs: rhs.following) &&
            namedEqual(lhs: lhs.followers, rhs: rhs.followers) &&
            namedEqual(lhs: lhs.pinned, rhs: rhs.pinned) &&
            namedEqual(lhs: lhs.blocked, rhs: rhs.blocked) &&
            namedEqual(lhs: lhs.appliedBlocked, rhs: rhs.appliedBlocked)
        }
        
        init(
            auth: APICredential = "",
            me: AddressName = "",
            mine: [AddressName] = [],
            following: [AddressName] = [],
            followers: [AddressName] = [],
            pinned: [AddressName] = [],
            blocked: [AddressName] = [],
            appliedBlocked: [AddressName] = []
        ) {
            self.auth = auth
            self.me = me
            self.mine = mine
            self.following = following
            self.followers = followers
            self.pinned = pinned
            self.blocked = blocked
            self.appliedBlocked = appliedBlocked
        }
        
        func credential(for address: AddressName) -> APICredential? {
            guard mine.contains(address) else {
                return nil
            }
            return auth
        }
    }
    
    var scribble: Scribbled {
        .init(
            auth: apiKey,
            me: actingAddress,
            mine: myAddresses,
            following: following,
            followers: followers,
            pinned: pinnedAddresses,
            blocked: visibleBlocked,
            appliedBlocked: appliedBlocked
        )
    }
}

//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 9/18/24.
//

import SwiftUI
import Foundation

@Observable
@MainActor
final class AddressBook {
    
    let apiKey: APICredential
    
    var actingAddress: Binding<AddressName>
    
    let accountAddressesFetcher: AccountAddressDataFetcher
    
    let globalBlocklistFetcher: AddressBlockListDataFetcher
    let localBlocklistFetcher: LocalBlockListDataFetcher
    let addressBlocklistFetcher: AddressBlockListDataFetcher
    
    let addressFollowingFetcher: AddressFollowingDataFetcher
    let addressFollowersFetcher: AddressFollowersDataFetcher
    
    let pinnedAddressFetcher: PinnedListDataFetcher
    
    var myAddresses: [AddressName] {
        accountAddressesFetcher.results.map({ $0.addressName })
    }
    var myOtherAddresses: [AddressName] {
        myAddresses.filter({ $0 != actingAddress.wrappedValue })
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
    
    init(
        authKey: APICredential,
        actingAddress: Binding<AddressName>,
        accountAddressesFetcher: AccountAddressDataFetcher,
        globalBlocklistFetcher: AddressBlockListDataFetcher,
        localBlocklistFetcher: LocalBlockListDataFetcher,
        addressBlocklistFetcher: AddressBlockListDataFetcher,
        addressFollowingFetcher: AddressFollowingDataFetcher,
        addressFollowersFetcher: AddressFollowersDataFetcher,
        pinnedAddressFetcher: PinnedListDataFetcher
    ) {
        self.apiKey = authKey
        self.actingAddress = actingAddress
        self.accountAddressesFetcher = accountAddressesFetcher
        self.globalBlocklistFetcher = globalBlocklistFetcher
        self.localBlocklistFetcher = localBlocklistFetcher
        self.addressBlocklistFetcher = addressBlocklistFetcher
        self.addressFollowingFetcher = addressFollowingFetcher
        self.addressFollowersFetcher = addressFollowersFetcher
        self.pinnedAddressFetcher = pinnedAddressFetcher
    }
    
    @MainActor
    func autoFetch() async {
        await accountAddressesFetcher.updateIfNeeded(forceReload: true)
        await globalBlocklistFetcher.updateIfNeeded(forceReload: true)
        await localBlocklistFetcher.updateIfNeeded(forceReload: true)
        await addressBlocklistFetcher.updateIfNeeded(forceReload: true)
        await addressFollowingFetcher.updateIfNeeded(forceReload: true)
        await addressFollowersFetcher.updateIfNeeded(forceReload: true)
        await pinnedAddressFetcher.updateIfNeeded(forceReload: true)
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
        Task { [addressBlocklistFetcher, addressFollowingFetcher] in
            await addressBlocklistFetcher.updateIfNeeded(forceReload: true)
            await addressFollowingFetcher.updateIfNeeded(forceReload: true)
            await addressFollowersFetcher.updateIfNeeded(forceReload: true)
        }
    }
    
    func pin(_ address: AddressName) async {
        await pinnedAddressFetcher.pin(address)
    }
    func removePin(_ address: AddressName) async {
        await pinnedAddressFetcher.removePin(address)
    }
    
    func block(_ address: AddressName) async {
        if let credential = credential(for: actingAddress.wrappedValue) {
            await addressBlocklistFetcher.block(address, credential: credential)
        }
        await localBlocklistFetcher.insert(address)
    }
    func unblock(_ address: AddressName) async {
        if let credential = credential(for: actingAddress.wrappedValue) {
            await addressBlocklistFetcher.unBlock(address, credential: credential)
        }
        await localBlocklistFetcher.remove(address)
    }
    
    @MainActor
    func follow(_ address: AddressName) async {
        guard let credential = credential(for: actingAddress.wrappedValue) else {
            return
        }
        await addressFollowingFetcher.follow(address, credential: credential)
    }
    @MainActor
    func unFollow(_ address: AddressName) async {
        guard let credential = credential(for: actingAddress.wrappedValue) else {
            return
        }
        await addressFollowingFetcher.unFollow(address, credential: credential)
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

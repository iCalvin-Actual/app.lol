//
//  AddressSummaryFetchers.swift
//  omgui
//
//  Created by Calvin Chestnut on 7/29/24.
//

import Blackbird
import Combine
import Foundation
import SwiftUI

@Observable
@MainActor
class AddressSummaryFetcher: Request {
    
    let addressName: AddressName
    let addressBook: AddressBook
    
    var url: URL?
    var registered: Date?
    
    var statuses: [String: StatusFetcher] = [:]
    var purls: [String: AddressPURLFetcher] = [:]
    var pastes: [String: AddressPasteFetcher] = [:]
    
    let profileFetcher: AddressProfilePageFetcher
    let nowFetcher: AddressNowPageFetcher
    
    let iconFetcher: AddressIconFetcher
    let purlFetcher: AddressPURLsFetcher
    let pasteFetcher: AddressPasteBinFetcher
    let statusFetcher: StatusLogFetcher
    let bioFetcher: AddressBioFetcher
    
    let followingFetcher: AddressFollowingFetcher
    let followersFetcher: AddressFollowersFetcher
    
    override var requestNeeded: Bool {
        loaded == nil
    }
    
    init(
        name: AddressName,
        addressBook: AddressBook
    ) {
        self.addressBook = addressBook
        self.addressName = name
        let isMine = addressBook.mine.contains(name)
        let credential: APICredential? = isMine ? addressBook.auth : nil
        self.iconFetcher = .init(address: name)
        self.bioFetcher = .init(address: name)
        self.statusFetcher = .init(addresses: [name], addressBook: addressBook)
        
        self.followingFetcher = .init(address: name, credential: credential)
        self.followersFetcher = .init(address: name, credential: credential)
        
        self.profileFetcher = .init(addressName: name)
        self.nowFetcher = .init(addressName: name)
        
        self.purlFetcher = .init(name: name, credential: credential, addressBook: addressBook)
        self.pasteFetcher = .init(name: name, credential: credential, addressBook: addressBook)
        
        super.init()
    }
    
    override func throwingRequest() async throws {
        let addressName = self.addressName
        guard !addressName.isEmpty else {
            return
        }
        
        Task { [
            weak iconFetcher,
            weak bioFetcher,
            weak profileFetcher,
            weak nowFetcher,
            weak followingFetcher,
            weak followersFetcher,
            weak pasteFetcher,
            weak statusFetcher,
            weak purlFetcher
        ] in
            async let icon: Void = iconFetcher?.updateIfNeeded() ?? {}()
            async let bio: Void = bioFetcher?.updateIfNeeded() ?? {}()
            async let profile: Void = profileFetcher?.updateIfNeeded() ?? {}()
            async let now: Void = nowFetcher?.updateIfNeeded() ?? {}()
            async let following: Void = followingFetcher?.updateIfNeeded() ?? {}()
            async let followers: Void = followersFetcher?.updateIfNeeded() ?? {}()
            async let paste: Void = pasteFetcher?.updateIfNeeded() ?? {}()
            async let status: Void = statusFetcher?.updateIfNeeded() ?? {}()
            async let purl: Void = purlFetcher?.updateIfNeeded() ?? {}()
            async let info = try AppClient.interface.fetchAddressInfo(addressName)
            let _ = await (icon, bio, purl, paste, status, following, followers, profile, now)
            self.registered = try await info.date
            self.url = try await info.url
        }
    }
    
    func statusFetcher(for id: String) -> StatusFetcher {
        let fetcher = statuses[id] ?? StatusFetcher(id: id, from: addressName)
        statuses[id] = fetcher
        return fetcher
    }
    
    func purlFetcher(for id: String) -> AddressPURLFetcher {
        let credential = addressBook.mine.contains(addressName) ? addressBook.auth : nil
        let fetcher = purls[id] ?? AddressPURLFetcher(name: addressName, title: id, credential: credential)
        fetcher.configure(credential: credential)
        purls[id] = fetcher
        return fetcher
    }
    
    func pasteFetcher(for id: String) -> AddressPasteFetcher {
        let credential = addressBook.mine.contains(addressName) ? addressBook.auth : nil
        let fetcher = pastes[id] ?? AddressPasteFetcher(name: addressName, title: id, credential: credential)
        fetcher.configure(credential: credential)
        pastes[id] = fetcher
        return fetcher
    }
}


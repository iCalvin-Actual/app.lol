//
//  AddressSummaryDataFetchers.swift
//  omgui
//
//  Created by Calvin Chestnut on 7/29/24.
//

import Blackbird
import Combine
import Foundation
import SwiftUI

class AddressSummaryDataFetcher: DataFetcher {
    
    let addressName: AddressName
    var addressBook: AddressBook
    
    var url: URL?
    var registered: Date?
    
    var statuses: [String: StatusDataFetcher] = [:]
    var purls: [String: AddressPURLDataFetcher] = [:]
    var pastes: [String: AddressPasteDataFetcher] = [:]
    
    @MainActor
    lazy var profileFetcher: AddressProfilePageDataFetcher? = {
        .init(addressName: addressName)
    }()
    @MainActor
    lazy var nowFetcher: AddressNowPageDataFetcher? = {
        .init(addressName: addressName)
    }()
    
    var iconFetcher: AddressIconDataFetcher
    var purlFetcher: AddressPURLsDataFetcher
    var pasteFetcher: AddressPasteBinDataFetcher
    var statusFetcher: StatusLogDataFetcher
    var bioFetcher: AddressBioDataFetcher
    
    var followingFetcher: AddressFollowingDataFetcher
    var followersFetcher: AddressFollowersDataFetcher
    
    override var requestNeeded: Bool {
        loaded == nil && registered == nil
    }
    
    init(
        name: AddressName,
        addressBook: AddressBook,
        interface: DataInterface
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
        
        self.purlFetcher = .init(name: name, credential: credential, addressBook: addressBook)
        self.pasteFetcher = .init(name: name, credential: credential, addressBook: addressBook)
        
        super.init()
    }
    
    @MainActor
    func configure(addressBook: AddressBook, _ automation: AutomationPreferences = .init()) {
        guard addressBook != self.addressBook else { return }
        self.addressBook = addressBook
        let credential: APICredential? = addressBook.auth
        
        statusFetcher.configure(addressBook: addressBook)
        
        purlFetcher.configure(credential)
        pasteFetcher.configure(credential: credential)
        
        super.configure(automation)
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
    
    func statusFetcher(for id: String) -> StatusDataFetcher {
        let fetcher = statuses[id] ?? StatusDataFetcher(id: id, from: addressName)
        statuses[id] = fetcher
        return fetcher
    }
    
    func purlFetcher(for id: String) -> AddressPURLDataFetcher {
        let credential = addressBook.mine.contains(addressName) ? addressBook.auth : nil
        let fetcher = purls[id] ?? AddressPURLDataFetcher(name: addressName, title: id, credential: credential)
        fetcher.configure(credential: credential)
        purls[id] = fetcher
        return fetcher
    }
    
    func pasteFetcher(for id: String) -> AddressPasteDataFetcher {
        let credential = addressBook.mine.contains(addressName) ? addressBook.auth : nil
        let fetcher = pastes[id] ?? AddressPasteDataFetcher(name: addressName, title: id, credential: credential)
        fetcher.configure(credential: credential)
        pastes[id] = fetcher
        return fetcher
    }
}

class AddressPrivateSummaryDataFetcher: AddressSummaryDataFetcher {
    
    var blockedFetcher: AddressBlockListDataFetcher
    
    override init(
        name: AddressName,
        addressBook: AddressBook,
        interface: DataInterface
    ) {
        self.blockedFetcher = .init(address: name, credential: addressBook.auth)
        
//        self.profilePoster = .init(
//            name,
//            draftItem: .init(
//                address: name,
//                content: "",
//                publish: true
//            ),
//            interface: interface,
//            credential: credential
//        )!
//        self.nowPoster = .init(
//            name,
//            draftItem: .init(
//                address: name,
//                content: "",
//                listed: true
//            ),
//            interface: interface,
//            credential: credential
//        )!
        
        super.init(name: name, addressBook: addressBook, interface: interface)
    }
    
    override func configure(addressBook: AddressBook, _ automation: AutomationPreferences = .init()) {
        guard self.addressBook != addressBook else { return }
        self.addressBook = addressBook
        let credential = addressBook.mine.contains(addressName) ? addressBook.auth : nil
        purlFetcher.configure(credential)
        pasteFetcher.configure(credential: credential)
        super.configure(addressBook: addressBook, automation)
    }
    
    override func perform() async {
        guard !addressName.isEmpty else {
            return
        }
        await blockedFetcher.perform()
        await super.perform()
    }
}


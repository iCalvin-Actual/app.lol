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
    
    @Published var url: URL?
    @Published var registered: Date?
    
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
    
    @Published var iconFetcher: AddressIconDataFetcher
    @Published var purlFetcher: AddressPURLsDataFetcher
    @Published var pasteFetcher: AddressPasteBinDataFetcher
    @Published var statusFetcher: StatusLogDataFetcher
    @Published var bioFetcher: AddressBioDataFetcher
    
    @Published var followingFetcher: AddressFollowingDataFetcher
    @Published var followersFetcher: AddressFollowersDataFetcher
    
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
        
        await iconFetcher.updateIfNeeded()
        await bioFetcher.updateIfNeeded()
        await purlFetcher.updateIfNeeded()
        await pasteFetcher.updateIfNeeded()
        await statusFetcher.updateIfNeeded()
        await followingFetcher.updateIfNeeded()
        await followersFetcher.updateIfNeeded()
        await profileFetcher?.updateIfNeeded()
        await nowFetcher?.updateIfNeeded()
        async let info = try AppClient.interface.fetchAddressInfo(addressName)
        
        registered = try await info.date
        url = try await info.url
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
    
    @Published
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


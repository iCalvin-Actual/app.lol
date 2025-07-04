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
    
    let addressBook: AddressBook
    let database: Blackbird.Database
    
    var addressName: AddressName
    
    var verified: Bool?
    var url: URL?
    var registered: Date?
    
    var iconURL: URL? {
        addressName.addressIconURL
    }
    
    var statuses: [String: StatusDataFetcher] = [:]
    var purls: [String: AddressPURLDataFetcher] = [:]
    var pastes: [String: AddressPasteDataFetcher] = [:]
    
    var iconFetcher: AddressIconDataFetcher
    var profileFetcher: AddressProfilePageDataFetcher
    var nowFetcher: AddressNowPageDataFetcher
    var purlFetcher: AddressPURLsDataFetcher
    var pasteFetcher: AddressPasteBinDataFetcher
    var statusFetcher: StatusLogDataFetcher
    var bioFetcher: AddressBioDataFetcher
    var markdownFetcher: ProfileMarkdownDataFetcher
    
    var followingFetcher: AddressFollowingDataFetcher
    var followersFetcher: AddressFollowersDataFetcher
    
    override var requestNeeded: Bool {
        loaded == nil && registered == nil
    }
    
    init(
        name: AddressName,
        addressBook: AddressBook,
        interface: DataInterface,
        database: Blackbird.Database
    ) {
        self.addressBook = addressBook
        self.database = database
        self.addressName = name
        let isMine = addressBook.myAddresses.contains(name)
        let credential: APICredential? = isMine ? addressBook.apiKey : nil
        self.iconFetcher = .init(address: name, interface: interface, db: database)
        self.profileFetcher = .init(addressName: name, interface: interface, db: database)
        self.nowFetcher = .init(addressName: name, interface: interface, db: database)
        self.purlFetcher = .init(name: name, credential: credential, addressBook: addressBook, interface: interface, db: database)
        self.pasteFetcher = .init(name: name, credential: credential, addressBook: addressBook, interface: interface, db: database)
        self.statusFetcher = .init(addresses: [name], addressBook: addressBook, interface: interface, db: database)
        self.bioFetcher = .init(address: name, interface: interface)
        self.followingFetcher = .init(address: name, credential: credential, interface: interface)
        self.followersFetcher = .init(address: name, credential: credential, interface: interface)
        if let credential {
            self.markdownFetcher = .init(name: name, credential: credential, interface: interface, db: database)
        } else {
            self.markdownFetcher = .init(name: "", credential: "", interface: interface, db: database)
        }
        
        super.init(interface: interface)
    }
    
    func configure(name: AddressName, _ automation: AutomationPreferences = .init()) {
        self.addressName = name
        
        let credential: APICredential? = addressBook.apiKey
        self.iconFetcher = .init(address: name, interface: interface, db: database)
        self.profileFetcher = .init(addressName: name, interface: interface, db: database)
        self.nowFetcher = .init(addressName: name, interface: interface, db: database)
        self.purlFetcher = .init(name: name, credential: credential, addressBook: addressBook, interface: interface, db: database)
        self.pasteFetcher = .init(name: name, credential: credential, addressBook: addressBook, interface: interface, db: database)
        self.statusFetcher = .init(addresses: [name], addressBook: addressBook, interface: interface, db: database)
        self.bioFetcher = .init(address: name, interface: interface)
        self.followingFetcher = .init(address: name, credential: credential, interface: interface)
        self.followersFetcher = .init(address: name, credential: credential, interface: interface)
        self.markdownFetcher = .init(name: name, credential: addressBook.apiKey, interface: interface, db: database)
        
        super.configure(automation)
    }
    
    override func throwingRequest() async throws {
        
        guard !addressName.isEmpty else {
            return
        }
        
        Task { @MainActor [iconFetcher, profileFetcher, nowFetcher, purlFetcher, pasteFetcher, statusFetcher, bioFetcher, followingFetcher] in
            await iconFetcher.updateIfNeeded()
            await bioFetcher.updateIfNeeded()
            await profileFetcher.updateIfNeeded()
            await markdownFetcher.updateIfNeeded()
            await nowFetcher.updateIfNeeded()
            await purlFetcher.updateIfNeeded()
            await pasteFetcher.updateIfNeeded()
            await statusFetcher.updateIfNeeded()
            await followingFetcher.updateIfNeeded()
            await followersFetcher.updateIfNeeded()
        }
        
        let info = try await interface.fetchAddressInfo(addressName)
        self.verified = false
        self.registered = info.date
        self.url = info.url
    }
    
    func statusFetcher(for id: String) -> StatusDataFetcher {
        guard let fetcher = statuses[id] else {
            let newFetcher = StatusDataFetcher(id: id, from: addressName, interface: interface, db: database)
            statuses[id] = newFetcher
            return newFetcher
        }
        return fetcher
    }
    
    func purlFetcher(for id: String) -> AddressPURLDataFetcher {
        guard let fetcher = purls[id] else {
            let newFetcher = AddressPURLDataFetcher(name: addressName, title: id, credential: addressBook.credential(for: addressName), interface: interface, db: database)
            purls[id] = newFetcher
            return newFetcher
        }
        return fetcher
    }
    
    func pasteFetcher(for id: String) -> AddressPasteDataFetcher {
        guard let fetcher = pastes[id] else {
            let newFetcher = AddressPasteDataFetcher(name: addressName, title: id, credential: addressBook.credential(for: addressName), interface: interface, db: database)
            pastes[id] = newFetcher
            return newFetcher
        }
        return fetcher
    }
}

class AddressPrivateSummaryDataFetcher: AddressSummaryDataFetcher {
    
    var blockedFetcher: AddressBlockListDataFetcher
    
    override init(
        name: AddressName,
        addressBook: AddressBook,
        interface: DataInterface,
        database: Blackbird.Database
    ) {
        self.blockedFetcher = .init(address: name, credential: addressBook.apiKey, interface: interface)
        
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
        
        super.init(name: name, addressBook: addressBook, interface: interface, database: database)
        
        self.profileFetcher = .init(addressName: addressName, interface: interface, db: database)
        self.followingFetcher = .init(address: addressName, credential: addressBook.apiKey, interface: interface)
        
        self.purlFetcher = .init(name: addressName, credential: addressBook.apiKey, addressBook: addressBook, interface: interface, db: database)
        self.pasteFetcher = .init(name: addressName, credential: addressBook.apiKey, addressBook: addressBook, interface: interface, db: database)
    }
    
    override func perform() async {
        guard !addressName.isEmpty else {
            return
        }
        await blockedFetcher.perform()
        await super.perform()
    }
}


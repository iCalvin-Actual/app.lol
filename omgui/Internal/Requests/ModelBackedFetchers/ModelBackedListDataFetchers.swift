//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 7/29/24.
//

import Blackbird
import Foundation
import SwiftUI


class GlobalAddressDirectoryFetcher: GlobalListDataFetcher<AddressModel> {
    @MainActor
    override func throwingRequest() async throws {
        let directory = try await interface.fetchAddressDirectory()
        let listItems = directory.map({ AddressModel(name: $0) })
        
        for model in listItems {
            try await model.write(to: db)
        }
    }
}
class GlobalNowGardenFetcher: GlobalListDataFetcher<NowListing> {
    @MainActor
    override func throwingRequest() async throws {
        let garden = try await interface.fetchNowGarden()
        
        for model in garden {
            try await model.write(to: db)
        }
    }
}
class GlobalStatusLogFetcher: GlobalListDataFetcher<StatusModel> {
    @MainActor
    override func throwingRequest() async throws {
        let statusLog = try await interface.fetchCompleteStatusLog()
        for model in statusLog {
            try await model.write(to: db)
        }
    }
}
class AppSupportFetcher: AddressPasteDataFetcher {
    init() {
        super.init(name: "app", title: "support")
    }
}
typealias AppLatestFetcher = AddressNowPageDataFetcher
extension AppLatestFetcher {
    static func `init`(interface: any DataInterface, db: Blackbird.Database) -> AppLatestFetcher {
        .init(addressName: "app")
    }
}
class AddressDirectoryDataFetcher: ModelBackedListDataFetcher<AddressModel> {
    override var title: String { "omg.lol/" }
    
    override func fetchRemote() async throws -> Int {
        items.hashValue
    }
    
    func configure(addressBook: AddressBook, _ automation: AutomationPreferences = .init()) {
        if self.addressBook != addressBook {
            results = []
        }
        self.addressBook = addressBook
        super.configure(automation)
    }
}
class AccountAddressDataFetcher: DataBackedListDataFetcher<AddressModel> {
    override var title: String {
        "my addresses"
    }
    private var credential: String
    
    @AppStorage("lol.cache.myAddresses")
    var localAddressesCache: String = ""
    
    var myAddresses: [AddressName] {
        get {
            let split = localAddressesCache.split(separator: "&&&")
            return split.map({ String($0) })
        }
        set {
            localAddressesCache = Array(Set(newValue)).joined(separator: "&&&")
        }
    }
    
    init(credential: APICredential) {
        self.credential = credential
        super.init()
    }
    
    func configure(credential: APICredential, _ automation: AutomationPreferences = .init()) {
        if self.credential != credential {
            self.credential = credential
            super.configure(automation)
        }
    }
    
    @MainActor
    override func throwingRequest() async throws {
        let credential = credential
        guard !credential.isEmpty else {
            results = []
            localAddressesCache = ""
            return
        }
        let results = try await interface.fetchAccountAddresses(credential).map({ AddressModel(name: $0) })
        
        self.results = results
        localAddressesCache = Array(Set(results.map({ $0.addressName }))).joined(separator: "&&&")
    }
    
    func clear() {
        myAddresses = []
    }
}

class AddressFollowingDataFetcher: DataBackedListDataFetcher<AddressModel> {
    var address: AddressName
    var credential: APICredential?
    
    override var title: String {
        "following"
    }
    
    init(address: AddressName, credential: APICredential?) {
        self.address = address
        self.credential = credential
        super.init()
    }
    
    func configure(address: AddressName, credential: APICredential?, _ automation: AutomationPreferences = .init()) {
        if self.address != address {
            results = []
        }
        self.address = address
        self.credential = credential
        super.configure(automation)
    }
    
    @MainActor
    override func throwingRequest() async throws {
        guard !address.isEmpty else {
            results = []
            return
        }
        let fetched = try await interface.fetchAddressFollowing(address).map({ AddressModel(name: $0) })
        self.results = fetched
    }
    
    @MainActor
    func follow(_ toFollow: AddressName, credential: APICredential) async {
        do {
            try await interface.followAddress(toFollow, from: address, credential: credential)
            self.results.append(.init(name: toFollow))
        } catch {
            if error.localizedDescription.contains("You're already following"), !self.results.contains(where: { $0.addressName == toFollow }) {
                self.results.append(.init(name: toFollow))
            }
        }
    }
    
    @MainActor
    func unFollow(_ toRemove: AddressName, credential: APICredential) async {
        do {
            try await interface.unfollowAddress(toRemove, from: address, credential: credential)
            self.results.removeAll(where: { $0.addressName == toRemove })
        } catch {
            if error.localizedDescription.contains("You're not following"), self.results.contains(where: { $0.addressName == toRemove }) {
                self.results.removeAll(where: { $0.addressName == toRemove })
            }
        }
    }
}

class AddressFollowersDataFetcher: DataBackedListDataFetcher<AddressModel> {
    var address: AddressName
    var credential: APICredential?
    
    override var title: String {
        "followers"
    }
    
    init(address: AddressName, credential: APICredential?) {
        self.address = address
        self.credential = credential
        super.init()
    }
    
    func configure(address: AddressName, credential: APICredential?, _ automation: AutomationPreferences = .init()) {
        if self.address != address {
            results = []
        }
        self.address = address
        self.credential = credential
        super.configure(automation)
    }
    
    @MainActor
    override func throwingRequest() async throws {
        guard !address.isEmpty else {
            return
        }
        
        do {
            let results = try await interface.fetchAddressFollowers(address).map({ AddressModel(name: $0) })
            self.results = results
        } catch {
            throw error
        }
    }
}

class AddressBlockListDataFetcher: DataBackedListDataFetcher<AddressModel> {
    var address: AddressName
    var credential: APICredential?
    
    override var title: String {
        "blocked from \(address)"
    }
    
    init(address: AddressName, credential: APICredential?, automation: AutomationPreferences = .init()) {
        self.address = address
        self.credential = credential
        super.init()
    }
    
    func configure(address: AddressName, credential: APICredential?, _ automation: AutomationPreferences = .init()) {
        if self.address != address {
            results = []
        }
        self.address = address
        self.credential = credential
        super.configure(automation)
    }
    
    override func throwingRequest() async throws {
        
        guard !address.isEmpty else {
            return
        }
        let address = address
        let credential = credential
        let pastes = try await interface.fetchAddressPastes(address, credential: credential)
        guard let blocked = pastes.first(where: { $0.name == "app.lol.blocked" }) else {
            return
        }
        self.results = blocked.content.components(separatedBy: .newlines).map({ String($0) }).filter({ !$0.isEmpty }).map({ AddressModel(name: $0) })
    }
    
    func block(_ toBlock: AddressName, credential: APICredential) async {
        loading = true
        let newValue = Array(Set(self.results.map({ $0.addressName }) + [toBlock]))
        let newContent = newValue.joined(separator: "\n")
        let draft = PasteModel.Draft(
            address: address,
            name: "app.lol.blocked",
            content: newContent,
            listed: false
        )
        let address = address
        let credential = credential
        let _ = try? await self.interface.savePaste(draft, to: address, credential: credential)
        await self.handleItems(newValue)
        
    }
    
    func unBlock(_ toUnblock: AddressName, credential: APICredential) async {
        loading = true
        let newValue = results.map({ $0.addressName }).filter({ $0 != toUnblock })
        let newContent = newValue.joined(separator: "\n")
        let draft = PasteModel.Draft(
            address: address,
            name: "app.lol.blocked",
            content: newContent,
            listed: false
        )
        let address = address
        let credential = credential
        let _ = try? await interface.savePaste(draft, to: address, credential: credential)
        await self.handleItems(newValue)
    }
    
    private func handleItems(_ addresses: [AddressName]) async {
        self.results = addresses.map({ AddressModel(name: $0) })
        loaded = .init()
        await fetchFinished()
    }
}

class NowGardenDataFetcher: ModelBackedListDataFetcher<NowListing> {
    override var title: String {
        "now.garden🌷"
    }
    
    override func fetchRemote() async throws -> Int {
        items.hashValue
    }
    
    func configure(addressBook: AddressBook, automation: AutomationPreferences = .init()) {
        if self.addressBook != addressBook {
            results = []
        }
        self.addressBook = addressBook
        super.configure(automation)
    }
}

class AddressPasteBinDataFetcher: ModelBackedListDataFetcher<PasteModel> {
    let addressName: AddressName
    var credential: APICredential?
    
    init(name: AddressName, credential: APICredential?, addressBook: AddressBook) {
        self.addressName = name
        super.init(addressBook: addressBook, filters: [.from(name)])
    }
    
    func configure(credential: APICredential?, _ automation: AutomationPreferences = .init()) {
        self.credential = credential
        super.configure(automation)
    }
    
    override func fetchRemote() async throws -> Int {
        guard !addressName.isEmpty else {
            return 0
        }
        let pastes = try await interface.fetchAddressPastes(addressName, credential: credential).filter {
            guard $0.addressName == "app" && addressBook.mine.contains($0.addressName) else {
                return true
            }
            return $0.name != "app.lol.blocked"
        }
        let db = db
        for model in pastes {
            try await model.write(to: db)
        }
        return pastes.hashValue
    }
}

class AddressPURLsDataFetcher: ModelBackedListDataFetcher<PURLModel> {
    let addressName: AddressName
    var credential: APICredential?
    
    init(name: AddressName, purls: [PURLModel] = [], credential: APICredential?, addressBook: AddressBook) {
        self.addressName = name
        self.credential = credential
        super.init(addressBook: addressBook, filters: [.from(name)])
    }
    
    func configure(_ newValue: APICredential?, _ automation: AutomationPreferences = .init()) {
        if credential != newValue {
            credential = newValue
        }
        super.configure(automation)
    }
    
    override func fetchRemote() async throws -> Int {
        guard !addressName.isEmpty else {
            return 0
        }
        let purls = try await interface.fetchAddressPURLs(addressName, credential: credential)
        let db = db
        for model in purls {
            try await model.write(to: db)
        }
        return purls.hashValue
    }
}

class StatusLogDataFetcher: ModelBackedListDataFetcher<StatusModel> {
    let displayTitle: String
    let addresses: [AddressName]
    
    override var title: String { displayTitle }
    
    init(title: String? = nil, addresses: [AddressName] = [], addressBook: AddressBook) {
        self.displayTitle = title ?? {
            switch addresses.count {
            case 0:
                return "status.lol/"
            case 1:
                return ""
            default:
                return "statuses"
            }
        }()
        self.addresses = addresses
        super.init(addressBook: addressBook, filters: addresses.isEmpty ? [] : [.fromOneOf(addresses)])
    }
    
    override func fetchRemote() async throws -> Int {
        defer {
            nextPage = 0
        }
        if addresses.isEmpty {
            let statuses = try await interface.fetchStatusLog()
            for model in statuses {
                try await model.write(to: db)
            }
            return statuses.hashValue
        } else {
            let statuses = try await interface.fetchAddressStatuses(addresses: addresses)
            for model in statuses {
                try await model.write(to: db)
            }
            return statuses.hashValue
        }
    }
    
    func configure(addressBook: AddressBook, _ automation: AutomationPreferences = .init()) {
        if self.addressBook != addressBook {
            results = []
        }
        self.addressBook = addressBook
        self.loading = true
        self.loaded = .init()
        self.loading = false
    }
}

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
    // Persist the last successful run date as an ISO8601 string in AppStorage.
    // Using a unique key to avoid collisions.
    @AppStorage("lol.lastFetch")
    private var lastFetch: String = ""

    @MainActor
    override func throwingRequest() async throws {
        // Decode last run date if present
        let formatter = ISO8601DateFormatter()
        let calendar = Calendar.current
        if let lastRun = formatter.date(from: lastFetch),
           calendar.isDateInToday(lastRun) {
            // Already ran today; skip work
            return
        }

        let garden = try await interface.fetchNowGarden()
        
        for model in garden {
            try await model.write(to: db)
        }
        
        let directory = try await interface.fetchAddressDirectory()
        
        for address in directory {
            
            print("Directory: Prepping model for \(address)")
            do {
                var model = try await interface.fetchAddressInfo(address)
                print("Directory: Fetching now for \(address)")
                if let listing = try await NowListing.read(from: db, id: address) {
                    let url = URL(string: String(listing.url.dropLast("/now".count)))
                    model.url = url
                }
                print("Directory: Writing model for \(address)")
                try await model.write(to: db)
            } catch {
                print("Directory: Fallback option for \(address)")
                try await AddressModel(name: address, url: URL(string: "https://\(address).omg.lol"), date: .distantPast).write(to: db)
            }
        }

        // Mark successful completion time
        lastFetch = formatter.string(from: Date())
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
    
    func configure(addressBook: AddressBook? = nil, filters: [FilterOption]? = nil, _ automation: AutomationPreferences = .init()) {
        if self.addressBook != addressBook {
            results = []
        }
        if let filters {
            self.filters = filters
        }
        if let addressBook {
            self.addressBook = addressBook
        }
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
        guard !credential.isEmpty else {
            results = []
            localAddressesCache = ""
            return
        }
        
        var results: [AddressModel] = []
        let addresses = try await interface.fetchAccountAddresses(credential)
        for address in addresses {
            results.append(try await interface.fetchAddressInfo(address))
        }
        
        self.results = results.sorted(with: .alphabet)
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
        "🌷 now.lol"
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
    
    override var title: String {
        "Pastebin"
    }
    
    init(name: AddressName, credential: APICredential?, addressBook: AddressBook, filters: [FilterOption]? = nil) {
        self.addressName = name
        super.init(addressBook: addressBook, filters: filters ?? [.from(name)])
    }
    
    func configure(credential: APICredential?, _ automation: AutomationPreferences = .init()) {
        self.credential = credential
        super.configure(automation)
    }
    
    func configure(addressBook: AddressBook? = nil, filters: [FilterOption]? = nil, _ automation: AutomationPreferences = .init()) {
        if self.addressBook != addressBook {
            results = []
        }
        if let filters {
            self.filters = filters
        }
        if let addressBook {
            self.addressBook = addressBook
        }
        super.configure(automation)
    }
    
    override func fetchRemote() async throws -> Int {
        guard !addressName.isEmpty else {
            return 0
        }
        let pastes = try await interface.fetchAddressPastes(addressName, credential: credential).filter {
            $0.name != "app.lol.blocked"
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
    
    override var title: String {
        "PURLs"
    }
    
    init(name: AddressName, purls: [PURLModel] = [], credential: APICredential?, addressBook: AddressBook, filters: [FilterOption]? = nil) {
        self.addressName = name
        self.credential = credential
        super.init(addressBook: addressBook, filters: filters ?? [.from(name)])
    }
    
    func configure(_ newValue: APICredential?, _ automation: AutomationPreferences = .init()) {
        if credential != newValue {
            credential = newValue
        }
        super.configure(automation)
    }
    
    func configure(addressBook: AddressBook? = nil, filters: [FilterOption]? = nil, _ automation: AutomationPreferences = .init()) {
        if self.addressBook != addressBook {
            results = []
        }
        if let filters {
            self.filters = filters
        }
        if let addressBook {
            self.addressBook = addressBook
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
    
    override var title: String {
        displayTitle
    }
    
    init(title: String? = nil, addresses: [AddressName] = [], addressBook: AddressBook, limit: Int = 42) {
        self.displayTitle = title ?? {
            switch addresses.count {
            case 0:
                return "💬 status.lol"
            default:
                return "status.lol"
                
            }
        }()
        self.addresses = addresses
        super.init(addressBook: addressBook, limit: limit, filters: addresses.isEmpty ? [] : [.fromOneOf(addresses)])
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
    
    func configure(addressBook: AddressBook? = nil, filters: [FilterOption]? = nil, _ automation: AutomationPreferences = .init()) {
        if self.addressBook != addressBook {
            results = []
        }
        if let addressBook {
            self.addressBook = addressBook
        }
        if let filters {
            self.filters = filters
        }
        self.loading = true
        self.loaded = .init()
        self.loading = false
    }
}


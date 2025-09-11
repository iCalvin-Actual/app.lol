//
//  ModelBackedListFetchers.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/11/25.
//

import Foundation

class AddressDirectoryFetcher: ModelBackedListFetcher<AddressModel> {
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

class NowGardenFetcher: ModelBackedListFetcher<NowListing> {
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

class AddressPasteBinFetcher: ModelBackedListFetcher<PasteModel> {
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

class AddressPURLsFetcher: ModelBackedListFetcher<PURLModel> {
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

class StatusLogFetcher: ModelBackedListFetcher<StatusModel> {
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

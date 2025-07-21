//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 7/29/24.
//

import Blackbird
import Combine

class BackedDataFetcher: Request {
    let db: Blackbird.Database
    
    var lastHash: Int?
    
    init(interface: DataInterface, db: Blackbird.Database, automation: AutomationPreferences = .init()) {
        self.db = db
        super.init(interface: interface, automation: automation)
    }
    
    override func throwingRequest() async throws {
        try await fetchModels()
        let nextHash = try await fetchRemote()
        guard nextHash != lastHash else {
            return
        }
        lastHash = nextHash
        try await fetchModels()
    }
    
    @MainActor
    func fetchModels() async throws {
    }
    
    @MainActor
    func fetchRemote() async throws -> Int {
        0
    }
}

class ModelBackedDataFetcher<M: BlackbirdModel>: BackedDataFetcher {
    @Published
    var result: M?
    
    override var requestNeeded: Bool {
        result == nil && super.requestNeeded
    }
    
    var noContent: Bool {
        guard !loading else {
            return false
        }
        return loaded != nil && result == nil
    }
}

typealias ModelBackedListable = BlackbirdListable & Listable

class GlobalListDataFetcher<T: ModelBackedListable>: ListFetcher<T> {
    let db: Blackbird.Database
    
    init(interface: DataInterface, db: Blackbird.Database, automation: AutomationPreferences = .init()) {
        self.db = db
        super.init(items: [], interface: interface, limit: 42, filters: [], sort: T.defaultSort, automation: automation)
    }
}

class ModelBackedListDataFetcher<T: ModelBackedListable>: ListFetcher<T> {
    
    var addressBook: AddressBook.Scribbled?
    let db: Blackbird.Database
    
    var lastHash: Int?
    
    init(addressBook: AddressBook.Scribbled?, interface: DataInterface, db: Blackbird.Database, limit: Int = 42, filters: [FilterOption] = .everyone, sort: Sort = T.defaultSort, automation: AutomationPreferences = .init()) {
        self.addressBook = addressBook
        self.db = db
        super.init(items: [], interface: interface, limit: limit, filters: filters, sort: sort, automation: automation)
    }
    
    @MainActor
    override func throwingRequest() async throws {
        try await fetchModels()
        let nextHash = try await fetchRemote()
        
        guard lastHash != nextHash else {
            return
        }
        lastHash = nextHash
        try await fetchModels()
    }
    
    @MainActor
    override func fetchNextPageIfNeeded() {
        if loaded == nil {
            Task { [weak self] in
                await self?.updateIfNeeded()
            }
        } else if !loading {
            Task { [weak self] in
                try? await self?.fetchModels()
            }
        }
    }
    
    // must override and return hash value
    @MainActor
    func fetchRemote() async throws -> Int {
        return items.hashValue
    }
    
    @MainActor
    func fetchModels() async throws {
        guard let nextPage, let addressBook else {
            return
        }
        var nextResults = try await T.read(
            from: db,
            matching: filters.asQuery(matchingAgainst: addressBook),
            orderBy: sort.asClause(),
            limit: limit,
            offset: (nextPage * limit)
        )
        var oldResults = nextPage == 0 ? [] : results
        if nextResults.count == limit {
            self.nextPage = nextPage + 1
        } else if nextResults.count != 0 || (loaded != nil && (nextResults + oldResults).count == 0) {
            self.nextPage = nil
        }
        if !oldResults.isEmpty {
            results.enumerated().forEach { (offset, element) in
                if let matchingInNext = nextResults.enumerated().first(where: { $0.element == element }) {
                    oldResults.remove(at: offset)
                    oldResults.insert(matchingInNext.element, at: offset)
                    nextResults.remove(at: matchingInNext.offset)
                }
            }
        }
        results = oldResults + nextResults
    }
}

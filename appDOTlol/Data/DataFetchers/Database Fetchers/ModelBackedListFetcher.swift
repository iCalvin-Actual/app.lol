//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 7/29/24.
//

import Blackbird
import Combine


class ModelBackedListFetcher<T: BlackbirdListable>: ListFetcher<T> {
    
    var addressBook: AddressBook
    let db: Blackbird.Database
    
    var lastHash: Int?
    
    init(addressBook: AddressBook, limit: Int = 42, filters: [FilterOption] = .everyone, sort: Sort = T.defaultSort, automation: AutomationPreferences = .init()) {
        self.addressBook = addressBook
        self.db = AppClient.database
        super.init(items: [], limit: limit, filters: filters, sort: sort, automation: automation)
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
    
    override func refresh() {
        loaded = nil
        nextPage = Self.nextPage
        Task { [weak self] in
            async let _ = self?.updateIfNeeded(forceReload: true)
        }
    }
    
    @MainActor
    override func fetchNextPageIfNeeded() {
        if loaded == nil {
            Task { [weak self] in
                let _ = await self?.updateIfNeeded(forceReload: true)
            }
        } else if !loading {
            Task { [weak self] in
                let _ = try? await self?.fetchModels()
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
        guard let nextPage else {
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

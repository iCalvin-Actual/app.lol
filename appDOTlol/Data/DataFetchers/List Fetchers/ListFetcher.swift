//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import AuthenticationServices
import Blackbird
import Combine
import SwiftUI
import Foundation
import os

private let listLevelLogger = Logger(subsystem: "Fetcher", category: "fetcher")

@Observable
class ListFetcher<T: Listable>: Request {
    static var isModelBacked: Bool {
        T.self is any BlackbirdListable.Type
    }
    static var nextPage: Int? {
        Self.isModelBacked ? 0 : nil
    }
    
    var results: [T] = []
    
    var items: Int { results.count }
    var title: String { "" }
    
    let limit: Int
    var nextPage: Int? = ListFetcher<T>.nextPage
    
    var filters: [FilterOption] {
        didSet {
            results = []
            nextPage = Self.nextPage
        }
    }
    var sort: Sort {
        didSet {
            results = []
            nextPage = Self.nextPage
        }
    }
    
    init(items: [T] = [], limit: Int = 42, filters: [FilterOption] = .everyone, sort: Sort = T.defaultSort, automation: AutomationPreferences = .init()) {
        self.results = items
        self.limit = limit
        self.filters = filters
        self.sort = sort
        super.init(automation: automation)
        self.loaded = items.isEmpty ? nil : .init()
    }
    
    var hasContent: Bool {
        !results.isEmpty && loaded != nil
    }
    
    var noContent: Bool {
        guard !loading, loaded != nil else {
            return false
        }
        return results.isEmpty
    }
    
    @MainActor
    func fetchNextPageIfNeeded() {
        Task { [weak self] in
            async let _ = self?.updateIfNeeded()
        }
    }
    
    @MainActor
    func refresh() {
        loaded = nil
        Task { [weak self] in
            async let _ = self?.updateIfNeeded(forceReload: true)
        }
    }
}


class PinnedListFetcher: ListFetcher<AddressModel> {
    @AppStorage("lol.cache.pinned.history", store: .standard)
    private var pinnedAddressesHistory: String = "app"
    var previouslyPinnedAddresses: Set<AddressName> {
        get {
            let split = pinnedAddressesHistory.split(separator: "&&&")
            return Set(split.map({ String($0) }))
        }
        set {
            pinnedAddressesHistory = newValue.sorted().joined(separator: "&&&")
        }
    }
    
    @AppStorage("lol.cache.pinned", store: .standard)
    private var currentlyPinnedAddresses: String = "app&&&adam&&&prami"
    var pinnedAddresses: [AddressName] {
        get {
            let split = currentlyPinnedAddresses.split(separator: "&&&")
            return split.map({ String($0) })
        }
        set {
            currentlyPinnedAddresses = Array(Set(newValue)).joined(separator: "&&&")
        }
    }
    
    override var title: String {
        "pinned"
    }
    
    init(items: [AddressModel] = [], automation: AutomationPreferences = .init()) {
        super.init(items: items, limit: .max, automation: automation)
    }
    
    @MainActor
    override func throwingRequest() async throws {
        results = pinnedAddresses.map({ AddressModel.init(name: $0) })
    }
    
    func isPinned(_ address: AddressName) -> Bool {
        pinnedAddresses.contains(address)
    }
    
    func pin(_ address: AddressName) async {
        pinnedAddresses.append(address)
        await updateIfNeeded(forceReload: true)
    }
    
    func removePin(_ address: AddressName) async {
        pinnedAddresses.removeAll(where: { $0 == address })
        await updateIfNeeded(forceReload: true)
    }
}

class LocalBlockListFetcher: ListFetcher<AddressModel> {
    
    // MARK: No-Account Blocklist
    @AppStorage("lol.cache.blocked", store: .standard)
    private var cachedBlockList: String = ""
    var blockedAddresses: [AddressName] {
        get {
            let split = cachedBlockList.split(separator: "&&&")
            return split.map({ String($0) })
        }
        set {
            cachedBlockList = Array(Set(newValue)).joined(separator: "&&&")
        }
    }
    
    init(automation: AutomationPreferences = .init()) {
        super.init(limit: .max, automation: automation)
        self.results = blockedAddresses.map({ AddressModel.init(name: $0) })
        
    }
    override var title: String {
        "blocked"
    }
    
    @MainActor
    override func throwingRequest() async throws {
        self.results = blockedAddresses.map({ AddressModel.init(name: $0) })
    }
    
    func remove(_ address: AddressName) async {
        blockedAddresses.removeAll(where: { $0 == address })
        await updateIfNeeded(forceReload: true)
    }
    
    func insert(_ address: AddressName) async {
        blockedAddresses.append(address)
        await updateIfNeeded(forceReload: true)
    }
}


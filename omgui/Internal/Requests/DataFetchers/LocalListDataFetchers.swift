//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 7/29/24.
//

import Foundation
import SwiftUI

class PinnedListDataFetcher: DataBackedListDataFetcher<AddressModel> {
    @AppStorage("app.lol.cache.pinned.history", store: .standard)
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
    
    @AppStorage("app.lol.cache.pinned", store: .standard)
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

class LocalBlockListDataFetcher: DataBackedListDataFetcher<AddressModel> {
    
    // MARK: No-Account Blocklist
    @AppStorage("app.lol.cache.blocked", store: .standard)
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
    
    init(interface: DataInterface, automation: AutomationPreferences = .init()) {
        super.init(interface: interface, automation: automation)
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

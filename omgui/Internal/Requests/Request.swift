//
//  Request.swift
//  omgui
//
//  Created by Calvin Chestnut on 7/29/24.
//

import Combine
import Foundation

struct AutomationPreferences {
    var autoLoad: Bool
    var reloadDuration: TimeInterval?
    
    init(_ autoLoad: Bool = true, reloadDuration: TimeInterval? = 60) {
        self.reloadDuration = reloadDuration
        self.autoLoad = autoLoad
    }
}

@MainActor
class Request: ObservableObject {
    
    let interface: DataInterface
    let automation: AutomationPreferences
    
    @Published
    var loaded: Date? = nil
    @Published
    var loading: Bool = false
    
    @Published
    var error: Error?
    
    var requests: [AnyCancellable] = []
    
    var requestNeeded: Bool {
        guard let loaded else {
            return true
        }
        guard let duration = automation.reloadDuration else {
            return false
        }
        return Date().timeIntervalSince(loaded) < duration
    }
    
    init(interface: DataInterface, automation: AutomationPreferences = .init()) {
        self.interface = interface
        self.automation = automation
    }
    
    func configure(_ automation: AutomationPreferences = .init()) {
        self.loaded = nil
        self.loading = false
    }
    
    @MainActor
    func updateIfNeeded(forceReload: Bool = false) async {
        guard !loading else {
            return
        }
        loading = true
        guard forceReload || requestNeeded else {
            print("Not performing on \(self)")
            return
        }
        print("Performing on \(self)")
        await perform()
    }
    
    @MainActor
    func perform() async {
        do {
            try await throwingRequest()
            await fetchFinished()
        } catch {
            print("🚨🚨🚨 Caught error: \(error) in \(self)")
            handle(error)
        }
    }
    
    @MainActor
    func throwingRequest() async throws {
        
    }
    
    @MainActor
    func fetchFinished() async {
        loaded = .init()
        loading = false
    }
    
    @MainActor
    func handle(_ incomingError: Error) {
        loaded = .init()
        loading = false
        error = incomingError
    }
}

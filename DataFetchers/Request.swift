//
//  Request.swift
//  omgui
//
//  Created by Calvin Chestnut on 7/29/24.
//

import Combine
import Foundation
import os

let requestLevelLogger = Logger(subsystem: "Request", category: "lifecycle")

struct AutomationPreferences {
    var autoLoad: Bool
    var reloadDuration: TimeInterval?
    
    init(_ autoLoad: Bool = true, reloadDuration: TimeInterval? = 60) {
        self.reloadDuration = reloadDuration
        self.autoLoad = autoLoad
    }
}

@Observable
class Request {
    
    let interface: OMGInterface
    let automation: AutomationPreferences
    
    var loaded: Date? = nil
    var loading: Bool = false
    
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
    
    deinit {
        requestLevelLogger.debug("Deinit \(String(describing: self))")
    }
    
    init(automation: AutomationPreferences = .init()) {
        self.interface = AppClient.interface
        self.automation = automation
        requestLevelLogger.debug("Init \(String(describing: self))")
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
            requestLevelLogger.debug("Not performing on \(String(describing: self))")
            return
        }
        requestLevelLogger.debug("Performing on \(String(describing: self))")
        await perform()
    }
    
    @MainActor
    func perform() async {
        do {
            try await throwingRequest()
            await fetchFinished()
        } catch {
            requestLevelLogger.error("Caught error: \(String(describing: error)) in \(String(describing: self))")
            handle(error)
        }
    }
    
    @MainActor
    func throwingRequest() async throws {
        
    }
    
    @MainActor
    func fetchFinished() async {
        requestLevelLogger.debug("Finished fetching on \(String(describing: self))")
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


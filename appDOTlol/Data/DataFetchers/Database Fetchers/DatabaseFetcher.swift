//
//  DatabaseFetcher.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/11/25.
//

import Blackbird
import Foundation

@Observable
class DatabaseFetcher<M: BlackbirdModel>: Request {
    let db: Blackbird.Database
    
    var result: M?
    var lastHash: Int?
    
    override var requestNeeded: Bool {
        result == nil || super.requestNeeded
    }
    
    var noContent: Bool {
        guard !loading else {
            return false
        }
        return loaded != nil && result == nil
    }
    
    override init(automation: AutomationPreferences = .init()) {
        self.db = AppClient.database
        super.init(automation: automation)
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

class AddressIconFetcher: DatabaseFetcher<AddressIconModel> {
    let address: AddressName
    
    init(address: AddressName) {
        self.address = address
        super.init()
    }
    
    override func fetchModels() async throws {
        result = try await AddressIconModel.read(from: db, id: address)
    }
    
    override func fetchRemote() async throws -> Int {
        guard let url = address.addressIconURL else {
            return 0
        }
        let response = try await URLSession.shared.data(from: url)
        let model = AddressIconModel(owner: address, data: response.0)
        try await model.write(to: db)
        result = model
        return model.hashValue
    }
}

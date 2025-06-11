//
//  DataFetchers.swift
//  omgui
//
//  Created by Calvin Chestnut on 7/29/24.
//

import Blackbird
import Combine
import Foundation

class URLContentDataFetcher: DataFetcher {
    let url: URL
    
    @Published
    var html: String?
    
    init(url: URL, html: String? = nil, interface: DataInterface) {
        self.url = url
        self.html = html
        super.init(interface: interface)
    }
    
    override func throwingRequest() async throws {
        
        guard url.scheme?.contains("http") ?? false else {
            return
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        self.html = String(data: data, encoding: .utf8)
    }
}

class AddressAvailabilityDataFetcher: DataFetcher {
    
    var address: String
    
    var available: Bool?
    var result: AddressAvailabilityModel?
    
    init(address: AddressName, interface: DataInterface) {
        self.address = address
        super.init(interface: interface)
    }
    
    func fetchAddress(_ address: AddressName) async throws {
        self.available = false
        self.address = address
        await self.updateIfNeeded(forceReload: true)
    }
    
    override func throwingRequest() async throws {
        
        let address = address
        guard !address.isEmpty else {
            return
        }
        let result = try await interface.fetchAddressAvailability(address)
        self.result = result
    }
}

class AddressIconDataFetcher: ModelBackedDataFetcher<AddressIconModel> {
    let address: AddressName
    
    init(address: AddressName, interface: DataInterface, db: Blackbird.Database) {
        self.address = address
        super.init(interface: interface, db: db)
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
        return model.hashValue
    }
}

//
//  AddressAvailabilityFetcher.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/11/25.
//

import Foundation

@Observable
class AddressAvailabilityFetcher: Request {
    
    var address: String
    
    var available: Bool?
    var result: AddressAvailabilityModel?
    
    init(address: AddressName, interface: OMGInterface) {
        self.address = address
        super.init()
    }
    
    func fetchAddress(_ address: AddressName) async throws {
        self.available = nil
        self.address = address
        await self.updateIfNeeded(forceReload: true)
    }
    
    override func throwingRequest() async throws {
        
        let address = address
        guard !address.isEmpty else {
            return
        }
        let result = try await interface.fetchAddressAvailability(address)
        self.available = result.available
        self.result = result
    }
}

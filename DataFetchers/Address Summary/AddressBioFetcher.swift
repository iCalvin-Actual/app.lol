//
//  AddressBioFetcher.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/11/25.
//

import Foundation

@Observable
class AddressBioFetcher: Request {
    let address: AddressName
    
    var bio: AddressSummaryModel?
    
    init(address: AddressName) {
        self.address = address
        super.init()
    }
    
    @MainActor
    override func throwingRequest() async throws {
        self.bio = try await interface.fetchAddressBio(address)
    }
}

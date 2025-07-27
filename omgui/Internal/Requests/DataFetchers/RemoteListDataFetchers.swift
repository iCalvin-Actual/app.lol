//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 7/29/24.
//

import Blackbird
import Foundation

class AddressBioDataFetcher: DataFetcher {
    let address: AddressName
    
    @Published
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


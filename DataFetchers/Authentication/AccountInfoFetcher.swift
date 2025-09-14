//
//  AccountInfoFetcher.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/11/25.
//

import Foundation


class AccountInfoFetcher: Request {
    private let name: String
    private let credential: String
    
    var accountName: String?
    var accountCreated: Date?
    
    override var requestNeeded: Bool {
        accountName == nil && super.requestNeeded
    }
    
    init(address: AddressName, credential: APICredential) {
        self.name = address
        self.credential = credential
        super.init()
    }
    
    override func throwingRequest() async throws {
        
        let address = name
        let credential = credential
        let info = try await interface.fetchAccountInfo(address, credential: credential)
        self.accountName = info?.name
        self.accountCreated = info?.created
    }
    
    var noContent: Bool {
        guard !loading else {
            return false
        }
        return loaded != nil && name.isEmpty
    }
}

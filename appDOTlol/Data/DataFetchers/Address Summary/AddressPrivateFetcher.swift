//
//  AddressPrivateFetcher.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/11/25.
//

import Foundation

class AddressPrivateSummaryFetcher: AddressSummaryFetcher {
    
    let blockedFetcher: AddressBlockListFetcher
    
    override init(
        name: AddressName,
        addressBook: AddressBook
    ) {
        self.blockedFetcher = .init(address: name, credential: addressBook.auth)
        
//        self.profilePoster = .init(
//            name,
//            draftItem: .init(
//                address: name,
//                content: "",
//                publish: true
//            ),
//            interface: interface,
//            credential: credential
//        )!
//        self.nowPoster = .init(
//            name,
//            draftItem: .init(
//                address: name,
//                content: "",
//                listed: true
//            ),
//            interface: interface,
//            credential: credential
//        )!
        
        super.init(name: name, addressBook: addressBook)
    }
    
    override func perform() async {
        guard !addressName.isEmpty else {
            await fetchFinished()
            return
        }
        await super.perform()
    }
    
    override func throwingRequest() async throws {
        await blockedFetcher.perform()
    }
}

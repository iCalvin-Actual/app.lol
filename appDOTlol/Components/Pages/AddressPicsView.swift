//
//  AddressPicsView.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/13/25.
//

import SwiftUI

struct AddressPicsView: View {
    @Environment(\.credentialFetcher) var credential
    
    @State
    var fetcher: PhotoFeedFetcher
    
    init(_ address: AddressName, addressBook: AddressBook) {
        _fetcher = .init(wrappedValue: .init(addresses: [address], addressBook: addressBook))
    }
    
    var body: some View {
        ListView<PicModel>(
            filters: .everyone,
            dataFetcher: fetcher
        )
    }
}

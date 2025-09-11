//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct AddressPastesView: View {
    @Environment(\.credentialFetcher) var credential
    @State
    var fetcher: AddressPasteBinFetcher
    
    init(_ address: AddressName, addressBook: AddressBook) {
        _fetcher = .init(wrappedValue: .init(name: address, credential: "", addressBook: addressBook))
    }
    
    var body: some View {
        ListView<PasteModel>(
            filters: .everyone,
            dataFetcher: fetcher
        )
        .task {
            let auth = credential(fetcher.addressName)
            Task { [weak fetcher] in
                fetcher?.configure(credential: auth)
                await fetcher?.updateIfNeeded()
            }
        }
    }
}

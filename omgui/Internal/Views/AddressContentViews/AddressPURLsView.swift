//
//  File.swift
//
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct AddressPURLsView: View {
    @Environment(\.credentialFetcher) var credential
    
    @StateObject var fetcher: AddressPURLsDataFetcher
    
    init(_ address: AddressName, addressBook: AddressBook) {
        _fetcher = .init(wrappedValue: .init(name: address, credential: nil, addressBook: addressBook))
    }
    
    var body: some View {
        ListView<PURLModel>(
            filters: .everyone,
            dataFetcher: fetcher
        )
        .task { [weak fetcher] in
            guard let fetcher else { return }
            fetcher.configure(credential(fetcher.addressName))
            
        }
    }
}

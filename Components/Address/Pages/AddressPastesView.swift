//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct AddressPastesView: View {
    @Environment(\.addressSummaryFetcher)
        var summaryFetcher
    @Environment(\.credentialFetcher)
        var credentialFetcher
    
    @State var fetcher: AddressPasteBinFetcher = .init(name: "", credential: "", addressBook: .init())
    
    let address: AddressName
    let addressBook: AddressBook
    
    init(_ address: AddressName, addressBook: AddressBook) {
        self.address = address
        self.addressBook = addressBook
    }
    
    var body: some View {
        ListView<PasteModel>(
            filters: .everyone,
            dataFetcher: fetcher
        )
        .task {
            await configureFetcher()
        }
        .onChange(of: addressBook, {
            Task {
                await configureFetcher()
            }
        })
        .onChange(of: address, {
            Task {
                await configureFetcher()
            }
        })
    }
    
    private func configureFetcher() async {
        let newFetcher = summaryFetcher(address)?.pasteFetcher ?? .init(name: address, credential: credentialFetcher(address), addressBook: addressBook)
        await newFetcher.updateIfNeeded()
        self.fetcher = newFetcher
    }
}

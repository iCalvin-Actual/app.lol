//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import Combine
import SwiftUI

struct StatusList: View {
    @Environment(\.addressBook)
        var addressBook
    @Environment(\.addressSummaryFetcher)
        var summaryFetcher
    @Environment(\.credentialFetcher)
        var credentialFetcher
    
    @State
        var fetcher: StatusLogFetcher = .init(addressBook: .init())
    
    let addresses: [AddressName]
    
    init(_ addresses: [AddressName]) {
        self.addresses = addresses
    }
    
    var body: some View {
        ListView<StatusModel>(
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
        .onChange(of: addresses, {
            Task {
                await configureFetcher()
            }
        })
        #if !os(tvOS)
        .toolbarRole(.editor)
        #endif
    }
    
    private func configureFetcher() async {
        if addresses.count == 1, let address = addresses.first, fetcher.addresses != [address] {
            self.fetcher = summaryFetcher(address)?.statusFetcher ?? .init(addresses: [address], addressBook: addressBook)
        } else if addresses.sorted() != fetcher.addresses.sorted() {
            self.fetcher = .init(addresses: addresses, addressBook: addressBook)
        }
        await fetcher.updateIfNeeded()
    }
}

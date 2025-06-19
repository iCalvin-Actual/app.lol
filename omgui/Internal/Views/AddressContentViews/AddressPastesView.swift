//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct AddressPastesView: View {
    @ObservedObject
    var fetcher: AddressPasteBinDataFetcher
    
    var body: some View {
        ListView<PasteModel, EmptyView>(
            filters: .everyone,
            dataFetcher: fetcher
        )
        .toolbar {
            ToolbarItem(placement: .principal) {
                AddressNameView(fetcher.addressName, suffix: "/pastebin")
            }
        }
    }
}

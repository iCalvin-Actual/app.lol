//
//  File.swift
//
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct AddressPURLsView: View {
    @ObservedObject
    var fetcher: AddressPURLsDataFetcher
    
    var body: some View {
        ListView<PURLModel, EmptyView>(
            filters: .everyone,
            dataFetcher: fetcher
        )
    }
}

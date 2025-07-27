//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import Combine
import SwiftUI

struct StatusList: View {
    @Environment(\.horizontalSizeClass)
    var sizeClass
    @Environment(\.addressBook)
    var addressBook
    @Environment(\.credentialFetcher)
    var credential
    @Environment(\.addressSummaryFetcher)
    var summary
    
    @StateObject
    var fetcher: StatusLogDataFetcher
    
    init(_ addresses: [AddressName], addressBook: AddressBook) {
        _fetcher = .init(wrappedValue: .init(addresses: addresses, addressBook: addressBook))
    }
    
    var body: some View {
        ListView<StatusModel, EmptyView>(
            filters: .everyone,
            dataFetcher: fetcher
        )
        .task { [weak fetcher] in
            guard let fetcher else { return }
            fetcher.configure(addressBook: addressBook)
            await fetcher.updateIfNeeded()
        }
        #if !os(tvOS)
        .toolbarRole(.editor)
        #endif
    }
}

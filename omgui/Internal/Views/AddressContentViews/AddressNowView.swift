//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct AddressNowView: View {
    @State
    var fetcher: AddressNowPageDataFetcher
    
    init(_ address: AddressName) {
        _fetcher = .init(wrappedValue: .init(addressName: address))
    }
    
    var body: some View {
        htmlBody
            .onAppear {
                Task { @MainActor [fetcher] in
                    await fetcher.updateIfNeeded()
                }
            }
        #if !os(tvOS)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    if let url = fetcher.result?.shareURLs.first?.content {
                        ShareLink(item: url)
                    }
                }
            }
        #endif
    }
    
    @ViewBuilder
    var htmlBody: some View {
        AddressNowPageView(
            fetcher: fetcher,
            htmlContent: fetcher.result?.html,
            baseURL: nil
        )
    }
}

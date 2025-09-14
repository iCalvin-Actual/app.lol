//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI
import WebKit

struct AddressProfileView: View {
    
    @Environment(\.addressSummaryFetcher)
        var summaryFetcher
    
    @State
        var fetcher: AddressProfilePageFetcher = .init(addressName: "")
    @State
        var presentedURL: URL? = nil
    
    let addressName: AddressName
    
    init(_ name: AddressName) {
        self.addressName = name
    }
    
    var body: some View {
        WebView(url: fetcher.baseURL)
            .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
            .webViewContentBackground(fetcher.theme.backgroundBehavior ? .visible : .hidden)
#if os(iOS)
            .sheet(item: $presentedURL, content: { url in
                SafariView(url: url)
                    .ignoresSafeArea(.container, edges: .all)
            })
#endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    ShareLink(item: fetcher.baseURL)
#if os(visionOS)
                        .tint(.clear)
#else
                        .foregroundStyle(.primary)
#endif
                }
            }
            .task {
                let newFetcher = summaryFetcher(addressName)?.profileFetcher ?? .init(addressName: addressName)
                fetcher = newFetcher
                await fetcher.updateIfNeeded()
            }
    }
}

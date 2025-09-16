//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI
import WebKit

struct AddressProfileView: View {
    
    @State
        var fetcher: AddressProfilePageFetcher = .init(addressName: "")
    @State
        var presentedURL: URL? = nil
    
    let addressName: AddressName
    
    init(_ name: AddressName) {
        self.addressName = name
    }
    
    var body: some View {
        coreBody
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
                        .tint(.primary)
#endif
                }
            }
            .task {
                let newFetcher = summaryFetcher(addressName)?.profileFetcher ?? .init(addressName: addressName)
                fetcher = newFetcher
                await fetcher.updateIfNeeded()
            }
    }
    
    @ViewBuilder
    var coreBody: some View {
#if os(iOS)
        if #available(iOS 26.0, *) {
            modernBody
        } else {
            legacyBody
        }
#else
        modernBody
#endif
    }
    
    @ViewBuilder
    @available(iOS 26.0, *)
    var modernBody: some View {
        WebView(url: fetcher.baseURL)
            .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
            .webViewContentBackground(fetcher.theme.backgroundBehavior ? .visible : .hidden)
    }
    
    #if os(iOS)
    @ViewBuilder
    var legacyBody: some View {
        HTMLContentView(
            activeAddress: addressName,
            htmlContent: fetcher.html,
            baseURL: fetcher.baseURL,
            activeURL: $presentedURL
        )
        .ignoresSafeArea(.container, edges: (sizeClass == .regular && UIDevice.current.userInterfaceIdiom == .pad) ? [.bottom] : [])
    }
    #endif
    
    @Environment(\.addressSummaryFetcher)
        var summaryFetcher
    @Environment(\.horizontalSizeClass)
        var sizeClass
}

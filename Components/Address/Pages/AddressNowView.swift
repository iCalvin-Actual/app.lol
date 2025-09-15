//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI
import WebKit

struct AddressNowView: View {
    @State
        var fetcher: AddressNowPageFetcher = .init(addressName: "")
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
                        .foregroundStyle(.primary)
#endif
                }
            }
        .task { await configureFetcher() }
        .onChange(of: fetcher.address, {
            Task { await configureFetcher() }
        })
#if !os(tvOS)
        .principalAddressItem(
            viewContext == .detail,
            summaryFetcher: summaryFetcher(fetcher.address),
            addressPage: .init(
                get: { .pastebin },
                set: {
                    presentDestination?(.address(fetcher.address, page: $0))
                }
            )
        )
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
    
    func configureFetcher() async {
        if addressName != fetcher.address {
            let newFetcher = AddressNowPageFetcher(addressName: addressName)
            self.fetcher = newFetcher
        }
        await self.fetcher.updateIfNeeded()
    }
    
    @Environment(\.presentListable)
        var presentDestination
    @Environment(\.addressSummaryFetcher)
        var summaryFetcher
    @Environment(\.viewContext)
        var viewContext
    @Environment(\.horizontalSizeClass)
        var sizeClass
}

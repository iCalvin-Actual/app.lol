//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 6/9/24.
//

import SwiftUI
#if canImport(WebKit)
import WebKit
#endif


struct AddressNowPageView: View {
    @State
    var fetcher: AddressNowPageFetcher
    
    let htmlContent: String?
    let baseURL: URL?
    
    @State
    var presentedURL: URL? = nil
    
    var body: some View {
        WebView(url: fetcher.baseURL)
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
    }
}

struct HTMLFetcherView: View {
    @Environment(\.horizontalSizeClass)
    var sizeClass
    
    @State
    var fetcher: Request
    
    let activeAddress: AddressName?
    let htmlContent: String?
    let baseURL: URL?
    
    @State
    var presentedURL: URL? = nil
    
    var body: some View {
        #if canImport(UIKit)
        HTMLContentView(
            activeAddress: activeAddress,
            htmlContent: htmlContent,
            baseURL: baseURL,
            activeURL: $presentedURL
        )
        .ignoresSafeArea(.container, edges: (sizeClass == .regular && UIDevice.current.userInterfaceIdiom == .pad) ? [.bottom] : [])
        .safeAreaInset(edge: .bottom) {
            if let url = baseURL {
                Link(destination: url) {
                    Label {
                        Text("Open URL")
                    } icon: {
                        Image(systemName: "link")
                    }
                    .padding()
                    .background(Material.thin)
                    .cornerRadius(16)
                }
                .frame(maxWidth: .infinity)
                .background(Color.clear)
            }
        }
        .safeAreaInset(edge: .top) {
            if fetcher.loading && fetcher.loaded == nil {
                LoadingView()
                    .padding(24)
                    .background(Material.regular)
            }
        }
        #if !os(tvOS)
        .sheet(item: $presentedURL, content: { url in
            SafariView(url: url)
                .ignoresSafeArea(.container, edges: .all)
        })
        #endif
        #elseif canImport(WebKit)
        WebView(url: baseURL)
        #endif
    }
}


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
import WebKit


struct AddressProfilePageView: View {
    @Environment(\.visibleAddress)
    var visibleAddress
    @ObservedObject
    var fetcher: AddressProfilePageDataFetcher
    
    let htmlContent: String?
    let baseURL: URL?
    
    @State
    var presentedURL: URL? = nil
    
    var body: some View {
        WebView(url: fetcher.baseURL)
            .onChange(of: visibleAddress, { oldValue, newValue in
                print("Do a thing")
            })
            .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
            .webViewContentBackground(fetcher.theme.backgroundBehavior ? .visible : .hidden)
            #if os(iOS)
            .sheet(item: $presentedURL, content: { url in
                SafariView(url: url)
                    .ignoresSafeArea(.container, edges: .all)
            })
            #endif
    }
}


struct AddressNowPageView: View {
    @ObservedObject
    var fetcher: AddressNowPageDataFetcher
    
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
    }
}

struct HTMLFetcherView: View {
    @Environment(\.horizontalSizeClass)
    var sizeClass
    
    @ObservedObject
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


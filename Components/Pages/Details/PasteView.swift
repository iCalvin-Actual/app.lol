//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 4/26/23.
//

import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

struct PasteView: View {
    @Environment(\.viewContext)
        var viewContext
    @Environment(\.addressBook)
        var addressBook
    @Environment(\.credentialFetcher)
        var credential
    @Environment(\.addressSummaryFetcher)
        var summaryFetcher
    @Environment(\.presentListable)
        var presentDestination
    
    @State
        var shareURL: URL?
    @State
        var presentURL: URL?
    
    @State
        var showDraft: Bool = false
    @State
        var detent: PresentationDetent = .draftDrawer
    
    @State
        var fetcher: AddressPasteFetcher = .init(
            name: "", 
            title: ""
        )
    
    let address: AddressName
    let id: String
    
    init(_ id: String, from address: AddressName) {
        self.address = address
        self.id = id
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let model = fetcher.result {
                PasteRowView(model: model, cardPadding: 16)
                    .padding(.horizontal, 8)
                    .frame(maxHeight: .infinity, alignment: .top)
            } else if fetcher.loading {
                LoadingView()
                    .padding()
            } else {
                LoadingView()
                    .padding()
                    .task { @MainActor [fetcher] in
                        await fetcher.updateIfNeeded()
                    }
            }
            Spacer()
        }
        .task { await configureFetcher() }
        .onChange(of: fetcher.address, {
            Task { await configureFetcher() }
        })
        .onChange(of: fetcher.title, {
            Task { await configureFetcher() }
        })
        .onChange(of: fetcher.credential, {
            Task { await configureFetcher() }
        })
#if canImport(UIKit) && !os(tvOS)
        .sheet(item: $presentURL, content: { url in
            SafariView(url: url)
                .ignoresSafeArea(.container, edges: .all)
        })
#endif
        .environment(\.viewContext, .detail)
#if !os(tvOS)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if let url = fetcher.result?.shareURLs.first?.content {
                    ShareLink(item: url)
                }
            }
        }
    #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
    #endif
#endif
        .tint(.secondary)
        .principalAddressItem(
            viewContext != .profile,
            summaryFetcher: summaryFetcher(fetcher.address),
            addressPage: .init(
                get: { .pastebin },
                set: {
                    presentDestination?(.address(fetcher.address, page: $0))
                }
            )
        )
    }
    
    func configureFetcher() async {
        let credential = credential(address)
        if address != fetcher.address || id != fetcher.address || credential != fetcher.credential {
            let newFetcher = AddressPasteFetcher(
                name: address,
                title: id,
                credential: credential
            )
            self.fetcher = newFetcher
        }
        await self.fetcher.updateIfNeeded()
    }
}


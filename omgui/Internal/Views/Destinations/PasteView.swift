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
    @Environment(\.dismiss)
    var dismiss
    @Environment(\.horizontalSizeClass)
    var sizeClass
    @Environment(\.viewContext)
    var viewContext
    @Environment(\.openURL)
    var openUrl
    
    @Environment(\.viewContext)
    var context: ViewContext
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
    
    @StateObject
    var fetcher: AddressPasteDataFetcher
    
    init(_ id: String, from address: AddressName) {
        _fetcher = .init(wrappedValue: .init(name: address, title: id))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let model = fetcher.result {
                PasteRowView(model: model, cardPadding: 16)
                    .padding(.horizontal, 8)
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
        .task {
            let addressCredential = credential(fetcher.address)
            if fetcher.credential != addressCredential {
                fetcher.configure(credential: addressCredential)
            }
        }
        .onChange(of: fetcher.title, {
            Task { [fetcher] in
                await fetcher.updateIfNeeded(forceReload: true)
            }
        })
        .onChange(of: fetcher.credential, {
            Task { [fetcher] in
                await fetcher.updateIfNeeded(forceReload: true)
            }
        })
#if canImport(UIKit) && !os(tvOS)
        .sheet(item: $presentURL, content: { url in
            SafariView(url: url)
                .ignoresSafeArea(.container, edges: .all)
        })
#endif
        .environment(\.viewContext, ViewContext.detail)
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
        .toolbar {
            if let addressSummaryFetcher = summaryFetcher(fetcher.address) {
                ToolbarItem(placement: .principal) {
                    AddressPrincipalView(
                        addressSummaryFetcher: addressSummaryFetcher,
                        addressPage: .init(
                            get: { .pastebin },
                            set: {
                                presentDestination?(.address(addressSummaryFetcher.addressName, page: $0))
                            }
                        )
                    )
                }
            }
        }
        .onReceive(fetcher.result.publisher, perform: { _ in
            withAnimation {
                let address = fetcher.result?.addressName ?? ""
                guard !address.isEmpty, addressBook.mine.contains(address) else {
                    showDraft = false
                    return
                }
                if fetcher.result == nil && fetcher.title.isEmpty {
                    detent = .large
                    showDraft = true
                } else if fetcher.result != nil {
                    detent = .draftDrawer
                    showDraft = true
                }
            }
        })
    }
    
    @ViewBuilder
    private func linksSection(_ items: [SharePacket]) -> some View {
        Text("links")
            .font(.subheadline)
        
        LazyVStack {
            ForEach(items) { item in
                linkPreviewBuilder(item)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    @ViewBuilder
    private func linkPreviewBuilder(_ item: SharePacket) -> some View {
        Button {
            guard item.content.scheme?.contains("http") ?? false else {
                openUrl(item.content)
                return
            }
            withAnimation {
                presentURL = item.content
            }
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    if !item.name.isEmpty {
                        Text(item.name)
                            .font(.subheadline)
                            .bold()
                            .fontDesign(.rounded)
                    }
                    
                    Text(item.content.absoluteString)
                        .font(.caption)
                        .fontDesign(.monospaced)
                }
                .multilineTextAlignment(.leading)
                .lineLimit(3)
                
                Spacer()
                
                if item.content.scheme?.contains("http") ?? false {
                    ZStack {
                        #if canImport(UIKit) && !os(tvOS)
                        RemoteHTMLContentView(activeAddress: fetcher.address, startingURL: item.content, activeURL: $presentURL, scrollEnabled: .constant(false))
                        #endif
                            
                        LinearGradient(
                            stops: [
                                .init(color: .lolBackground, location: 0.1),
                                .init(color: .clear, location: 0.5)
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    }
                    .frame(width: 144, height: 144)
                    .mask {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                    }
                }
            }
            .foregroundStyle(Color.primary)
            .padding(4)
            .background(Material.thin)
            .mask {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
            }
        }
    }
    
    @ViewBuilder
    var draftContent: some View {
//        if let poster = fetcher.draftPoster {
//            PasteDraftView(draftFetcher: poster)
//        } else {
            EmptyView()
//        }
    }
}


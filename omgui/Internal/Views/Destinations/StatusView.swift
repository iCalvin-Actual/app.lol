//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 4/27/23.
//

import SwiftUI

struct StatusView: View {
    @ObservedObject
    var fetcher: StatusDataFetcher
    
    @Environment(\.addressBook)
    var addressBook
    @Environment(\.viewContext)
    var viewContext
    
    @Environment(\.openURL)
    var openUrl
    
    @State
    var shareURL: URL?
    @State
    var presentURL: URL?
    
    @State
    var expandBio: Bool = false
    
    @State
    var dummyValue: Bool = false
    
    init(fetcher: StatusDataFetcher) {
        self.fetcher = fetcher
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 32) {
                if viewContext != .profile, let addressBook {
                    AddressSummaryHeader(expandBio: $expandBio, addressBioFetcher: addressBook.addressSummary(fetcher.address).bioFetcher)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Material.thin)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .background(Color.clear)
                }
                if let model = fetcher.result {
                    StatusRowView(model: model)
                        .environment(\.viewContext, ViewContext.detail)
                        .padding(.horizontal)
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
                if let items = fetcher.result?.imageLinks, !items.isEmpty {
                    imageSection(items)
                        .padding(.horizontal)
                }
                if let items = fetcher.result?.linkedItems, !items.isEmpty {
                    linksSection(items)
                        .padding(.horizontal)
                }
                Spacer()
            }
            .padding(.vertical)
        }
        .onChange(of: fetcher.id, {
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
        #endif
    }
    
    @ViewBuilder
    private func imageSection(_ items: [SharePacket]) -> some View {
        Text("images")
            .font(.title2)
        LazyVStack {
            ForEach(items) { item in
                linkPreviewBuilder(item)
                    .frame(maxWidth: .infinity)
            }
        }
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
}

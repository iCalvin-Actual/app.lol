//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 4/27/23.
//

import SwiftUI

struct StatusView: View {
    
    @Environment(\.addressBook) var addressBook
    @Environment(\.viewContext) var viewContext
    @Environment(\.openURL) var openUrl
    @Environment(\.presentListable) var presentDestination
    @Environment(\.addressSummaryFetcher) var summaryFetcher
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @State var shareURL: URL?
    @State var presentURL: URL?
    @State var expandLinks: Bool = false
    
    @StateObject
    var fetcher: StatusDataFetcher
    
    init(address: AddressName, id: String) {
        _fetcher = .init(wrappedValue: .init(id: id, from: address))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let model = fetcher.result {
                StatusRowView(model: model)
                    .frame(maxHeight: expandLinks ? 300 : .infinity, alignment: .top)
                    .padding(.horizontal, 6)
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
            }
            if let items = fetcher.result?.linkedItems, !items.isEmpty {
                linksSection(items)
            }
            Spacer()
        }
        .padding(4)
        .padding(.vertical, sizeClass == .compact ? 16 : 0)
        .onChange(of: fetcher.id, {
            Task { [fetcher] in
                await fetcher.updateIfNeeded(forceReload: true)
            }
        })
        .environment(\.viewContext, ViewContext.detail)
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
        .tint(.primary)
        .toolbar {
            if let addressSummaryFetcher = summaryFetcher(fetcher.address) {
                ToolbarItem(placement: .principal) {
                    AddressPrincipalView(
                        addressSummaryFetcher: addressSummaryFetcher,
                        addressPage: .init(
                            get: { .statuslog },
                            set: {
                                presentDestination?(.address(addressSummaryFetcher.addressName, page: $0))
                            }
                        )
                    )
                }
            }
        }
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
        Section(isExpanded: $expandLinks) {
            ScrollView {
                ForEach(items) { item in
                    linkPreviewBuilder(item)
                        .frame(maxWidth: .infinity)
                }
            }
        } header: {
            Button {
                withAnimation{
                    expandLinks.toggle()
                }
            } label: {
                HStack {
                    Label("Links", systemImage: "link")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .rotationEffect(.init(degrees: expandLinks ? 90 : 0))
                }
            }
            .foregroundStyle(.primary)
            .buttonStyle(.bordered)
            .clipShape(Capsule())
        }
        .padding(8)
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
                            .foregroundColor(.secondary)
                    }
                    
                    Text(item.content.absoluteString)
                        .font(.caption)
                        .fontDesign(.monospaced)
                }
                .multilineTextAlignment(.leading)
                .lineLimit(3)
                
                Spacer()
            }
            .foregroundStyle(Color.primary)
            .padding(8)
            .background(Material.thin)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    @Previewable @State var model: StatusModel?
    
    let db = AppClient.database
    
    NavigationStack {
        if let model {
            StatusView(address: model.addressName, id: model.id)
                .background(NavigationDestination.account.gradient)
        }
    }
    .task {
        do {
            let sampleModel = StatusModel.sample(with: "app")
            try await sampleModel.write(to: db)
            model = sampleModel
        } catch {
            print(error.localizedDescription)
        }
    }
    .environment(\.viewContext, .detail)
    .environment(\.addressBook, .init())
    .environment(\.credentialFetcher, { _ in "" })
    .environment(\.pinAddress, { _ in })
    .environment(\.presentListable, { _ in })
    .environment(\.blackbirdDatabase, db)
}

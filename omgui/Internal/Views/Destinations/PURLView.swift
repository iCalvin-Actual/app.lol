//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 4/26/23.
//

#if canImport(AppKit)
import AppKit
#endif
import Blackbird
import SwiftUI
import WebKit

struct PURLView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.viewContext) var context
    @Environment(\.addressBook) var addressBook
    @Environment(\.addressSummaryFetcher)
    var summaryFetcher
    @Environment(\.presentListable)
    var presentDestination
    
    @Environment(\.credentialFetcher) var credential
    
    @State var showDraft: Bool = false
    @State var detent: PresentationDetent = .draftDrawer
    
    @State var presented: URL? = nil
    
    @StateObject var fetcher: AddressPURLDataFetcher
    
    init(id: String, from address: AddressName) {
        _fetcher = .init(wrappedValue: .init(name: address, title: id))
    }
    
    var body: some View {
        preview
            .toolbar {
                if let shareUrl = fetcher.result?.primaryURL {
                    ToolbarItem(placement: .primaryAction) {
                        ShareLink(item: shareUrl.content)
                            .tint(.primary)
                    }
                }
            }
            .task { [weak fetcher] in
                guard let fetcher else { return }
                fetcher.configure(credential: credential(fetcher.address))
                await fetcher.updateIfNeeded()
            }
    }
    
    @ViewBuilder
    var draftView: some View {
//        if let poster = fetcher.draftPoster {
//            PURLDraftView(draftFetcher: poster)
//        }
        EmptyView()
    }
    
    @ViewBuilder
    var preview: some View {
        WebView(fetcher.page)
            .safeAreaInset(edge: .bottom) {
                if let model = fetcher.result {
                    PURLRowView(model: model, cardColor: .lolRandom(model.listTitle), cardPadding: 8, cardRadius: 16, showSelection: true)
                        .padding(8)
                }
            }
    }
    
    @ViewBuilder
    var pathInfo: some View {
        if context != .profile {
            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    AddressIconView(address: fetcher.address, addressBook: addressBook)
                    Text("/\(fetcher.result?.name ?? fetcher.title)")
                        .font(.title2)
                        .fontDesign(.serif)
                        .foregroundStyle(Color.primary)
                        .multilineTextAlignment(.leading)
                }
                
                if let destination = fetcher.result?.content, !destination.isEmpty {
                    Text(destination)
                    #if !os(tvOS)
                        .textSelection(.enabled)
                    #endif
                        .font(.caption)
                        .fontDesign(.rounded)
                        .multilineTextAlignment(.leading)
                }
            }
            .lineLimit(3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Material.thin)
            .cornerRadius(10)
            .padding()
            .background(Color.clear)
        }
    }
}

#Preview {
    @Previewable @State var model: PURLModel?
    
    let db = AppClient.database
    
    NavigationStack {
        if let model {
            PURLView(id: model.name, from: model.addressName)
        }
    }
    .task {
        do {
            let sampleModel = PURLModel(owner: "app", name: "swiftAPI", content: "https://www.apple.com")
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

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

struct WrappedPage {
    
}

struct PURLView: View {
    @Environment(\.credentialFetcher)
        var credential
    @Environment(\.horizontalSizeClass)
        var sizeClass
    
    @State
        var showDraft: Bool = false
    @State
        var detent: PresentationDetent = .draftDrawer
    
    @State
        var presented: URL? = nil
    
    @State
    var fetcher: AddressPURLFetcher = .init(
        name: "",
        title: ""
    )
    
    let id: String
    let address: AddressName
    
    init(id: String, from address: AddressName) {
        self.address = address
        self.id = id
    }
    
    var body: some View {
        coreBody
            .safeAreaInset(edge: .bottom) {
                if let model = fetcher.result {
                    PURLRowView(
                        model: model,
                        cardColor: .lolRandom(model.listTitle),
                        cardPadding: 8,
                        cardRadius: 16,
                        showSelection: true
                    )
                    .environment(\.viewContext, .detail)
                    .padding(8)
                }
            }
            .task {
                await configureFetcher()
            }
            .onChange(of: fetcher.address, {
                Task { await configureFetcher() }
            })
            .onChange(of: fetcher.title, {
                Task { await configureFetcher() }
            })
            .onChange(of: fetcher.credential, {
                Task { await configureFetcher() }
            })
            .toolbar {
                if let shareUrl = fetcher.result?.primaryURL {
                    ToolbarItem(placement: .primaryAction) {
                        ShareLink(item: shareUrl.content)
#if os(visionOS)
                            .tint(.clear)
#else
                            .tint(.primary)
#endif
                    }
                }
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
        WebView(url: fetcher.result?.url)
    }
    
#if os(iOS)
    @ViewBuilder
    var legacyBody: some View {
        HTMLContentView(
            activeAddress: address,
            htmlContent: "",
            baseURL: fetcher.result?.url,
            activeURL: $presented
        )
        .ignoresSafeArea(.container, edges: (sizeClass == .regular && UIDevice.current.userInterfaceIdiom == .pad) ? [.bottom] : [])
    }
#endif
    
    func configureFetcher() async {
        let credential = credential(address)
        if address != fetcher.address || id != fetcher.address || credential != fetcher.credential {
            let newFetcher = AddressPURLFetcher(
                name: address,
                title: id,
                credential: credential
            )
            self.fetcher = newFetcher
        }
        await self.fetcher.updateIfNeeded()
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
    .environment(\.credentialFetcher, { _ in "" })
    .environment(\.pinAddress, { _ in })
    .environment(\.presentListable, { _ in })
    .environment(\.blackbirdDatabase, db)
}

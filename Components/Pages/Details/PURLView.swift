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
    @Environment(\.credentialFetcher)
        var credential
    
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
        WebView(fetcher.page)
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
                            .foregroundStyle(.primary)
#endif
                    }
                }
            }
    }
    
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

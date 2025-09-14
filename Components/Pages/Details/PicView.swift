//
//  PicView.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/13/25.
//

import SwiftUI

struct PicView: View {
    
    @Environment(\.addressBook) var addressBook
    @Environment(\.viewContext) var viewContext
    @Environment(\.openURL) var openUrl
    @Environment(\.presentListable) var presentDestination
    @Environment(\.addressSummaryFetcher) var summaryFetcher
    @Environment(\.picCache) var picCache
    
    @State var shareURL: URL?
    @State var presentURL: URL?
    
    let address: AddressName
    let id: String
    
    @State
    var fetcher: PicFetcher?
    
    init(address: AddressName, id: String) {
        self.address = address
        self.id = id
    }
    
    var body: some View {
        Group {
            if let model = fetcher?.result {
                PicRowView(model: model, cardPadding: 16)
                    .environment(\.viewContext, .detail)
                    .padding(.horizontal, 8)
                    .frame(maxHeight: .infinity, alignment: .top)
            } else if fetcher?.loading ?? false {
                LoadingView()
                    .padding()
                    .frame(maxHeight: .infinity, alignment: .center)
            } else {
                LoadingView()
                    .padding()
                    .frame(maxHeight: .infinity, alignment: .center)
                    .task {
                        if fetcher == nil {
                            if let cachedFetcher = picCache.object(forKey: NSString(string: address)) {
                                fetcher = cachedFetcher
                            } else {
                                let newFetcher = PicFetcher(id: id, from: address)
                                fetcher = newFetcher
                            }
                        }
                        await self.fetcher?.updateIfNeeded()
                    }
            }
        }
        .onChange(of: fetcher?.id, {
            Task { [weak fetcher] in
                await fetcher?.updateIfNeeded(forceReload: true)
            }
        })
        #if canImport(UIKit) && !os(tvOS)
        .sheet(item: $presentURL, content: { url in
            SafariView(url: url)
                .ignoresSafeArea(.container, edges: .all)
        })
        #endif
#if !os(tvOS)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if let url = fetcher?.result?.shareURLs.first?.content {
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
            summaryFetcher: summaryFetcher(address),
            addressPage: .init(
                get: { .statuslog },
                set: {
                    presentDestination?(.address(address, page: $0))
                }
            )
        )
    }
}

#Preview {
    @Previewable @State var model: PicModel?
    
    let db = AppClient.database
    
    NavigationStack {
        if let model {
            PicView(address: model.addressName, id: model.id)
        }
    }
    .task {
        do {
            let sampleModel = PicModel.sample(with: "app")
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

//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 4/27/23.
//

import SwiftUI

struct StatusView: View {
    @State
        var presentURL: URL?
    
    @State
        var fetcher: StatusFetcher = .init(id: "", from: "")
    
    init(address: AddressName, id: String) {
        _fetcher = .init(wrappedValue: .init(id: id, from: address))
    }
    
    var body: some View {
        Group {
            if let model = fetcher.result {
                StatusRowView(model: model, cardPadding: 16)
                    .environment(\.viewContext, .detail)
                    .padding(.horizontal, 8)
            } else if fetcher.loading {
                LoadingView()
                    .padding()
                    .frame(maxHeight: .infinity, alignment: .center)
            } else {
                LoadingView()
                    .padding()
                    .frame(maxHeight: .infinity, alignment: .center)
                    .task { @MainActor [fetcher] in
                        await fetcher.updateIfNeeded()
                    }
            }
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
                get: { .statuslog },
                set: {
                    presentDestination?(.address(fetcher.address, page: $0))
                }
            )
        )
    }
    
    @Environment(\.viewContext)
        var viewContext
    @Environment(\.presentListable)
        var presentDestination
    @Environment(\.addressSummaryFetcher)
        var summaryFetcher
}

#Preview {
    @Previewable @State var model: StatusModel?
    
    let db = AppClient.database
    
    NavigationStack {
        if let model {
            StatusView(address: model.addressName, id: model.id)
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
    .environment(\.credentialFetcher, { _ in "" })
    .environment(\.pinAddress, { _ in })
    .environment(\.presentListable, { _ in })
    .environment(\.blackbirdDatabase, db)
}

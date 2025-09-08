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
    
    @StateObject
    var fetcher: StatusDataFetcher
    
    init(address: AddressName, id: String) {
        _fetcher = .init(wrappedValue: .init(id: id, from: address))
    }
    
    var body: some View {
        Group {
            if let model = fetcher.result {
                StatusRowView(model: model, cardPadding: 16)
                    .frame(maxHeight: .infinity, alignment: .top)
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
        .toolbar {
            if let addressSummaryFetcher = summaryFetcher(fetcher.address) {
                ToolbarItem(placement: .topBarTrailing) {
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

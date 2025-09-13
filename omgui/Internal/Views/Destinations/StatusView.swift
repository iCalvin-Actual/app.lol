//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 4/27/23.
//

import SwiftUI

struct StatusView: View {
    @Environment(\.namespace) var namespace
    @Namespace var localNamespace
    
    @Environment(\.addressBook) var addressBook
    @Environment(\.viewContext) var viewContext
    @Environment(\.openURL) var openUrl
    @Environment(\.presentListable) var presentDestination
    @Environment(\.addressSummaryFetcher) var summaryFetcher
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @State var shareURL: URL?
    @State var presentURL: URL?
    
    @State
    var fetcher: StatusFetcher
    
    init(address: AddressName, id: String) {
        _fetcher = .init(wrappedValue: .init(id: id, from: address))
    }
    
    var body: some View {
        Group {
            if let model = fetcher.result {
                StatusRowView(model: model, cardPadding: 16)
                    .environment(\.viewContext, .detail)
                    .padding(.horizontal, 8)
                    .matchedGeometryEffect(id: model.listID, in: namespace ?? localNamespace)
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
            ToolbarItem(placement: .safePrincipal) {
                if let summaryFetcher = summaryFetcher(fetcher.address), viewContext != .profile {
                    AddressPrincipalView(
                        addressSummaryFetcher: summaryFetcher,
                        addressPage: .init(
                            get: { .statuslog },
                            set: {
                                presentDestination?(.address(fetcher.address, page: $0))
                            }
                        )
                    )
                }
            }
        }
    }
}

extension ToolbarItemPlacement {
    static var safePrincipal: ToolbarItemPlacement {
        #if os(macOS)
        return .principal
        #else
        return .topBarLeading
        #endif
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

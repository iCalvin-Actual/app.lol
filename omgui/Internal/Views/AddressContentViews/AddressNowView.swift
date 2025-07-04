//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct AddressNowView: View {
    @ObservedObject
    var fetcher: AddressNowPageDataFetcher
    
    var body: some View {
        htmlBody
            .onChange(of: fetcher.addressName, {
                Task { [fetcher] in
                    await fetcher.updateIfNeeded(forceReload: true)
                }
            })
            .onAppear {
                Task { @MainActor [fetcher] in
                    await fetcher.updateIfNeeded()
                }
            }
        #if !os(tvOS)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    if let url = fetcher.result?.shareURLs.first?.content {
                        ShareLink(item: url)
                    }
                }
            }
        #endif
    }
    
    @ViewBuilder
    var htmlBody: some View {
        AddressNowPageView(
            fetcher: fetcher,
            activeAddress: fetcher.addressName,
            htmlContent: fetcher.result?.html,
            baseURL: nil
        )
    }
}

#Preview {
    let sceneModel = SceneModel.sample
    AddressNowView(fetcher: sceneModel.addressSummary("app").nowFetcher)
}

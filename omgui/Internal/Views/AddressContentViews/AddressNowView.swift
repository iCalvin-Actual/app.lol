//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct AddressNowView: View {
    @ObservedObject
    var fetcher: AddressNowDataFetcher
    
    var body: some View {
        htmlBody
            .onChange(of: fetcher.address, {
                Task { [fetcher] in
                    await fetcher.updateIfNeeded(forceReload: true)
                }
            })
            .onAppear {
                Task { @MainActor [fetcher] in
                    await fetcher.updateIfNeeded()
                }
            }
            .toolbar {
                ToolbarItem(placement: .secondaryAction) {
                    if let url = fetcher.result?.shareURLs.first?.content {
                        ShareLink(item: url)
                    }
                }
            }
    }
    
    @ViewBuilder
    var htmlBody: some View {
        if let html = fetcher.result?.html {
            HTMLFetcherView(
                fetcher: fetcher,
                activeAddress: fetcher.address,
                htmlContent: html,
                baseURL: nil
            )
        } else {
            VStack {
                if fetcher.loading {
                    LoadingView()
                        .padding()
                } else if fetcher.noContent {
                    ThemedTextView(text: "no /now page")
                        .padding()
                        .frame(maxWidth: .infinity)
                } else {
                    LoadingView()
                        .padding()
                }
                Spacer()
            }
        }
    }
}

#Preview {
    let sceneModel = SceneModel.sample
    AddressNowView(fetcher: sceneModel.addressSummary("app").nowFetcher)
}

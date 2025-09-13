//
//  PicRowView.swift
//
//
//  Created by Calvin Chestnut on 3/8/23.
//

import Blackbird
import MarkdownUI
import SafariServices
import SwiftUI

struct PicRowView: View {
    @Environment(\.addressBook) var addressBook
    @Environment(\.pinAddress) var pin
    @Environment(\.unpinAddress) var unpin
    @Environment(\.blockAddress) var block
    @Environment(\.unblockAddress) var unblock
    @Environment(\.followAddress) var follow
    @Environment(\.unfollowAddress) var unfollow
    @Environment(\.openURL) var openUrl
    
    @Environment(\.picCache) var picCache
    
    @Environment(\.viewContext) var context: ViewContext
    @Environment(\.presentListable) var present
    
    @GestureState private var zoom = 1.0
    
    @State var showURLs: Bool = false
    @State var presentImage: URL?
    @State var presentURL: URL?
    
    let model: PicModel
    
    let cardColor: Color
    let cardPadding: CGFloat
    let cardRadius: CGFloat
    let showSelection: Bool
    
    let menuBuilder = ContextMenuBuilder<PicModel>()
    
    @State
    var picFetcher: PicFetcher?
    
    init(model: PicModel, cardColor: Color? = nil, cardPadding: CGFloat = 8, cardRadius: CGFloat = 16, showSelection: Bool = false) {
        self.model = model
        self.cardColor = cardColor ?? .lolRandom(model.id)
        self.cardPadding = cardPadding
        self.cardRadius = cardRadius
        self.showSelection = showSelection
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            RowHeader(model: model) {
                EmptyView()
            }
            
            mainBody
            
            RowFooter(model: model) {
                EmptyView()
            }
        }
        .asCard(destination: model.rowDestination(), padding: cardPadding, radius: cardRadius, selected: showSelection)
        .contextMenu(menuItems: {
            menuBuilder.contextMenu(
                for: model,
                fetcher: nil,
                addressBook: addressBook,
                menuFetchers: (
                    navigate: present ?? { _ in },
                    follow: follow,
                    block: block,
                    pin: pin,
                    unFollow: unfollow,
                    unBlock: unblock,
                    unPin: unpin
                )
            )
        })
        .confirmationDialog("Open Image", isPresented: $showURLs, actions: {
            Button {
                presentURL = model.content
            } label: {
                Text(model.description)
            }
        })
        .sheet(item: $presentURL) { url in
            #if !os(macOS)
            SafariView(url: url)
            #endif
        }
        .clipped()
        .id(picFetcher?.id ?? model.id)
        .task {
            if picFetcher?.id != model.id {
                picFetcher = nil
            }
        }
    }
    
    @ViewBuilder
    var mainBody: some View {
        rowBody
            .padding(8)
            .asCard(material: .regular, padding: 4, radius: cardRadius)
            .padding(.horizontal, 4)
    }
    
    @ViewBuilder
    var rowBody: some View {
        VStack(alignment: .leading, spacing: 8) {
            appropriateMarkdown
                .fontWeight(.medium)
                .fontDesign(.rounded)
            imagePreview(model.content)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .lineLimit(context != .detail ? 3 : nil)
        .multilineTextAlignment(.leading)
    }
    
    @State private var offset: CGFloat = 0
    @ViewBuilder
    var appropriateMarkdown: some View {
        Markdown(model.description, hideImages: true)
    }
    
    @ViewBuilder
    func imagePreview(_ url: URL) -> some View {
        if context == .detail {
            Button {
#if os(macOS)
                openUrl(url)
#else
                presentURL = url
#endif
            } label: {
                imageBody(url)
            }
            .buttonStyle(.plain)
        } else {
            imageBody(url)
        }
    }
    
    @ViewBuilder
    func imageBody(_ url: URL) -> some View {
        if let picFetcher, let result = picFetcher.imageData, !result.isEmpty {
            #if canImport(UIKit)
            if let image = UIImage(data: result) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipped()
            }
            #elseif canImport(AppKit)
            if let image = NSImage(data: result) {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipped()
            }
            #endif
        } else {
            // Fallback placeholder on failure
            Color.secondary.opacity(0.2)
                .frame(maxWidth: .infinity)
                .aspectRatio(5/3, contentMode: .fill)
                .overlay(
                    LoadingView()
                )
                .task {
                    if picFetcher == nil || picFetcher?.id != model.id {
                        
                        if let cachedFetcher = picCache.object(forKey: NSString(string: model.id)) {
                            picFetcher = cachedFetcher
                        } else {
                            let newFetcher = PicFetcher(id: model.id, from: model.addressName)
                            self.picFetcher = newFetcher
                            picCache.setObject(newFetcher, forKey: NSString(string: model.id))
                        }
                    }
                    await picFetcher?.updateIfNeeded()
                }
        }
    }
}

#Preview {
    @Previewable @State var fetcher: PhotoFeedFetcher?
    
    let db = AppClient.database
    
    NavigationStack {
        if let fetcher {
            ListView(dataFetcher: fetcher)
                .background(NavigationDestination.account.gradient)
        }
    }
    .task {
        do {
            let sampleModels: [PicModel] = [.sample(with: "app"), .sample(with: "alex"), .sample(with: "merlinmann")]
            try await sampleModels.first?.write(to: db)
            fetcher = .init(addressBook: .init())
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

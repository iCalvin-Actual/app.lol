//
//  File.swift
//
//
//  Created by Calvin Chestnut on 3/8/23.
//

import MarkdownUI
import SafariServices
import SwiftUI

struct StatusRowView: View {
    @Environment(\.addressBook)
        var addressBook
    @Environment(\.pinAddress)
        var pin
    @Environment(\.unpinAddress)
        var unpin
    @Environment(\.blockAddress)
        var block
    @Environment(\.unblockAddress)
        var unblock
    @Environment(\.followAddress)
        var follow
    @Environment(\.unfollowAddress)
        var unfollow
    @Environment(\.openURL)
        var openUrl
    
    @Environment(\.viewContext)
        var context: ViewContext
    @Environment(\.presentListable)
        var present
    
    @GestureState
        private var zoom = 1.0
    
    @State
        var presentURL: URL?
    
    let model: StatusModel
    
    let cardColor: Color
    let cardPadding: CGFloat
    let cardRadius: CGFloat
    let showSelection: Bool
    
    private let menuBuilder = ContextMenuBuilder<StatusModel>()
    
    init(model: StatusModel, cardColor: Color? = nil, cardPadding: CGFloat = 8, cardRadius: CGFloat = 16, showSelection: Bool = false) {
        self.model = model
        self.cardColor = cardColor ?? .lolRandom(model.displayEmoji)
        self.cardPadding = cardPadding
        self.cardRadius = cardRadius
        self.showSelection = showSelection
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            RowHeader(model: model) {
                Text(model.displayEmoji.count > 1 ? "✨" : model.displayEmoji.prefix(1))
                    .font(.system(size: 35))
            }
            
            mainBody
            
            RowFooter(model: model) {
                if !model.linkedItems.isEmpty {
                    Menu {
                        ForEach(model.linkedItems) { item in
                            Button {
                                guard item.content.scheme?.contains("http") ?? false else {
                                    openUrl(item.content)
                                    return
                                }
#if os(macOS)
                                openUrl(item.content)
#else
                                withAnimation {
                                    presentURL = item.content
                                }
#endif
                            } label: {
                                Text(item.name)
                                    .font(.headline)
                                Text(item.content.absoluteString)
                                    .font(.subheadline)
                            }
                        }
                    } label: {
                        Image(systemName: "link.circle")
                    }
                    .buttonStyle(.borderless)
                } else {
                    EmptyView()
                }
            }
        }
        .asCard(destination: model.rowDestination(), padding: cardPadding, radius: cardRadius, selected: showSelection)
        .contextMenu(menuItems: {
            menuBuilder.contextMenu(
                for: model,
                fetcher: nil,
                addressBook: addressBook,
                appActions: (
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
        .sheet(item: $presentURL) { url in
            #if !os(macOS)
            SafariView(url: url)
            #endif
        }
        .clipped()
    }
    
    @ViewBuilder
    var mainBody: some View {
        VStack(alignment: .leading, spacing: 8) {
            appropriateMarkdown
                .tint(.lolAccent)
                .fontWeight(.medium)
                .fontDesign(.rounded)
            
            if !model.imageLinks.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .center) {
                        ForEach(model.imageLinks) { image in
                            imagePreview(image.content)
                        }
                    }
                    .padding(8)
                }
                .padding(-8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .lineLimit(context != .detail ? 5 : nil)
        .multilineTextAlignment(.leading)
        .padding(8)
        .asCard(material: .regular, padding: 4, radius: cardRadius)
        .padding(.horizontal, 4)
    }
    
    @ViewBuilder
    func imagePreview(_ url: URL) -> some View {
        Button {
            #if os(macOS)
            openUrl(url)
            #else
            presentURL = url
            #endif
        } label: {
            // Async image thumbnail cropped to a square with rounded corners
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .clipped()
                case .failure(_):
                    // Fallback placeholder on failure
                    Color.secondary.opacity(0.2)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundStyle(.secondary)
                        )
                case .empty:
                    // Loading placeholder
                    ProgressView()
                        .background(Color.secondary.opacity(0.1))
                @unknown default:
                    Color.secondary.opacity(0.2)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .buttonStyle(.plain)
    }
    
    @State private var offset: CGFloat = 0
    @ViewBuilder
    var appropriateMarkdown: some View {
        if context == .detail {
            ScrollView {
                Markdown(model.displayStatus, hideImages: true)
            }
            .onScrollGeometryChange(for: CGFloat.self, of: { proxy in
                proxy.contentOffset.y
            }, action: { oldValue, newValue in
                offset = newValue
            })
        } else {
            Markdown(model.displayStatus, hideImages: true)
        }
    }
}

#Preview {
    @Previewable @State var fetcher: StatusLogFetcher?
    
    let db = AppClient.database
    
    NavigationStack {
        if let fetcher {
            ListView(dataFetcher: fetcher)
                .background(NavigationDestination.account.gradient)
        }
    }
    .task {
        do {
            let sampleModels: [StatusModel] = [.sample(with: "app"), .sample(with: "alex"), .sample(with: "merlinmann")]
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

#Preview {
    ScrollView {
        VStack(spacing: 0) {
            StatusRowView(model: .sample(with: "app"))
                .environment(\.viewContext, ViewContext.column)
            StatusRowView(model: .sample(with: "alexcox"))
                .environment(\.viewContext, ViewContext.profile)
            StatusRowView(model: .sample(with: "app"))
                .environment(\.viewContext, ViewContext.detail)
        }
        .padding(.vertical)
    }
    .environment(\.viewContext, .column)
}


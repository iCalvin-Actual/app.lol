//
//  File.swift
//
//
//  Created by Calvin Chestnut on 3/8/23.
//

import MarkdownUI
import SwiftUI

struct StatusRowView: View {
    @Environment(\.pinAddress) var pin
    @Environment(\.unpinAddress) var unpin
    @Environment(\.blockAddress) var block
    @Environment(\.unblockAddress) var unblock
    @Environment(\.followAddress) var follow
    @Environment(\.unfollowAddress) var unfollow
    
    @Environment(\.viewContext) var context: ViewContext
    @Environment(\.addressBook) var addressBook
    @Environment(\.presentListable) var present
    @Environment(\.addressSummaryFetcher) var summaryFetcher
    
    @GestureState private var zoom = 1.0
    
    @State var showURLs: Bool = false
    @State var presentUrl: URL?
    
    let model: StatusModel
    
    let cardColor: Color
    let cardPadding: CGFloat
    let cardradius: CGFloat
    let showSelection: Bool
    
    let menuBuilder = ContextMenuBuilder<StatusModel>()
    
    init(model: StatusModel, cardColor: Color? = nil, cardPadding: CGFloat = 8, cardradius: CGFloat = 16, showSelection: Bool = false) {
        self.model = model
        self.cardColor = cardColor ?? .lolRandom(model.displayEmoji)
        self.cardPadding = cardPadding
        self.cardradius = cardradius
        self.showSelection = showSelection
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            RowHeader(model: model) {
                Text(model.displayEmoji.count > 1 ? "✨" : model.displayEmoji.prefix(1))
                    .font(.system(size: 35))
            }
            
            mainBody
            
            HStack {
                Text(DateFormatter.short.string(from: model.date))
                    .font(.caption)
                    .padding(.horizontal, 4)
                Spacer()
                Menu {
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
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            .foregroundStyle(.secondary)
            .padding(4)
            .padding(.leading, 4)
        }
        .asCard(color: cardColor, padding: 0, radius: cardradius, selected: showSelection || context == .detail)
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
            ForEach(model.imageLinks) { link in
                Button {
                    presentUrl = link.content
                } label: {
                    Text(link.name)
                }
            }
        })
        .sheet(item: $presentUrl) { url in
            AsyncImage(url: url) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(zoom)
                #if !os(tvOS)
                    .gesture(
                        MagnifyGesture()
                            .updating($zoom) { value, gestureState, transaction in
                                gestureState = value.magnification
                            }
                    )
                #endif
            } placeholder: {
                ThemedTextView(text: "Loading image...")
            }
        }
        .clipped()
    }
    
    @ViewBuilder
    var mainBody: some View {
        rowBody
            .frame(maxHeight: context == .detail ? .infinity : nil, alignment: .top)
            .asCard(color: cardColor, material: .regular, padding: cardPadding, radius: cardradius)
            .padding(.horizontal, 4)
    }
    
    @ViewBuilder
    var rowBody: some View {
        VStack(alignment: .leading, spacing: 2) {
            /*
             This was tricky to set up
             so I'm leaving it here
             
//                    Text(model.displayEmoji)
//                        .font(.system(size: 44))
//                    + Text(" ").font(.largeTitle) +
             */
            appropriateMarkdown
                .tint(.lolAccent)
                .fontWeight(.medium)
                .fontDesign(.rounded)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .lineLimit(context == .column ? 5 : nil)
        .multilineTextAlignment(.leading)
    }
    
    @ViewBuilder
    var appropriateMarkdown: some View {
        ScrollView {
            Markdown(model.displayStatus)
        }
        .scrollDisabled(context == .column)
    }
    
    @ViewBuilder
    var headerContent: some View {
        HStack(alignment: .bottom, spacing: 4) {
            if context != .profile {
                AddressIconView(address: model.address, addressBook: addressBook, showMenu: context != .detail, contentShape: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 2)
            }
            VStack(alignment: .leading, spacing: 2) {
                AddressNameView(model.address, font: .headline)
                    .foregroundStyle(.primary)
                if let caption = context != .detail ? DateFormatter.relative.string(for: model.date) ?? model.listCaption : model.listCaption {
                    Text(caption)
                        .multilineTextAlignment(.leading)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .truncationMode(.tail)
                }
            }
            Spacer()
            Text(model.displayEmoji.count > 1 ? "✨" : model.displayEmoji.prefix(1))
                .font(.system(size: 35))
        }
    }
}

#Preview {
    VStack {
        Spacer()
        StatusRowView(model: .sample(with: "app"))
            .environment(\.viewContext, ViewContext.column)
        StatusRowView(model: .sample(with: "alexcox"))
            .environment(\.viewContext, ViewContext.profile)
        StatusRowView(model: .sample(with: "app"))
            .environment(\.viewContext, ViewContext.detail)
        Spacer()
    }
    .environment(SceneModel.sample)
    .padding(.horizontal)
}


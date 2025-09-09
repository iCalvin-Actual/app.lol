//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import MarkdownUI
import SwiftUI

struct RowHeader<T: Listable, V: View>: View {
    @Environment(\.viewContext) var context
    @Environment(\.addressBook) var addressBook
    
    let model: T
    let cornerView: () -> V
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            if context != .profile {
                AddressIconView(address: model.addressName, showMenu: context != .detail, contentShape: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 2)
            }
            HStack (alignment: .lastTextBaseline, spacing: 4) {
                VStack(alignment: .leading, spacing: 2) {
                    if let caption = DateFormatter.relative.string(for: model.displayDate) ?? model.listCaption {
                        Text(caption)
                            .multilineTextAlignment(.leading)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .truncationMode(.tail)
                    }
                    AddressNameView(model.addressName, font: .headline)
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                cornerView()
            }
        }
        .padding(.top, 4)
        .padding(.horizontal, 4)
        .padding(4)
        
    }
}

struct RowFooter<T: Listable, A: View>: View {
    @Environment(\.addressBook) var addressBook
    @Environment(\.pinAddress) var pin
    @Environment(\.unpinAddress) var unpin
    @Environment(\.blockAddress) var block
    @Environment(\.unblockAddress) var unblock
    @Environment(\.followAddress) var follow
    @Environment(\.unfollowAddress) var unfollow
    @Environment(\.presentListable) var present
    
    let model: T
    
    @ViewBuilder let accessoryBuilder: () -> A
    
    let menuBuilder = ContextMenuBuilder<T>()
    
    var body: some View {
        HStack(alignment: .top) {
            if let date = model.displayDate {
                Text(DateFormatter.short.string(from: date))
                    .font(.caption)
                    .padding(.horizontal, 4)
            }
            Spacer()
            accessoryBuilder()
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
}

struct PURLRowView: View {
    @Environment(\.pinAddress) var pin
    @Environment(\.unpinAddress) var unpin
    @Environment(\.blockAddress) var block
    @Environment(\.unblockAddress) var unblock
    @Environment(\.followAddress) var follow
    @Environment(\.unfollowAddress) var unfollow
    
    @Environment(\.viewContext) var context: ViewContext
    @Environment(\.presentListable) var present
    @Environment(\.addressSummaryFetcher) var summaryFetcher
    
    let model: PURLModel
    
    let cardColor: Color
    let cardPadding: CGFloat
    let cardRadius: CGFloat
    let showSelection: Bool
    
    let menuBuilder = ContextMenuBuilder<PURLModel>()
    
    init(model: PURLModel, cardColor: Color? = nil, cardPadding: CGFloat = 8, cardRadius: CGFloat = 16, showSelection: Bool = false) {
        self.model = model
        self.cardColor = cardColor ?? .lolRandom(model.listTitle)
        self.cardPadding = cardPadding
        self.cardRadius = cardRadius
        self.showSelection = showSelection
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            RowHeader(model: model) {
                Text("/\(model.listTitle)")
                    .fontDesign(.serif)
                    .font(.subheadline)
            }
            
            mainBody
            
            RowFooter(model: model) { EmptyView() }
        }
        .asCard(padding: cardPadding, radius: cardRadius, selected: showSelection)
        .frame(maxWidth: .infinity)
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
        if !model.content.isEmpty {
            HStack {
                Text(model.content.replacingOccurrences(of: "https://www.", with: ""))
                    .fontWeight(.medium)
                    .fontDesign(.monospaced)
                    .frame(maxHeight: context == .detail ? 30 : nil)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(4)
            .multilineTextAlignment(.leading)
        }
    }
}

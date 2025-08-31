//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import MarkdownUI
import SwiftUI

struct PURLRowView: View {
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
    
    let model: PURLModel
    
    let cardColor: Color
    let cardPadding: CGFloat
    let cardradius: CGFloat
    let showSelection: Bool
    
    let menuBuilder = ContextMenuBuilder<PURLModel>()
    
    init(model: PURLModel, cardColor: Color? = nil, cardPadding: CGFloat = 8, cardradius: CGFloat = 16, showSelection: Bool = false) {
        self.model = model
        self.cardColor = cardColor ?? .lolRandom(model.listTitle)
        self.cardPadding = cardPadding
        self.cardradius = cardradius
        self.showSelection = showSelection
    }
    
    @ViewBuilder
    var headerContent: some View {
        HStack(alignment: .bottom, spacing: 4) {
            if context != .profile {
                AddressIconView(address: model.addressName, addressBook: addressBook, showMenu: context != .detail, contentShape: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 2)
            }
            VStack(alignment: .leading, spacing: 2) {
                if context != .profile {
                    AddressNameView(model.addressName, font: .headline)
                        .foregroundStyle(.primary)
                } else if let timeText = DateFormatter.short.string(for: model.date) {
                    Text(timeText)
                        .fontDesign(.serif)
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
                if let caption = context != .detail ? DateFormatter.relative.string(for: model.date) ?? model.listCaption : model.listCaption {
                    Text(caption)
                        .multilineTextAlignment(.leading)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .truncationMode(.tail)
                }
            }
            Spacer()
            Text(model.listTitle)
                .font(.subheadline)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerContent
                .padding(4)
            
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
        .asCard(color: cardColor, padding: 0, radius: cardradius, selected: showSelection)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    var mainBody: some View {
        rowBody
            .asCard(color: cardColor, material: .regular, padding: cardPadding, radius: cardradius)
            .padding(.horizontal, 4)
    }
    
    @ViewBuilder
    var rowBody: some View {
        if !model.content.isEmpty {
            HStack {
                Text(model.content)
                    .fontWeight(.medium)
                    .fontDesign(.serif)
                    .frame(maxHeight: 30)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(context == .column ? 5 : nil)
            .multilineTextAlignment(.leading)
        }
    }
}

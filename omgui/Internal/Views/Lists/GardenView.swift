//
//  File 2.swift
//  
//
//  Created by Calvin Chestnut on 3/15/23.
//

import SwiftUI

struct GardenView: View {
    @Environment(\.nowGardenFetcher)
    var fetcher
    
    var body: some View {
        if let fetcher {
            ListView<NowListing>(dataFetcher: fetcher)
        }
    }
}

struct GardenItemView: View {
    @Environment(\.addressBook) var addressBook
    @Environment(\.viewContext) var context
    @Environment(\.pinAddress) var pin
    @Environment(\.unpinAddress) var unpin
    @Environment(\.blockAddress) var block
    @Environment(\.unblockAddress) var unblock
    @Environment(\.followAddress) var follow
    @Environment(\.unfollowAddress) var unfollow
    
    @Environment(\.presentListable) var present
    
    let model: NowListing
    
    let cardColor: Color
    let cardPadding: CGFloat
    let cardradius: CGFloat
    let showSelection: Bool
    
    let menuBuilder = ContextMenuBuilder<NowListing>()
    
    init(model: NowListing, cardColor: Color, cardPadding: CGFloat, cardradius: CGFloat, showSelection: Bool) {
        self.model = model
        self.cardColor = cardColor
        self.cardPadding = cardPadding
        self.cardradius = cardradius
        self.showSelection = showSelection
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerContent
                .padding(4)
            
            HStack(alignment: .bottom) {
                Text(model.listSubtitle)
                    .font(.callout)
                    .foregroundStyle(.primary)
                    .fontDesign(.monospaced)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .asCard(color: cardColor, material: .regular, padding: cardPadding, radius: cardradius)
            .padding(.horizontal, 4)
            
            
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
            .padding(.horizontal, 4)
        }
        .asCard(color: cardColor, padding: 0, radius: cardradius, selected: showSelection)
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
    }
    
    @ViewBuilder
    var headerContent: some View {
        HStack(alignment: .bottom, spacing: 4) {
            if context != .profile {
                AddressIconView(address: model.owner, addressBook: addressBook, contentShape: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 2)
            }
            VStack(alignment: .leading, spacing: 2) {
                if context != .profile {
                    AddressNameView(model.owner, font: .headline)
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
            Text("/now")
                .fontDesign(.serif)
                .font(.headline)
                .frame(maxHeight: .infinity)
        }
    }
}

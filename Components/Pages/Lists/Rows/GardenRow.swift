//
//  GardenRow.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/14/25.
//

import SwiftUI


struct GardenItemView: View {
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
    
    @Environment(\.presentListable)
        var present
    
    let model: NowListing
    
    let cardColor: Color
    let cardPadding: CGFloat
    let cardRadius: CGFloat
    let showSelection: Bool
    
    private let menuBuilder = ContextMenuBuilder<NowListing>()
    
    init(model: NowListing, cardColor: Color, cardPadding: CGFloat, cardRadius: CGFloat, showSelection: Bool) {
        self.model = model
        self.cardColor = cardColor
        self.cardPadding = cardPadding
        self.cardRadius = cardRadius
        self.showSelection = showSelection
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            RowHeader(model: model) {
                Text("/now")
                    .fontDesign(.serif)
                    .font(.subheadline)
            }
            
            Text(model.listSubtitle)
                .font(.callout)
                .foregroundStyle(.primary)
                .fontDesign(.monospaced)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .asCard(material: .regular, padding: 4, radius: cardRadius)
                .padding(.horizontal, 4)
            
            RowFooter(model: model) { EmptyView() }
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
    }
}

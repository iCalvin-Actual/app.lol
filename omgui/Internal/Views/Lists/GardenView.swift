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
            RowHeader(model: model) {
                Text("/now")
                    .fontDesign(.serif)
                    .font(.subheadline)
            }
            
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
            
            RowFooter(model: model)
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
}

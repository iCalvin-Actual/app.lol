//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import MarkdownUI
import SwiftUI

struct PasteRowView: View {
    @Environment(\.pinAddress) var pin
    @Environment(\.unpinAddress) var unpin
    @Environment(\.blockAddress) var block
    @Environment(\.unblockAddress) var unblock
    @Environment(\.followAddress) var follow
    @Environment(\.unfollowAddress) var unfollow
    
    @Environment(\.viewContext) var context: ViewContext
    @Environment(\.presentListable) var present
    
    let model: PasteModel
    
    let cardColor: Color
    let cardPadding: CGFloat
    let cardRadius: CGFloat
    let showSelection: Bool
    
    let menuBuilder = ContextMenuBuilder<PasteModel>()
    
    init(model: PasteModel, cardColor: Color? = nil, cardPadding: CGFloat = 8, cardRadius: CGFloat = 16, showSelection: Bool = false) {
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
    }
    
    @ViewBuilder
    var mainBody: some View {
        rowBody
            .asCard(material: .regular, radius: cardRadius)
            .padding(.horizontal, 4)
    }
    
    @ViewBuilder
    var rowBody: some View {
        appropriateMarkdown
            .tint(.lolAccent)
            .fontWeight(.medium)
            .fontDesign(.rounded)
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(context == .column ? 4 : nil)
            .multilineTextAlignment(.leading)
    }
    
    @ViewBuilder
    var appropriateMarkdown: some View {
        if context == .detail {
            ScrollView {
                Markdown(model.content)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
            }
        } else {
            Text(model.content)
                .padding(8)
        }
    }
}

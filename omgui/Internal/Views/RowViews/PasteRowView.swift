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
    @Environment(\.addressBook) var addressBook
    @Environment(\.presentListable) var present
    @Environment(\.addressSummaryFetcher) var summaryFetcher
    
    let model: PasteModel
    
    let cardColor: Color
    let cardPadding: CGFloat
    let cardradius: CGFloat
    let showSelection: Bool
    
    let menuBuilder = ContextMenuBuilder<PasteModel>()
    
    init(model: PasteModel, cardColor: Color? = nil, cardPadding: CGFloat = 8, cardradius: CGFloat = 16, showSelection: Bool = false) {
        self.model = model
        self.cardColor = cardColor ?? .lolRandom(model.listTitle)
        self.cardPadding = cardPadding
        self.cardradius = cardradius
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
            
            RowFooter(model: model)
        }
        .asCard(color: cardColor, padding: 0, radius: cardradius, selected: showSelection)
        .frame(maxWidth: .infinity, maxHeight: context == .detail ? .infinity : 250)
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
        if context == .detail {
            ScrollView {
                Markdown(model.content)
            }
        } else {
            Text(model.content)
        }
    }
}

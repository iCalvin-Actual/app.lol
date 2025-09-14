//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import MarkdownUI
import SwiftUI

struct PasteRowView: View {
    
    let model: PasteModel
    
    let cardColor: Color
    let cardPadding: CGFloat
    let cardRadius: CGFloat
    let showSelection: Bool
    
    private let menuBuilder = ContextMenuBuilder<PasteModel>()
    
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
        .asCard(destination: model.rowDestination(), padding: cardPadding, radius: cardRadius, selected: showSelection)
    }
    
    @ViewBuilder
    var mainBody: some View {
        appropriateMarkdown
            .tint(.lolAccent)
            .fontWeight(.medium)
            .fontDesign(.rounded)
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(context != .detail ? 4 : nil)
            .multilineTextAlignment(.leading)
            .asCard(material: .regular, radius: cardRadius)
            .padding(.horizontal, 4)
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
    
    @Environment(\.viewContext)
        var context: ViewContext
    @Environment(\.presentListable)
        var present
}

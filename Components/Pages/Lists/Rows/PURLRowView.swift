//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import MarkdownUI
import SwiftUI

struct PURLRowView: View {
    @Environment(\.viewContext)
        var context: ViewContext
    
    let model: PURLModel
    
    let cardColor: Color
    let cardPadding: CGFloat
    let cardRadius: CGFloat
    let showSelection: Bool
    
    private let menuBuilder = ContextMenuBuilder<PURLModel>()
    
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
        .asCard(destination: model.rowDestination(), padding: cardPadding, radius: cardRadius, selected: showSelection)
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

//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct PURLRowView: View {
    @Environment(\.viewContext)
    var context: ViewContext
    @Environment(\.addressBook)
    var addressBook: AddressBook
    
    let model: PURLModel
    
    let cardColor: Color
    let cardPadding: CGFloat
    let cardradius: CGFloat
    let showSelection: Bool
    
    init(model: PURLModel, cardColor: Color, cardPadding: CGFloat, cardradius: CGFloat, showSelection: Bool) {
        self.model = model
        self.cardColor = cardColor
        self.cardPadding = cardPadding
        self.cardradius = cardradius
        self.showSelection = showSelection
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                HStack(alignment: .bottom, spacing: 0) {
                    if context != .profile {
                        AddressIconView(address: model.owner, addressBook: addressBook)
                            .padding(.horizontal, 4)
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        if context != .profile {
                            AddressNameView(model.owner)
                        }
                        Text("/\(model.name)")
                            .font(.title2)
                            .bold()
                            .fontDesign(.serif)
                            .foregroundStyle(.primary)
                            .lineLimit(3)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                if let caption = context != .detail ? DateFormatter.relative.string(for: model.date) ?? model.listCaption : model.listCaption {
                    Text(caption)
                        .multilineTextAlignment(.trailing)
                        .font(.caption2)
                        .foregroundStyle(.primary)
                        .truncationMode(.head)
                }
            }
            .padding(.top, 6)
            .padding(4)
            .padding(.horizontal, 4)
            
            VStack(alignment: .leading, spacing: 8) {
                if !model.content.isEmpty {
                    Text(model.content)
                        .font(.body)
                        .fontDesign(.monospaced)
                        .lineLimit(5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.secondary)
                }
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity)
            .asCard(color: cardColor, material: .regular, padding: cardPadding, radius: cardradius)
        }
        .asCard(color: cardColor, padding: 0, radius: cardradius, selected: showSelection)
        .frame(maxWidth: .infinity)
    }
}

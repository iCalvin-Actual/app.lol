//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct PasteRowView: View {
    @Environment(\.viewContext)
    var context: ViewContext
    @Environment(\.addressBook)
    var addressBook: AddressBook
    
    let model: PasteModel
    
    let cardColor: Color
    let cardPadding: CGFloat
    let cardradius: CGFloat
    let showSelection: Bool
    
    init(model: PasteModel, cardColor: Color? = nil, cardPadding: CGFloat = 8, cardradius: CGFloat = 16, showSelection: Bool = false) {
        self.model = model
        self.cardColor = cardColor ?? .lolRandom(model.listTitle)
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
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Text("/\(model.name)")
                            .font(.title2)
                            .fontDesign(.serif)
                            .bold()
                            .lineLimit(context != .detail ? 3 : nil)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                if let caption = model.listCaption {
                    Text(caption)
                        .multilineTextAlignment(.trailing)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .truncationMode(.head)
                }
            }
            .padding(4)
            .padding(.top, 6)
            .padding(.horizontal, 4)
            
            VStack(alignment: .leading, spacing: 8) {
                if !model.content.isEmpty {
                    Text(model.content)
                        .font(.body)
                        .fontDesign(.rounded)
                        .lineLimit(context != .detail ? 5 : nil)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.primary)
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

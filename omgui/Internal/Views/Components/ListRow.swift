//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI
import Foundation

struct ListRow<T: Listable>: View {
    
    enum Style {
        case standard
        case smaller
        case minimal
    }
    
    let model: T
    
    var preferredStyle: Style
    
    var selected: Binding<T?>
    
    var cardColor: Color {
        .lolRandom(model.listTitle)
    }
    var cardPadding: CGFloat {
        8
    }
    var cardradius: CGFloat {
        16
    }
    var showSelection: Bool {
        selected.wrappedValue == model
    }
    
    var activeStyle: Style {
        switch isSearching {
        case true:
            return .minimal
        case false:
            return preferredStyle
        }
    }
    
    init(model: T, selected: Binding<T?> = .constant(nil), preferredStyle: Style = .standard) {
        self.model = model
        self.selected = selected
        self.preferredStyle = preferredStyle
    }
    
    @Environment(\.isSearching) var isSearching
    @Environment(\.presentListable) var present
    
    var verticalPadding: CGFloat {
        switch activeStyle {
        case .minimal:
            return 0
        case .smaller:
            return 8
        case .standard:
            return 16
        }
    }
    
    var trailingPadding: CGFloat {
        verticalPadding / 2
    }
    
    var body: some View {
        appropriateBody
            .foregroundStyle(Color.primary)
            .padding(2)
            .animation(.easeInOut(duration: 0.42), value: selected.wrappedValue)
            .contentShape(RoundedRectangle(cornerRadius: 12))
            .onTapGesture {
                present?(model)
            }
    }
    
    @ViewBuilder
    var appropriateBody: some View {
        if let statusModel = model as? StatusModel {
            statusBody(statusModel)
        } else if let nowModel = model as? NowListing {
            gardenView(nowModel)
        } else if let purlModel = model as? PURLModel {
            purlView(purlModel)
        } else if let pasteModel = model as? PasteModel {
            pasteView(pasteModel)
        } else {
            standardBody
                .asCard(color: cardColor, padding: cardPadding, radius: cardradius, selected: showSelection)
        }
    }
    
    @ViewBuilder
    func statusBody(_ model: StatusModel) -> some View {
        StatusRowView(model: model, cardColor: cardColor, cardPadding: cardPadding, cardradius: cardradius, showSelection: showSelection)
    }
    
    @ViewBuilder
    func gardenView(_ model: NowListing) -> some View {
        GardenItemView(model: model, cardColor: cardColor, cardPadding: cardPadding, cardradius: cardradius, showSelection: showSelection)
    }
    
    @ViewBuilder
    func pasteView(_ model: PasteModel) -> some View {
        PasteRowView(model: model, cardColor: cardColor, cardPadding: cardPadding, cardradius: cardradius, showSelection: showSelection)
    }
    
    @ViewBuilder
    func purlView(_ model: PURLModel) -> some View {
        PURLRowView(model: model, cardColor: cardColor, cardPadding: cardPadding, cardradius: cardradius, showSelection: showSelection)
    }
    
    @ViewBuilder
    var standardBody: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .bottom) {
                AddressIconView(address: model.addressName, size: 55)
                AddressNameView(model.listTitle, font: .headline)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            let subtitle = model.listSubtitle
            let caption = model.listCaption ?? ""
            let hasMoreText: Bool = !subtitle.isEmpty || !caption.isEmpty
            if hasMoreText {
                HStack(alignment: .bottom) {
                    Text(subtitle)
                        .foregroundStyle(.primary)
                        .font(.headline)
                        .bold()
                        .fontDesign(.monospaced)
                        .lineLimit(5)
                    Spacer()
                    Text(caption)
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                        .fontDesign(.rounded)
                }
                .padding(.trailing, trailingPadding)
            }
        }
    }
}

#Preview {
    let name: AddressName = "calvin"
    ScrollView {
        VStack {
//            AddressSummaryHeader(expandBio: $expanded, addressBioFetcher: .init(address: name, interface: SampleData()))
//            ListRow(model: AddressModel.sample(with: name))
//                .environment(\.viewContext, .column)
//            ListRow(model: AddressModel.sample(with: name))
//                .environment(\.viewContext, .profile)
//            ListRow(model: AddressModel.sample(with: name))
//                .environment(\.viewContext, .detail)
            
            
            ListRow(model: NowListing.sample(with: name))
                .environment(\.viewContext, .column)
            
            ListRow(model: PURLModel.sample(with: name))
                .environment(\.viewContext, .column)
            ListRow(model: PURLModel.sample(with: name))
                .environment(\.viewContext, .profile)
            ListRow(model: PURLModel.sample(with: name))
                .environment(\.viewContext, .detail)
            
            
            ListRow(model: PasteModel.sample(with: name))
                .environment(\.viewContext, .column)
            ListRow(model: PasteModel.sample(with: name))
                .environment(\.viewContext, .profile)
            ListRow(model: PasteModel.sample(with: name))
                .environment(\.viewContext, .detail)
            
            
            ListRow(model: StatusModel.sample(with: name))
                .environment(\.viewContext, .column)
            ListRow(model: StatusModel.sample(with: name))
                .environment(\.viewContext, .profile)
            ListRow(model: StatusModel.sample(with: name))
                .environment(\.viewContext, .detail)
        }
        .padding(.horizontal)
    }
    .environment(SceneModel.sample)
    .background(Color.lolPurple)
}

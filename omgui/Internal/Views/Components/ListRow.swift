//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI
import Foundation

struct ListRow<T: Listable>: View {
    @Environment(\.addressBook) var addressBook
    @Environment(\.viewContext) var context
    @Environment(\.pinAddress) var pin
    @Environment(\.unpinAddress) var unpin
    @Environment(\.blockAddress) var block
    @Environment(\.unblockAddress) var unblock
    @Environment(\.followAddress) var follow
    @Environment(\.unfollowAddress) var unfollow
    @Environment(\.isSearching) var isSearching
    @Environment(\.presentListable) var present
    
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
        16
    }
    var cardRadius: CGFloat {
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
    
    let menuBuilder = ContextMenuBuilder<T>()
    
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
            .animation(.easeInOut(duration: 0.42), value: selected.wrappedValue)
            .contentShape(RoundedRectangle(cornerRadius: 12))
            .onTapGesture {
                present?(model.rowDestination())
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
        }
    }
    
    @ViewBuilder
    func statusBody(_ model: StatusModel) -> some View {
        StatusRowView(model: model, cardColor: cardColor, cardPadding: cardPadding, cardRadius: cardRadius, showSelection: showSelection)
    }
    
    @ViewBuilder
    func gardenView(_ model: NowListing) -> some View {
        GardenItemView(model: model, cardColor: cardColor, cardPadding: cardPadding, cardRadius: cardRadius, showSelection: showSelection)
    }
    
    @ViewBuilder
    func pasteView(_ model: PasteModel) -> some View {
        PasteRowView(model: model, cardColor: cardColor, cardPadding: cardPadding, cardRadius: cardRadius, showSelection: showSelection)
    }
    
    @ViewBuilder
    func purlView(_ model: PURLModel) -> some View {
        PURLRowView(model: model, cardColor: cardColor, cardPadding: cardPadding, cardRadius: cardRadius, showSelection: showSelection)
    }
    
    @ViewBuilder
    var standardBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            RowHeader(model: model) {
                Text("/profile")
                    .fontDesign(.serif)
                    .font(.subheadline)
            }
            
            Text(
                model.listSubtitle.isEmpty
                    ? "\(model.addressName).omg.lol"
                    : String(model.listSubtitle.replacingOccurrences(of: "https://", with: ""))
            )
            .font(.callout)
            .foregroundStyle(.primary)
            .fontDesign(.monospaced)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(8)
            .asCard(material: .regular, padding: 0, radius: cardRadius)
            .padding(.horizontal, 4)
            
            RowFooter(model: model) { EmptyView() }
        }
        .asCard(padding: cardPadding, radius: cardRadius, selected: showSelection)
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
    .background(Color.lolPurple)
}

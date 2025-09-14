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
    
    @Binding
        var selected: T?
    
    var cardColor: Color {
        .lolRandom(model.listTitle)
    }
    var cardPadding: CGFloat { 16 }
    var cardRadius: CGFloat { cardPadding }
    var showSelection: Bool { selected == model }
    
    let model: T
    
    init(model: T, selected: Binding<T?> = .constant(nil)) {
        self.model = model
        self._selected = selected
    }
    
    let menuBuilder = ContextMenuBuilder<T>()
    
    var body: some View {
        appropriateBody
            .animation(.easeInOut(duration: 0.42), value: selected)
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
        } else if let picModel = model as? PicModel {
            picView(picModel)
        } else {
            standardBody
        }
    }
    
    @ViewBuilder
    func statusBody(_ model: StatusModel) -> some View {
        StatusRowView(
            model: model,
            cardColor: cardColor,
            cardPadding: cardPadding,
            cardRadius: cardRadius,
            showSelection: showSelection
        )
    }
    
    @ViewBuilder
    func gardenView(_ model: NowListing) -> some View {
        GardenItemView(
            model: model,
            cardColor: cardColor,
            cardPadding: cardPadding,
            cardRadius: cardRadius,
            showSelection: showSelection
        )
    }
    
    @ViewBuilder
    func picView(_ model: PicModel) -> some View {
        PicRowView(
            model: model,
            cardColor: cardColor,
            cardPadding: cardPadding,
            cardRadius: cardRadius,
            showSelection: showSelection
        )
    }
    
    @ViewBuilder
    func pasteView(_ model: PasteModel) -> some View {
        PasteRowView(
            model: model,
            cardColor: cardColor,
            cardPadding: cardPadding,
            cardRadius: cardRadius,
            showSelection: showSelection
        )
    }
    
    @ViewBuilder
    func purlView(_ model: PURLModel) -> some View {
        PURLRowView(
            model: model,
            cardColor: cardColor,
            cardPadding: cardPadding,
            cardRadius: cardRadius,
            showSelection: showSelection
        )
    }
    
    @ViewBuilder
    var standardBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            RowHeader(model: model) {
                EmptyView()
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

#Preview {
    let name: AddressName = "calvin"
    ScrollView {
        VStack {
            ListRow(model: AddressModel.sample(with: name))
                .environment(\.viewContext, .column)
            ListRow(model: AddressModel.sample(with: name))
                .environment(\.viewContext, .profile)
            ListRow(model: AddressModel.sample(with: name))
                .environment(\.viewContext, .detail)
            
            
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

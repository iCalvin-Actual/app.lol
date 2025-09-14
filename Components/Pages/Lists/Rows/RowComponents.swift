//
//  RowHeader.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/14/25.
//

import SwiftUI


struct RowHeader<T: Listable, V: View>: View {
    @Environment(\.viewContext)
        var context
    
    var showMenu: Bool {
        #if os(macOS)
        return false
        #else
        context != .detail
        #endif
    }
    
    let model: T
    let cornerView: () -> V
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            if context != .profile {
                AddressIconView(address: model.addressName, showMenu: showMenu, contentShape: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 2)
                    .buttonStyle(.borderless)
            }
            HStack (alignment: .lastTextBaseline, spacing: 4) {
                VStack(alignment: .leading, spacing: 2) {
                    if let caption = DateFormatter.relative.string(for: model.displayDate) ?? model.listCaption {
                        Text(caption)
                            .multilineTextAlignment(.leading)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .truncationMode(.tail)
                    }
                    AddressNameView(model.addressName, font: .headline)
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                cornerView()
            }
        }
        .padding(.top, 4)
        .padding(.horizontal, 4)
        .padding(4)
    }
}

struct RowFooter<T: Listable, A: View>: View {
    @Environment(\.addressBook) var addressBook
    @Environment(\.pinAddress) var pin
    @Environment(\.unpinAddress) var unpin
    @Environment(\.blockAddress) var block
    @Environment(\.unblockAddress) var unblock
    @Environment(\.followAddress) var follow
    @Environment(\.unfollowAddress) var unfollow
    @Environment(\.presentListable) var present
    
    let model: T
    
    @ViewBuilder let accessoryBuilder: () -> A
    
    let menuBuilder = ContextMenuBuilder<T>()
    
    var body: some View {
        HStack(alignment: .top) {
            if let date = model.displayDate {
                Text(DateFormatter.short.string(from: date))
                    .font(.caption)
                    .padding(.horizontal, 4)
            }
            Spacer()
            accessoryBuilder()
            Menu {
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
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .buttonStyle(.borderless)
        }
        .foregroundStyle(.secondary)
        .padding(4)
        .padding(.leading, 4)
    }
}

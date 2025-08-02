//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 9/11/24.
//

import SwiftUI

struct SafetyView: View {
    @Environment(\.addressBook)
    var addressBook
    
    @Environment(\.pinAddress) var pin
    @Environment(\.unpinAddress) var unpin
    @Environment(\.blockAddress) var block
    @Environment(\.unblockAddress) var unblock
    @Environment(\.followAddress) var follow
    @Environment(\.unfollowAddress) var unfollow
    
    var menuBuilder: ContextMenuBuilder<AddressModel> = .init()
    
    @State
    var selected: AddressModel?
    
    @ViewBuilder
    var body: some View {
        List(selection: $selected) {
            Section("reach out") {
                Text("if you need to reach out for help with another address, for any reason, do not hesitate.")
                    .multilineTextAlignment(.leading)
                ReportButton()
            }
            .foregroundStyle(.primary)
#if !os(tvOS) && !os(macOS)
            .listRowBackground(Color(UIColor.systemBackground).opacity(0.82))
            #endif
            
            Section("blocked") {
                if addressBook.blocked.isEmpty {
                    Text("If you wan't to stop seeing content from an address, Long Press the address or avatar and select Safety > Block")
                } else {
                    ForEach(addressBook.blocked.map({ AddressModel(name: $0) })) { item in
                        ListRow(model: item)
                            .tag(item)
                        #if !os(tvOS)
                            .listRowSeparator(.hidden, edges: .all)
                        #endif
                            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .contextMenu(menuItems: {
                                menuBuilder.contextMenu(
                                    for: item,
                                    fetcher: nil,
                                    addressBook: addressBook,
                                    menuFetchers: (
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
            }
            .foregroundStyle(.primary)
            #if canImport(UIKit) && !os(tvOS)
            .listRowBackground(Color(UIColor.systemBackground).opacity(0.82))
            #endif
        }
        #if !os(tvOS)
        .scrollContentBackground(.hidden)
        #endif
    }
}

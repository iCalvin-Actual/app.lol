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
                if (addressBook?.visibleBlocked ?? []).isEmpty {
                    Text("If you wan't to stop seeing content from an address, Long Press the address or avatar and select Safety > Block")
                } else if let addressBook {
                    ForEach(addressBook.visibleBlocked.map({ AddressModel(name: $0) })) { item in
                        ListRow(model: item)
                            .tag(item)
                        #if !os(tvOS)
                            .listRowSeparator(.hidden, edges: .all)
                        #endif
                            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .contextMenu(menuItems: {
                                menuBuilder.contextMenu(for: item, fetcher: nil, addressBook: addressBook)
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

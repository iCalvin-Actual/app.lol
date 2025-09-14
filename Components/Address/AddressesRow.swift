//
//  AddressesRow.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/14/25.
//

import SwiftUI

struct AddressesRow: View {
    @Environment(\.dismiss)
        var dismiss
    @Environment(\.presentListable)
        var present
    @Environment(\.horizontalSizeClass)
        var sizeClass
    
    let addresses: [AddressSummaryFetcher]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 0) {
                ForEach(addresses, id: \.addressName) { standardCard($0) }
                Spacer()
            }
        }
        .animation(.default, value: addresses.map(\.addressName))
        .background(Material.regular)
    }
    
    @ViewBuilder
    func standardCard(_ fetcher: AddressSummaryFetcher, _ colorToUse: Color? = nil) -> some View {
        
        let address = fetcher.addressName
        if let present {
            Button {
                if sizeClass == .compact {
                    dismiss()
                }
                present(.address(address, page: .profile))
            } label: {
                card(address, colorToUse)
            }
            .buttonStyle(.plain)
        } else {
            NavigationLink(value: NavigationDestination.address(address, page: .profile)) {
                card(address, colorToUse)
            }
        }
    }
    
    @ViewBuilder
    func card(_ address: AddressName, _ colorToUse: Color?) -> some View {
        AddressCard(address)
            .background(colorToUse)
    }
}

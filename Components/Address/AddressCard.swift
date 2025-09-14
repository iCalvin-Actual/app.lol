//
//  AddressCard.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/14/25.
//

import SwiftUI


struct AddressCard: View {
    let address: AddressName
    let embedInMenu: Bool
    
    init(_ address: AddressName, embedInMenu: Bool = false) {
        self.address = address
        self.embedInMenu = embedInMenu
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            AddressIconView(address: address, size: 55, showMenu: embedInMenu)
            Text(address.addressDisplayString)
                .font(.caption)
                .fontDesign(.serif)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.trailing)
                .lineLimit(3)
        }
        .padding(12)
    }
}

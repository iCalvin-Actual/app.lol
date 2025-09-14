//
//  AddressPreviewButton.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/14/25.
//

import SwiftUI


struct AddressPreviewButton: View {
    
    @Binding
        var page: AddressContent
    
    let address: AddressName
    let theme: ThemeModel?
    
    var body: some View {
        HStack(spacing: 2) {
#if !os(macOS) && !os(visionOS)
            AddressIconView(
                address: address,
                size: 30,
                showMenu: false,
                contentShape: Circle()
            )
                .frame(width: 30, height: 30)
#endif
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                AddressNameView(address, font: .headline)
                    .bold()
                    .foregroundStyle(theme?.foregroundColor ?? .primary)
                    .lineLimit(2)
                if page == .now {
                    ThemedTextView(text: page.displayString, font: .headline)
                }
            }
#if os(macOS)
            .padding(.horizontal)
#endif
        }
    }
}


//
//  AddressPrincipalView.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/14/25.
//

import SwiftUI


struct AddressPrincipalView: View {
    @Environment(\.dismiss)
        var dismiss
    
    @Environment(\.addressBook)
        var addressBook
    @Environment(\.showAddressPage)
        var showPage
    
    @State
        var presentSummary: Bool = false
    
    let fetcher: AddressSummaryFetcher
    
    @Binding
        var addressPage: AddressContent
    
    var body: some View {
        Button {
            withAnimation {
                presentSummary.toggle()
            }
        } label: {
            AddressPreviewButton(
                page: $addressPage,
                address: fetcher.addressName,
                theme: fetcher.profileFetcher.theme
            )
        }
#if os(visionOS)
        .buttonStyle(.borderless)
#endif
        .popover(isPresented: $presentSummary) {
            AddressPreview(
                fetcher: fetcher,
                page: .init(
                    get: { addressPage },
                    set: {
                        presentSummary = false
                        addressPage = $0
                    }
                )
            )
            .padding(2)
            .environment(\.showAddressPage, showPage)
            .environment(\.visibleAddressPage, addressPage)
            .environment(\.addressBook, addressBook)
        }
    }
}

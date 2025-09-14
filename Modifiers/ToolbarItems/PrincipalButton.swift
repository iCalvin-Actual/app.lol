//
//  PrincipalButton.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/14/25.
//

import SwiftUI

fileprivate struct PrincipalToolbarModifier: ViewModifier {
    let conditional: Bool
    let summaryFetcher: AddressSummaryFetcher?
    @Binding var addressPage: AddressContent
    
    init(
        conditional: Bool = true,
        summaryFetcher: AddressSummaryFetcher?,
        addressPage: Binding<AddressContent>
    ) {
        self.conditional = conditional
        self.summaryFetcher = summaryFetcher
        self._addressPage = addressPage
    }

    func body(content: Content) -> some View {
        content
            .toolbar {
                if conditional, let summaryFetcher {
                    ToolbarItem(placement: .safePrincipal) {
                        AddressPrincipalView(
                            fetcher: summaryFetcher,
                            addressPage: $addressPage
                        )
                    }
                }
            }
    }
}

extension View {
    func principalAddressItem(
        _ conditional: Bool = true,
        summaryFetcher: AddressSummaryFetcher?,
        addressPage: Binding<AddressContent>
    ) -> some View {
        self.modifier(PrincipalToolbarModifier(conditional: conditional, summaryFetcher: summaryFetcher, addressPage: addressPage))
    }
}

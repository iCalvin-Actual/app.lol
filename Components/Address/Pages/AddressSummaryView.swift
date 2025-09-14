//
//  File.swift
//
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI
import WebKit
import MarkdownUI

struct AddressSummaryView: View {
    @Environment(\.colorSchemeContrast)
        var contrast
    @Environment(\.showAddressPage)
        var showPage
    @Environment(\.destinationConstructor)
        var destinationConstructor
    @Environment(\.apiInterface)
        var apiInterface
    @Environment(\.blackbird)
        var database
    @Environment(\.addressSummaryFetcher)
        var summaryFetchers
    
    @State
        var addressSummaryFetcher: AddressSummaryFetcher = .init(
            name: "",
            addressBook: .init()
        )
    
    @State
        var presentBio: Bool = false
    @State
        var expandBio: PresentationDetent = .medium
    
    @State
        var addressPage: AddressContent
    
    let address: AddressName
    let addressBook: AddressBook
    
    
    init(_ addressName: AddressName, addressBook: AddressBook, page: AddressContent = .profile) {
        self.address = addressName
        self.addressBook = addressBook
        self.addressPage = page
    }
    
    var body: some View {
        destinationConstructor?
            .destination(
                addressPage.destination(addressSummaryFetcher.addressName),
                contrast: contrast
            )
            .id(addressSummaryFetcher.addressName)
            .background(Color.clear)
            .navigationSplitViewColumnWidth(min: 250, ideal: 600)
            .principalAddressItem(summaryFetcher: addressSummaryFetcher, addressPage: $addressPage)
            .environment(\.viewContext, .profile)
            .task { @MainActor in
                let newFetcher = summaryFetchers(address) ?? .init(name: address, addressBook: addressBook)
                self.addressSummaryFetcher = newFetcher
                await newFetcher.updateIfNeeded()
            }
    }
}


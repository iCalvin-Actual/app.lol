//
//  File.swift
//
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI
import WebKit

struct AddressSummaryView: View {
    @Environment(\.showAddressPage)
    var showPage
    @Environment(\.visibleAddressPage)
    var visiblePage
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass
    @Environment(\.visibleAddressPage)
    var addressPage
    @Environment(\.destinationConstructor)
    var destinationConstructor
    @Environment(\.apiInterface)
    var apiInterface
    @Environment(\.blackbird)
    var database
    
    @StateObject
    var addressSummaryFetcher: AddressSummaryDataFetcher
    
    @State
    var expandBio: Bool = false
    
    let address: AddressName
    let addressBook: AddressBook
    
    private var allPages: [AddressContent] {
        [
            .profile,
            .now,
            .statuslog,
            .pastebin,
            .purl
        ]
    }
    
    init(_ addressName: AddressName, addressBook: AddressBook) {
        self.address = addressName
        self.addressBook = addressBook
        self._addressSummaryFetcher = .init(wrappedValue: .init(name: addressName, addressBook: .init(), interface: AppClient.interface))
    }
    
    var body: some View {
        sizeAppropriateBody
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Menu {
                        ForEach(allPages) { page in
                            Button {
                                showPage(page)
                            } label: {
                                Label {
                                    Text(page.displayString)
                                } icon: {
                                    if page == visiblePage {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                        Button {
                            withAnimation {
                                expandBio = addressSummaryFetcher.bioFetcher.bio != nil
                            }
                        } label: {
                            Text("Bio")
                        }
                        .disabled(addressSummaryFetcher.bioFetcher.bio == nil)
                    } label: {
                        HStack(spacing: 2) {
                            AddressIconView(address: address, addressBook: addressBook, size: 30, contentShape: Circle())
                                .frame(width: 30, height: 30)
                            Text(address.addressDisplayString)
                                .font(.headline)
                                .foregroundStyle(.primary)
                        }
                    }
                    .padding(12)
                    .glassEffect()
                }
            }
            .environment(\.viewContext, .profile)
            .task { @MainActor [weak addressSummaryFetcher] in
                await addressSummaryFetcher?.updateIfNeeded()
            }
            .sheet(isPresented: $expandBio) {
                ScrollView {
                    VStack {
                        HStack {
                            AddressIconView(address: address, addressBook: addressBook)
                            AddressNameView(address)
                        }
                        .padding()
                        Text({
                            let givenBio = addressSummaryFetcher.bioFetcher.bio?.bio
                            let markdown = AttributedString(markdown: givenBio)
                            return ""
                        }())
                        Text(addressSummaryFetcher.bioFetcher.bio?.bio ?? "No bio")
                    }
                    .padding()
                }
            }
    }
    
    @ViewBuilder
    var sizeAppropriateBody: some View {
        if horizontalSizeClass == .regular {
            destination(addressPage)
        } else {
            destination(addressPage)
        }
    }
    
    @ViewBuilder
    func destination(_ item: AddressContent? = nil) -> some View {
        let workingItem = item ?? .profile
        destinationConstructor?.destination(workingItem.destination(addressSummaryFetcher.addressName))
            .background(Color.clear)
            .navigationSplitViewColumnWidth(min: 250, ideal: 600)
    }
    
    func fetcherForContent(_ content: AddressContent) -> Request {
        switch content {
        case .now:
            return addressSummaryFetcher.nowFetcher ?? .init(addressName: addressSummaryFetcher.nowFetcher?.address ?? "")
        case .pastebin:
            return addressSummaryFetcher.pasteFetcher
        case .purl:
            return addressSummaryFetcher.purlFetcher
        case .profile:
            return addressSummaryFetcher.profileFetcher ?? .init(addressName: addressSummaryFetcher.profileFetcher?.address ?? "")
        case .statuslog:
            return addressSummaryFetcher.statusFetcher
        }
    }
}

struct AddressBioLabel: View {
    @Environment(\.viewContext)
    var context
    
    @Binding
    var expanded: Bool
    
    @ObservedObject
    var addressBioFetcher: AddressBioDataFetcher
    
    var body: some View {
        if addressBioFetcher.loaded == nil {
            LoadingView()
                .task { @MainActor [addressBioFetcher] in
                    if addressBioFetcher.loaded == nil {
                        await addressBioFetcher.updateIfNeeded()
                    }
                }
        } else if addressBioFetcher.loading {
            LoadingView()
        } else if let content = addressBioFetcher.bio?.bio, !content.isEmpty {
            contentView(content)
                .onTapGesture {
                    withAnimation {
                        expanded.toggle()
                    }
                }
        } else if context != .profile {
            AddressNameView(addressBioFetcher.address)
        } else {
            Spacer()
        }
    }
    
    @ViewBuilder
    func contentView(_ bio: String) -> some View {
        if expanded {
            ScrollView {
                MarkdownContentView(content: bio)
            }
        } else {
            Text(bio)
                .lineLimit(3)
                .font(.callout)
                .fontDesign(.rounded)
        }
    }
}

struct AddressSummaryHeader: View {
    @Environment(\.addressBook) var addressBook
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass
    @Environment(\.visibleAddressPage)
    var addressPage
    @Environment(\.showAddressPage)
    var showPage
    
    var expandBio: Binding<Bool>
    
    @ObservedObject
    var addressBioFetcher: AddressBioDataFetcher
    
    let allPages: [AddressContent]
    
    init(expandBio: Binding<Bool>, addressBioFetcher: AddressBioDataFetcher, allPages: [AddressContent] = [], selection: Binding<AddressContent>? = nil) {
        self.expandBio = expandBio
        self.addressBioFetcher = addressBioFetcher
        self.allPages = allPages
    }
    
    var body: some View {
        HStack {
            AddressIconView(address: addressBioFetcher.address, addressBook: addressBook, showMenu: true, contentShape: Circle())
            destinationPicker
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.leading, 4)
        .padding(.trailing, 8)
        .glassEffect(.regular)
    }
    
    @ViewBuilder
    var destinationPicker: some View {
        Picker("Page", selection: .init(get: {
            addressPage
        }, set: { newValue in
            showPage(newValue)
        })) {
            ForEach(allPages) { page in
                Text(page.displayString)
                    .tag(page)
            }
        }
        .pickerStyle(.menu)
        .frame(maxHeight: 44)
    }
}

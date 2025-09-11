//
//  File.swift
//
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct Sidebar: View {
    
    @Environment(\.horizontalSizeClass)
    var horizontalSize
    @Environment(\.addressBook)
    var addressBook
    @Environment(\.setAddress)
    var setAddress
    @Environment(\.destinationConstructor)
    var destinationConstructor
    @Environment(\.pinnedFetcher)
    var pinned
    
    @SceneStorage("app.tab.selected")
    var selected: NavigationItem?
    
    @State
    var expandAddresses: Bool = false
    
    var sidebarModel: NavigationModel {
        .init(addressBook: addressBook)
    }
    
    private var myAddresses: [AddressName] {
        addressBook.mine
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                LogoView()
                    .frame(height: 34)
                ThemedTextView(text: "app.lol", font: .title)
                Spacer()
            }
            List(selection: .init(get: {
                selected
            }, set: { newValue in
                selected = newValue
            })) {
                ForEach(sidebarModel.sections) { section in
                    let items = sidebarModel.items(for: section, sizeClass: horizontalSize, context: .column)
                    if !items.isEmpty {
                        Section {
                            ForEach(items) { item in
                                item.sidebarView
                                    .tag(item)
                                    .contextMenu(menuItems: {
                                        contextMenu(for: item)
                                    })
                            }
                        } header: {
                            Text(section.displayName)
                                .fontDesign(.monospaced)
                                .font(.subheadline)
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
        }
        .environment(\.viewContext, ViewContext.column)
    }
    
    private func isActingAddress(_ address: AddressName) -> Bool {
        guard !address.isEmpty else {
            return false
        }
        return addressBook.me == address
    }
    
    @ViewBuilder
    private func contextMenu(for item: NavigationItem) -> some View {
        switch item {
        case .pinnedAddress(let address):
            Button(action: {
                Task { [weak pinned] in
                    await pinned?.removePin(address)
                }
            }, label: {
                Label("Un-Pin \(address.addressDisplayString)", systemImage: "pin.slash")
            })
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    func destinationView(_ destination: NavigationDestination? = .webpage("app")) -> some View {
        destinationConstructor?.destination(destination)
    }
}

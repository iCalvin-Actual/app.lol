//
//  File.swift
//
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct Sidebar: View {
    
    let actingAddress: AddressName
    
    @Environment(\.horizontalSizeClass)
    var horizontalSize
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    
    @State
    var expandAddresses: Bool = false
    
    @Binding
    var selected: NavigationItem?
    
    let sidebarModel: SidebarModel
    
    private var myAddresses: [AddressName] {
        sceneModel.addressBook.myAddresses
    }
    
    init(selected: Binding<NavigationItem?>, model: SidebarModel, acting: AddressName) {
        self.actingAddress = acting
        self._selected = selected
        self.sidebarModel = model
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
            List(selection: $selected) {
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
        actingAddress == address
    }
    
    @ViewBuilder
    private func contextMenu(for item: NavigationItem) -> some View {
        switch item {
        case .pinnedAddress(let address):
            let addressBook = sceneModel.addressBook
            let pinnedAddressFetcher = sidebarModel.pinnedFetcher
            Button(action: {
                Task { @MainActor in
                    await addressBook.removePin(address)
                    await pinnedAddressFetcher.updateIfNeeded(forceReload: true)
                }
            }, label: {
                Label("Un-Pin \(address.addressDisplayString)", systemImage: "pin.slash")
            })
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private var addressPickerSection: some View {
        if !myAddresses.isEmpty {
            Section {
                ForEach(myAddresses) { address in
                    Button {
                        Task {
                            sceneModel.addressBook.actingAddress.wrappedValue = address
                        }
                    } label: {
                        addressOption(address)
                    }
                }
            } header: {
                Text("Select active address")
            }
        }
    }
    
    @ViewBuilder
    private func addressOption(_ address: AddressName) -> some View {
        if isActingAddress(address) {
            Label(address, systemImage: "checkmark")
        } else {
            Label(title: { Text(address) }, icon: { EmptyView() })
        }
    }
    
    @ViewBuilder
    func destinationView(_ destination: NavigationDestination? = .webpage("app")) -> some View {
        sceneModel.destinationConstructor.destination(destination)
    }
}

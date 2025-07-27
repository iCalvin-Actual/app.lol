//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 9/1/24.
//

import SwiftUI

struct AddressesRow: View {
    @Environment(\.setAddress)
    var setAddress
    @Environment(\.addressBook)
    var addressBook
    @Environment(\.dismiss)
    var dismiss
    @Environment(\.presentListable)
    var present
    
    var color: Color {
    #if canImport(UIKit)
        return Color(uiColor: .systemBackground)
    #else
        return Color(nsColor: .windowBackgroundColor)
    #endif
    }
    
    let addresses: [AddressName]
    let selection: Bool
    
    init(addresses: [AddressName], selection: Bool = false) {
        self.addresses = addresses
        self.selection = selection
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 0) {
                ForEach(addresses, id: \.self) { address in
                    if address == addressBook.me {
                        standardCard(address, color)
                    } else {
                        if selection {
                            addressSelectionCard(address)
                        } else {
                            standardCard(address)
                        }
                    }
                }
                Spacer()
            }
        }
        .animation(.default, value: addresses)
        .background(Material.regular)
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 12, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 12, style: .continuous))
    }
    
    @ViewBuilder
    func addressSelectionCard(_ address: AddressName) -> some View {
        Button {
            withAnimation {
                setAddress(address)
            }
        } label: {
            card(address, nil)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    func standardCard(_ address: AddressName, _ colorToUse: Color? = nil) -> some View {
        if let present {
            Button {
                dismiss()
                present(AddressModel(name: address))
            } label: {
                card(address, colorToUse)
            }
            .buttonStyle(.plain)
        } else {
            NavigationLink(value: NavigationDestination.address(address)) {
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

struct AccountView: View {
    @Environment(\.authenticate)
    var authenticate
    
    @SceneStorage("lol.address")
    var actingAddress: AddressName = ""
    
    @Environment(\.addressBook)
    var addressBook
    
    @Environment(\.horizontalSizeClass)
    var sizeClass
    
    let menuBuilder = ContextMenuBuilder<AddressModel>()
    
    var body: some View {
        if sizeClass == .compact {
            coreBody
        } else {
            NavigationStack { coreBody }
        }
    }
    
    @ViewBuilder
    var coreBody: some View {
        if addressBook.signedIn {
            authenticatedBody
        } else {
            Text("Benefits of an account!")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    @ViewBuilder
    var authenticatedBody: some View {
        List {
            Section("Lists") {
                // Mine addresses horizontal scroll section
                if !addressBook.mine.isEmpty {
                    Section {
                        AddressesRow(addresses: addressBook.mine, selection: true)
                    } header: {
                        Label {
                            Text("mine")
                        } icon: {
                            Image(systemName: "person")
                        }
                        .foregroundStyle(.secondary)
                        .font(.callout)
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .listRowSeparator(.hidden)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Material.ultraThin)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(Color.clear)
                }
                
                // Following horizontal scroll section
                if !addressBook.following.isEmpty {
                    Section {
                        AddressesRow(addresses: addressBook.following)
                    } header: {
                        Label {
                            Text("following")
                        } icon: {
                            Image(systemName: "at")
                        }
                        .foregroundStyle(.secondary)
                        .font(.callout)
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .listRowSeparator(.hidden)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Material.ultraThin)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(Color.clear)
                }
                
                // Followers horizontal scroll section
                if !addressBook.followers.isEmpty {
                    Section {
                        AddressesRow(addresses: addressBook.followers)
                    } header: {
                        Label {
                            Text("followers")
                        } icon: {
                            Image(systemName: "at")
                        }
                        .foregroundStyle(.secondary)
                        .font(.callout)
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .listRowSeparator(.hidden)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Material.ultraThin)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(Color.clear)
                }
            }
            
            // Logout button row as non-selectable content
            if addressBook.signedIn && sizeClass == .compact {
                // Wrap in a Group to avoid affecting List selection
                Group {
                    Button(role: .destructive, action: {
                        authenticate("")
                    }) {
                        Label {
                            Text("log out")
                        } icon: {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                        }
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                    #if canImport(UIKit)
                    .listRowBackground(Color(UIColor.systemBackground).opacity(0.82))
                    #endif
                }
            }
        }
        .animation(.default, value: addressBook.signedIn)
        .animation(.default, value: addressBook.following)
        .animation(.default, value: addressBook.followers)
        .animation(.default, value: addressBook.pinned)
        .animation(.default, value: addressBook.mine)
        .frame(maxWidth: 800)
        .frame(maxWidth: .infinity)
        .environment(\.defaultMinListRowHeight, 0)
        .safeAreaInset(edge: .bottom, content: {
            if !addressBook.signedIn || sizeClass == .regular {
                AuthenticateButton()
            }
        })
        #if !os(tvOS)
        .scrollContentBackground(.hidden)
        #endif
    }
}

struct AuthenticateButton: View {
    @Environment(AccountAuthDataFetcher.self)
    var accountFetcher
    @Environment(\.addressBook) var addressBook
    
    var body: some View {
        if !addressBook.signedIn {
            Button(action: {
                accountFetcher.perform()
            }) {
                Text("sign in with omg.lol")
                    .bold()
                    .font(.callout)
                    .fontDesign(.serif)
                    .frame(maxWidth: .infinity)
                    .padding(3)
            }
            .buttonStyle(.borderedProminent)
            .accentColor(.lolPink)
            .buttonBorderShape(.roundedRectangle(radius: 6))
            .padding()
        } else {
            Button(action: {
                accountFetcher.logout()
            }) {
                Label {
                    Text("log out")
                } icon: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                }
                .bold()
                .font(.callout)
                .fontDesign(.serif)
                .frame(maxWidth: .infinity)
                .padding(3)
            }
            .buttonStyle(.borderedProminent)
            .accentColor(.lolPink)
            .buttonBorderShape(.roundedRectangle(radius: 6))
            .padding()
        }
    }
}

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
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
                .lineLimit(3)
        }
        .padding(12)
    }
}

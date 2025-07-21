//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 9/1/24.
//

import SwiftUI

struct AddressesRow: View {
    let addresses: [AddressName]
    var selection: Binding<AddressName>?
    
    @Environment(\.presentAddress)
    var present
    
    var color: Color {
    #if canImport(UIKit)
        return Color(uiColor: .systemBackground)
    #else
        return Color(nsColor: .windowBackgroundColor)
    #endif
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 0) {
                ForEach(addresses, id: \.self) { address in
                    if address == selection?.wrappedValue {
                        standardCard(address, color)
                    } else {
                        if selection != nil {
                            addressSelectionCard(address)
                        } else {
                            standardCard(address)
                        }
                    }
                }
                Spacer()
            }
        }
        .background(Material.regular)
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 12, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 12, style: .continuous))
    }
    
    @ViewBuilder
    func addressSelectionCard(_ address: AddressName) -> some View {
        Button {
            withAnimation {
                selection?.wrappedValue = address
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
                present(address)
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
    @Environment(\.login) var login
    @Environment(\.logout) var logout
    
    @SceneStorage("app.lol.address")
    var actingAddress: AddressName = ""
    
    let viewModel: AccountViewModel
    
    @Environment(\.addressBook)
    var addressBook
    
    @State
    var selected: NavigationItem?
    
    @Environment(\.horizontalSizeClass)
    var sizeClass
    
    let menuBuilder = ContextMenuBuilder<AddressModel>()
    
    var selectedAddress: Binding<AddressName>? {
        let address = addressBook?.actingAddress ?? ""
        guard !address.isEmpty else {
            return nil
        }
        return .init(get: {
            address
        }, set: { new in
            actingAddress = new
        })
    }
    
    var body: some View {
        if sizeClass == .compact {
            coreBody
        } else {
            NavigationStack { coreBody }
        }
    }
    
    @ViewBuilder
    var coreBody: some View {
        if addressBook?.signedIn ?? false {
            authenticatedBody
        } else {
            Text("Benefits of an account!")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    @ViewBuilder
    var authenticatedBody: some View {
        List(selection: $selected) {
            Section("Lists") {
                // Mine addresses horizontal scroll section
                if !viewModel.mine.isEmpty {
                    Section {
                        AddressesRow(addresses: viewModel.mine, selection: selectedAddress)
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
                if !viewModel.following.isEmpty {
                    Section {
                        AddressesRow(addresses: viewModel.following, selection: nil)
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
                if !viewModel.followers.isEmpty {
                    Section {
                        AddressesRow(addresses: viewModel.followers, selection: nil)
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
            if addressBook?.signedIn ?? false && sizeClass == .compact {
                // Wrap in a Group to avoid affecting List selection
                Group {
                    Button(role: .destructive, action: logout) {
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
        .animation(.default, value: addressBook?.signedIn ?? false)
        .animation(.default, value: viewModel.following)
        .animation(.default, value: viewModel.followers)
        .animation(.default, value: viewModel.pinned)
        .animation(.default, value: viewModel.mine)
        .frame(maxWidth: 800)
        .frame(maxWidth: .infinity)
        .environment(\.defaultMinListRowHeight, 0)
        .safeAreaInset(edge: .bottom, content: {
            if !(addressBook?.signedIn ?? true) || sizeClass == .regular {
                AuthenticateButton()
            }
        })
        #if !os(tvOS)
        .scrollContentBackground(.hidden)
        #endif
    }
}

struct AuthenticateButton: View {
    @Environment(\.login) var login
    @Environment(\.logout) var logout
    @Environment(\.addressBook) var addressBook
    
    var body: some View {
        if !(addressBook?.signedIn ?? true) {
            Button(action: {
                login()
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
            Button(action: logout) {
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

@MainActor
struct AccountViewModel {
    let scribble: AddressBook.Scribbled
    
    var showPinned: Bool { !pinned.isEmpty }
    var showFollowing: Bool { !following.isEmpty }
    var showFollowers: Bool { !followers.isEmpty }
    var showBlocked: Bool { !blocked.isEmpty }

    var pinned: [AddressName] {
        scribble.pinned
    }
    
    var mine: [AddressName] {
        scribble.mine
    }
    
    var following: [AddressName] {
        scribble.following
    }
    var followers: [AddressName] {
        scribble.followers
    }
    
    var blocked: [AddressName] {
        scribble.blocked
    }
}

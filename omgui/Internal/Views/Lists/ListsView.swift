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
    @Environment(\.horizontalSizeClass)
    var sizeClass
    
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
                if sizeClass == .compact {
                    dismiss()
                }
                present(.address(address))
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
        AddressCard(address, addressBook: addressBook)
            .background(colorToUse)
    }
}

struct AccountView: View {
    @Environment(\.authenticate)
    var authenticate
    @Environment(AccountAuthDataFetcher.self)
    var authFetcher
    @Environment(\.presentListable)
    var present
    
    @SceneStorage("lol.address")
    var actingAddress: AddressName = ""
    
    @Environment(\.addressBook)
    var addressBook
    
    @Environment(\.addressFollowingFetcher)
    var followingFetcher
    @Environment(\.addressFollowersFetcher)
    var followersFetcher
    
    @Environment(\.horizontalSizeClass)
    var sizeClass
    
    @State
    var confirmLogout: Bool = false
    
    let menuBuilder = ContextMenuBuilder<AddressModel>()
    
    var body: some View {
        coreBody
            .task { [weak followingFetcher, weak followersFetcher] in
                await followingFetcher?.updateIfNeeded()
                await followersFetcher?.updateIfNeeded()
            }
    }
    
    @ViewBuilder
    var coreBody: some View {
        List {
            if !addressBook.signedIn {
                Button(action: {
                    authFetcher.perform()
                }) {
                    Label {
                        Text("Sign in")
                    } icon: {
                        Image(systemName: "rectangle.portrait.and.arrow.left")
                    }
                    .bold()
                    .font(.callout)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(3)
                }
                .foregroundStyle(.primary)
#if canImport(UIKit)
                .listRowBackground(Color(UIColor.systemBackground).opacity(0.82))
#elseif os(macOS)
                .padding(.vertical, 16)
#endif
            }
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
                
                if !addressBook.pinned.isEmpty {
                    Section {
                        AddressesRow(addresses: addressBook.pinned)
                    } header: {
                        Label {
                            Text("pinned")
                        } icon: {
                            Image(systemName: "pin")
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
            
            if sizeClass == .compact {
                Section("app.lol") {
                    ForEach([NavigationItem.appSupport, NavigationItem.safety, NavigationItem.appLatest]) { item in
                        Button {
                            present?(item.destination)
                        } label: {
                            item.label
                        }
                        .foregroundStyle(.primary)
                        #if canImport(UIKit)
                        .listRowBackground(Color(UIColor.systemBackground).opacity(0.82))
                        #endif
                    }
                }
            }
            
            if addressBook.signedIn {
                Button(action: {
                    withAnimation { confirmLogout = true }
                }) {
                    Label {
                        Text("Log out")
                    } icon: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }
                    .bold()
                    .font(.callout)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(3)
                }
                .foregroundStyle(.primary)
#if canImport(UIKit)
                .listRowBackground(Color(UIColor.systemBackground).opacity(0.82))
#elseif os(macOS)
                .padding(.vertical, 16)
#endif
                .alert("Log out?", isPresented: $confirmLogout, actions: {
                    Button("Cancel", role: .cancel) { }
                    Button(
                        "Yes",
                        role: .destructive,
                        action: {
                            authenticate("")
                        })
                }, message: {
                    Text("Are you sure you want to sign out of your omg.lol account? Your pinned and blocked lists will be maintained after logout")
                })
                .contentShape(Rectangle())
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
        #if !os(tvOS)
        .scrollContentBackground(.hidden)
        #endif
    }
}

struct AuthenticateButton: View {
    @Environment(AccountAuthDataFetcher.self)
    var accountFetcher
    @Environment(\.addressBook) var addressBook
    @Environment(\.authenticate) var authenticate
    
    @State
    var confirmLogout: Bool = false
    
    var body: some View {
        if !addressBook.signedIn {
            Button(action: {
                accountFetcher.perform()
            }) {
                Label {
                    Text("sign in with omg.lol")
                        .bold()
                        .font(.callout)
                        .fontDesign(.serif)
                        .padding(4)
                } icon: {
                    Image(systemName: "key")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.borderedProminent)
            
        } else {
            Button(action: {
                withAnimation { confirmLogout = true }
            }) {
                Label {
                    Text("Log out")
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
            .buttonBorderShape(.capsule)
            .alert("Log out?", isPresented: $confirmLogout, actions: {
                Button("Cancel", role: .cancel) { }
                Button(
                    "Yes",
                    role: .destructive,
                    action: {
                        accountFetcher.logout()
                    })
            }, message: {
                Text("Are you sure you want to sign out of omg.lol?")
            })
        }
    }
}

struct AddressCard: View {
    let address: AddressName
    let addressBook: AddressBook
    let embedInMenu: Bool
    
    init(_ address: AddressName, addressBook: AddressBook, embedInMenu: Bool = false) {
        self.address = address
        self.addressBook = addressBook
        self.embedInMenu = embedInMenu
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            AddressIconView(address: address, addressBook: addressBook, size: 55, showMenu: embedInMenu)
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

//
//  AccountAccessoryView.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/14/25.
//

import SwiftUI


struct AccountAccessoryView: View {
    
    @SceneStorage("lol.highlightFollows")
        var highlightFollows: Bool = true
    
    @State
        var confirmLogout: Bool = false
    @State
        var hasShownLoginPrompt: Bool = false
    
    @Binding
        var addAddress: Bool
    
    var shouldHighlightFollows: Bool {
        highlightFollows && addressBook.signedIn && !addressBook.following.isEmpty
    }
    
    var highlights: [AddressName] {
        shouldHighlightFollows ? addressBook.following : addressBook.pinned
    }
    
    var body: some View {
        HStack(spacing: 2) {
            if addressBook.signedIn {
                #if os(macOS)
                AddressIconView(address: addressBook.me, showMenu: false, contentShape: Circle())
                #else
                Menu {
                    primaryMenu
                } label: {
                    AddressIconView(address: addressBook.me, showMenu: false, contentShape: Circle())
                }
                .menuStyle(.borderlessButton)
                .padding(.top, -1)
                .padding(.leading, 1)
                .alert(
                    "Log out?",
                    isPresented: $confirmLogout,
                    actions: {
                        Button("Cancel", role: .cancel) { }
                        Button(
                            "Yes",
                            role: .destructive,
                            action: {
                                authenticate("")
                            }
                        )
                    }, message: {
                        Text("Are you sure you want to sign out of omg.lol?")
                    }
                )
                .contentShape(Rectangle())
                #endif
            } else {
                AppActionsButton()
                    .font(.largeTitle)
                    .buttonStyle(.borderless)
                    .foregroundStyle(.secondary)
            }
            
            VStack(alignment: .leading) {
                if !addressBook.signedIn && !hasShownLoginPrompt {
                    HStack {
                        Image(systemName: "key")
                            .font(.caption2)
                        Text("Sign in with omg.lol")
                            .font(.caption)
                    }
                    .foregroundStyle(.tint)
                    .animation(.default, value: hasShownLoginPrompt)
                    .task {
                        try? await Task.sleep(nanoseconds: 2000)
                        withAnimation {
                            hasShownLoginPrompt = true
                        }
                    }
                } else if addressBook.mine.count > 1 {
                    HStack(spacing: 2) {
                        Image(systemName: "person.circle")
                            .bold()
                            .font(.caption2)
                        Text("\(addressBook.mine.count)")
                            .bold()
                            .font(.caption)
                    }
                    .foregroundStyle(.tint)
                }
                if !addressBook.me.isEmpty {
                    AddressNameView(addressBook.me)
                        .foregroundStyle(.primary)
                } else {
                    Spacer()
                }
            }
            .padding(4)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            #if os(iOS)
            Menu {
                secondaryMenu
            } label: {
                highlightIcons
            }
            .padding(.trailing, 2)
            .menuStyle(.borderlessButton)
            #else
            highlightIcons
            Menu {
                primaryMenu
                secondaryMenu
            } label: {
                Label(title: {  }, icon: { Image(systemName: "ellipsis.circle")})
            }
            .menuStyle(.borderlessButton)
            #endif
        }
        .padding(.top, 2)
        .padding(.horizontal, 2)
    }
    
    @ViewBuilder
    var highlightIcons: some View {
        HStack(spacing: 2) {
            HStack(alignment: .bottom, spacing: -12) {
                if highlights.count > 2 {
                    AddressIconView(address: highlights[2], size: 24, showMenu: false, contentShape: Circle())
                }
                if highlights.count > 1 {
                    AddressIconView(address: highlights[1], size: 32, showMenu: false, contentShape: Circle())
                        .padding(.trailing, -4)
                }
                if let firstPin = highlights.first {
                    AddressIconView(address: firstPin, size: 36, showMenu: false, contentShape: Circle())
                }
            }
#if !os(macOS)
            VStack {
                if addressBook.following.isEmpty {
                    if addressBook.pinned.count == 0 {
                        Image(systemName: "pin.circle")
                            .font(.body)
                            .bold()
                            .foregroundStyle(Color.lolAccent)
                    } else if addressBook.pinned.count > 2 {
                        Image(systemName: "pin.circle")
                            .bold()
                            .foregroundStyle(Color.lolAccent)
                    }
                } else {
                    Image(systemName: "pin.circle")
                        .bold(!shouldHighlightFollows)
                        .foregroundStyle(shouldHighlightFollows ? Color.primary : Color.lolAccent)
                    Image(systemName: "person.2.circle")
                        .bold(shouldHighlightFollows)
                        .foregroundStyle(shouldHighlightFollows ? Color.lolAccent : Color.primary)
                }
            }
            .font(.caption2)
            if addressBook.pinned.count > 2 || !addressBook.following.isEmpty {
                VStack(alignment: .leading) {
                    Text("\(addressBook.pinned.count)")
                        .bold(!shouldHighlightFollows)
                        .foregroundStyle(shouldHighlightFollows ? Color.primary : Color.lolAccent)
                    if !addressBook.following.isEmpty {
                        Text("\(addressBook.following.count)")
                            .bold(shouldHighlightFollows)
                            .foregroundStyle(shouldHighlightFollows ? Color.lolAccent : Color.primary)
                    }
                }
                .font(.caption)
            }
#endif
        }
        .foregroundStyle(Color.secondary)
        .animation(.default, value: addressBook.pinned)
        .animation(.default, value: addressBook.following)
        .padding(.trailing, 4)
    }
    
    @ViewBuilder
    var primaryMenu: some View {
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
        }
        ForEach(addressBook.mine.sorted().reversed()) { address in
            Section(address.addressDisplayString) {
                Button {
                    withAnimation {
                        presentListable?(.address(address, page: .profile))
                    }
                } label: {
                    Label {
                        Text("Profile")
                    } icon: {
                        Image(systemName: "person")
                    }
                }
                if addressBook.me != address {
                    Button {
                        withAnimation {
                            set(address)
                        }
                    } label: {
                        Label {
                            Text("Use address")
                        } icon: {
                            Image(systemName: "shuffle")
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var secondaryMenu: some View {
        Button {
            withAnimation { addAddress.toggle() }
        } label: {
            Label {
                Text("Add pin")
            } icon: {
                Image(systemName: "plus.circle")
            }
        }
        if addressBook.following.isEmpty {
            Menu {
                ForEach(addressBook.following) { address in
                    Button {
                        withAnimation {
                            presentListable?(.address(address, page: .profile))
                        }
                    } label: {
                        Text(address.addressDisplayString)
                    }
                }
            } label: {
                Label("Following", systemImage: "binoculars")
            }
        }
        Section("Pins") {
            ForEach(addressBook.pinned) { address in
                Button {
                    withAnimation {
                        presentListable?(.address(address, page: .profile))
                    }
                } label: {
                    Label {
                        Text(address.addressDisplayString)
                    } icon: {
                        if address == addressBook.pinned.last {
                            Image(systemName: "pin")
                        }
                    }
                }
            }
        }
        Divider()
        if !addressBook.following.isEmpty {
            Menu {
                Button {
                    highlightFollows = true
                } label: {
                    Label("Follows", systemImage: shouldHighlightFollows ? "checkmark" : "binoculars")
                        .bold(shouldHighlightFollows)
                }
                .bold(shouldHighlightFollows)
                .disabled(!addressBook.signedIn)
                Button {
                    highlightFollows = false
                } label: {
                    Label("Pinned", systemImage: shouldHighlightFollows ? "pin" : "checkmark")
                }
                .bold(shouldHighlightFollows)
            } label: {
                Label("Highlight", systemImage: "star")
            }
        }
    }
    
    @Environment(\.presentListable)
        var presentListable
    @Environment(\.setAddress)
        var set
    @Environment(\.authenticate)
        var authenticate
    @Environment(\.addressBook)
        var addressBook
}

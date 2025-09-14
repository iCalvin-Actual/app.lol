//
//  AccountView.swift
//  omgui
//
//  Created by Calvin Chestnut on 9/1/24.
//

import SwiftUI

struct AccountView: View {
    @Environment(AccountAuthFetcher.self)
        var authFetcher
    @Environment(\.authenticate)
        var authenticate
    @Environment(\.presentListable)
        var present
    @Environment(\.addressSummaryFetcher)
        var summaryFetcherCache
    @Environment(\.setAddress)
        var setAddress
    
    @Environment(\.horizontalSizeClass)
    var sizeClass
    
    @State
    var confirmLogout: Bool = false
    
    var actingAddress: Binding<AddressName> {
        .init(
            get: { addressBook.me },
            set: { setAddress($0) }
        )
    }
    
    let addressBook: AddressBook
    @Bindable
    var followingFetcher: AddressFollowingFetcher
    @Bindable
    var followersFetcher: AddressFollowersFetcher
    
    let menuBuilder = ContextMenuBuilder<AddressModel>()
    
    var body: some View {
        coreBody
            .navigationTitle("💗 /\(addressBook.signedIn ? "account" : "app")")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                Menu{
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
                } label: {
                    Label("More", systemImage: "ellipsis.circle")
                        .bold()
                }
                .tint(.secondary)
            }
            .task { [weak followingFetcher, weak followersFetcher] in
                await followingFetcher?.updateIfNeeded()
                await followersFetcher?.updateIfNeeded()
            }
    }
    
    @ViewBuilder
    var coreBody: some View {
        List {
            Section("Lists") {
                // Mine addresses horizontal scroll section
                if !addressBook.mine.isEmpty {
                    Label {
                        Text("Mine")
                    } icon: {
                        Image(systemName: "person")
                    }
                    .foregroundStyle(.primary)
                    .font(.callout)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .listRowSeparator(.hidden)
                    
                    AddressesRow(addresses: addressBook.mine.sorted().compactMap({ summaryFetcherCache($0) }))
                        .frame(maxWidth: .infinity)
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowBackground(Color.clear)
                }

                // Following horizontal scroll section
                if !addressBook.following.isEmpty {
                    Label {
                        Text("Following")
                    } icon: {
                        Image(systemName: "at")
                    }
                    .foregroundStyle(.primary)
                    .font(.callout)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .listRowSeparator(.hidden)
                    
                    AddressesRow(addresses: addressBook.following.sorted().compactMap({ summaryFetcherCache($0) }))
                        .frame(maxWidth: .infinity)
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowBackground(Color.clear)
                }

                // Followers horizontal scroll section
                if !addressBook.followers.isEmpty {
                    Label {
                        Text("Followers")
                    } icon: {
                        Image(systemName: "at")
                    }
                    .foregroundStyle(.primary)
                    .font(.callout)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .listRowSeparator(.hidden)
                    
                    AddressesRow(addresses: addressBook.followers.sorted().compactMap({ summaryFetcherCache($0) }))
                        .frame(maxWidth: .infinity)
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowBackground(Color.clear)
                }
                
                if !addressBook.pinned.isEmpty {
                    Label {
                        Text("pinned")
                    } icon: {
                        Image(systemName: "pin")
                    }
                    .foregroundStyle(.primary)
                    .font(.callout)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .listRowSeparator(.hidden)
                    
                    AddressesRow(addresses: addressBook.pinned.sorted().compactMap({ summaryFetcherCache($0) }))
                        .frame(maxWidth: .infinity)
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowBackground(Color.clear)
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
                .buttonStyle(.bordered)
                .foregroundStyle(.secondary)
#if canImport(UIKit)
                .listRowBackground(Color(UIColor.systemBackground).opacity(0.82))
#elseif os(macOS)
                .padding(.vertical, 16)
#endif
                .contentShape(Rectangle())
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
            } else {
                Button(action: {
                    authFetcher.perform()
                }) {
                    Label {
                        Text("Sign in")
                    } icon: {
                        Image(systemName: "key")
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

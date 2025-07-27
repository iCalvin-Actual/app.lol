//
//  OptionsButton.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 7/20/25.
//


import SwiftUI
import WebKit

struct OptionsButton: View {
    @Environment(\.addressBook)
    var addressBook
    @Environment(AccountAuthDataFetcher.self)
    var accountFetcher
    
    var body: some View {
        if addressBook.signedIn {
            loggedInMenu
                .tint(.accent)
        } else {
            loggedOutMenu
        }
    }
    
    @ViewBuilder
    var appSection: some View {
        Section("app.lol") {
            ForEach([NavigationItem.appLatest, NavigationItem.appSupport, NavigationItem.safety]) { item in
                NavigationLink(value: item) {
                    Label(item.displayString, systemImage: item.iconName)
                }
            }
        }
    }
    
    @ViewBuilder
    var loggedOutMenu: some View {
        Menu {
            loginButton
            appSection
        } label: {
            Label {
                Text("Options")
            } icon: {
                Image(systemName: "heart")
            }
        }
    }
    
    @ViewBuilder
    var loggedInMenu: some View {
        Menu {
            appSection
            logoutButton
        } label: {
            Label {
                Text("Options")
            } icon: {
                Image(systemName: "heart.fill")
            }
        }
    }
    
    @ViewBuilder
    var logoutButton: some View {
        Button(role: .destructive, action: {
            accountFetcher.logout()
        }) {
            Label {
                Text("log out")
                    .frame(maxWidth: .infinity, alignment: .leading)
            } icon: {
                Image(systemName: "rectangle.portrait.and.arrow.right")
            }
        }
    }
    
    @ViewBuilder
    var loginButton: some View {
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
    }
}

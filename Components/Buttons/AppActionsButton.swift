//
//  OptionsButton.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 7/20/25.
//


import SwiftUI
import WebKit

struct AppActionsButton: View {
    @Environment(\.presentListable) var presentListable
    @Environment(\.pinAddress)
    var pin
    @Environment(\.addressBook)
    var addressBook
    @Environment(AccountAuthFetcher.self)
    var accountFetcher
    
    var body: some View {
        Menu {
            appSection
            moreSection
        } label: {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 38, height: 38)
        }
        .padding(.horizontal, 2)
    }
    
    @ViewBuilder
    var moreSection: some View {
        Section("more") {
            ForEach([NavigationItem.appLatest, NavigationItem.appSupport, NavigationItem.safety]) { item in
                Button(action: {
                    presentListable?(item.destination)
                }, label: {
                    Label(item.displayString, systemImage: item.iconName)
                })
            }
        }
    }
    
    @ViewBuilder
    var appSection: some View {
        Section("app.lol") {
            AuthenticateButton()
        }
    }
}

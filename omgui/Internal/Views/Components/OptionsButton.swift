//
//  OptionsButton.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 7/20/25.
//


import SwiftUI
import WebKit

struct OptionsButton: View {
    @Environment(\.presentListable) var presentListable
    @Environment(\.pinAddress)
    var pin
    @Environment(\.addressBook)
    var addressBook
    @Environment(AccountAuthDataFetcher.self)
    var accountFetcher
    
    @State var addAddress: Bool = false
    @State var address: String = ""
    
    var body: some View {
        Menu {
            appSection
            moreSection
        } label: {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 36, height: 36)
                .padding(.horizontal, 4)
        }
        .alert("Add pinned address", isPresented: $addAddress) {
            TextField("Address", text: $address)
            Button("Cancel") { }
            Button("Add") {
                addAddress = false
                pin(address)
            }.disabled(address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
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
            Button {
                withAnimation { addAddress.toggle() }
            } label: {
                Label {
                    Text("add pin")
                } icon: {
                    Image(systemName: "plus.circle")
                }
            }
        }
    }
}

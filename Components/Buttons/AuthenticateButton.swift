//
//  AuthenticateButton.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/14/25.
//

import SwiftUI


struct AuthenticateButton: View {
    @Environment(AccountAuthFetcher.self)
        var accountFetcher
    @Environment(\.addressBook)
        var addressBook
    
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
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
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

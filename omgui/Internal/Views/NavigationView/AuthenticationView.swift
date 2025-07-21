//
//  AuthenticationView.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 7/20/25.
//


import SwiftUI

struct AuthenticationView: View {
    @AppStorage("app.lol.auth")
    var authKey: String = ""
    
    @State
    var confirmLogout = false
    
    @State
    var performingAuthAction = false
    
    let accountAuthDataFetcher: AccountAuthDataFetcher
    
    var body: some View {
        TabBar()
            .environment(\.logout, {
                confirmLogout = true
                
            })
            .environment(\.login, {
                performingAuthAction = true
                print("Hello")
            })
            .alert("log out?", isPresented: $confirmLogout, actions: {
                Button("cancel", role: .cancel) { }
                Button(
                    "yes",
                    role: .destructive,
                    action: {
                        authKey = ""
                    }
                )
            }, message: {
                Text("are you sure you want to sign out of omg.lol?")
            })
    }
}

//
//  lolApp.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Blackbird
import omgapi
import os
import SwiftUI

@main
struct omgApp: App {
    
    @AppStorage("lol.auth")         
    var authKey: String = ""
    @AppStorage("lol.terms")
    var acceptedTerms: TimeInterval = 0
    @AppStorage("lol.onboarding")
    var showOnboarding: Bool = false
    
    @State var appModel: AppModel = .init()
    
    @ViewBuilder
    func loadingView() -> some View {
        LoadingView()
    }
    
    var body: some Scene {
        WindowGroup {
            OMGScene(appModel: appModel)
                .task {
                    appModel = .init(
                        authKey: $authKey,
                        acceptedTerms: $acceptedTerms,
                        showOnboarding: $showOnboarding
                    )
                    appModel.performFirstRun()
                }
            
                .environment(\.authenticate,        appModel.authenticate(_:))
                .environment(\.credentialFetcher,   appModel.credential(for:))
            
                .environment(\.pinAddress, appModel.pin(_:))
                .environment(\.unpinAddress, appModel.removePin(_:))
            
                .environment(\.imageCache, appModel.imageCache)
            
                .sheet(isPresented: $showOnboarding) { OnboardingView() }
        }
    }
}

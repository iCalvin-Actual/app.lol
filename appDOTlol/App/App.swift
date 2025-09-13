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
    
    @State var appModel: AppModel?
    
    @ViewBuilder
    func loadingView() -> some View {
        LoadingView()
    }
    
    var body: some Scene {
        WindowGroup {
            if let appModel {
                OMGScene(appModel: appModel)
                    .task {
                        appModel.performFirstRun()
                    }
                
                    .environment(\.authenticate,        appModel.authenticate(_:))
                    .environment(\.credentialFetcher,   appModel.credential(for:))
                
                    .environment(\.pinAddress, appModel.pin(_:))
                    .environment(\.unpinAddress, appModel.removePin(_:))
                
                    .environment(\.avatarCache, appModel.avatarCache)
                    .environment(\.profileCache, appModel.profileCache)
                    .environment(\.privateCache, appModel.privateCache)
                    .environment(\.picCache, appModel.imageCache)
                
                    .sheet(isPresented: $showOnboarding) { OnboardingView() }
            } else {
                loadingView()
                    .task {
                        appModel = .init(
                            authKey: $authKey,
                            acceptedTerms: $acceptedTerms,
                            showOnboarding: $showOnboarding
                        )
                    }
            }
        }
    }
}

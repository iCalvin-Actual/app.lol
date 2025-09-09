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

private let logger = Logger(subsystem: "OMGApp", category: "app-events")

@main
struct lolApp: App {
    
    static let termsUpdated: Date = .init(timeIntervalSince1970: 1727921377)
    
    @AppStorage("lol.auth")         var authKey: String = ""
    @AppStorage("lol.terms")        var acceptedTerms: TimeInterval = 0
    @AppStorage("lol.onboarding")   var showOnboarding: Bool = false
    
    @State var globalDirectoryFetcher: GlobalAddressDirectoryFetcher = .init()
    @State var globalStatusFetcher: GlobalStatusLogFetcher = .init()
    
    @State var appSupportFetcher: AppSupportFetcher = .init()
    @State var localBlockedFetcher: LocalBlockListDataFetcher = .init()
    @State var pinnedFetcher: PinnedListDataFetcher = .init()
    
    @State var appLatestFetcher: AppLatestFetcher = .init(addressName: "app")
    @State var appBlockedFetcher: AddressBlockListDataFetcher = .init(address: "app", credential: "")
    
    @State var addressFetcher: AccountAddressDataFetcher = .init(credential: "")
    
    let profileCache: ProfileCache = .init()
    let privateCache: PrivateCache = .init()
    let imageCache: ImageCache = .init()
    
    @Environment(\.webAuthenticationSession)
    private var webAuthSession
    var accountFetcher: AccountAuthDataFetcher {
        return .init(
            session: webAuthSession,
            client: AppClient.info,
            interface: AppClient.interface,
            authenticate: {
                Task { @MainActor [cred = $0] in
                    authenticate(cred)
                }
            }
        )
    }
    
    var body: some Scene {
        WindowGroup {
            OMGScene(
                addressFetcher: addressFetcher,
                globalDirectoryFetcher: globalDirectoryFetcher,
                globalStatusFetcher: globalStatusFetcher,
                appSupportFetcher: appSupportFetcher,
                localBlockedFetcher: localBlockedFetcher,
                pinnedFetcher: pinnedFetcher,
                appLatestFetcher: appLatestFetcher,
                appBlockedFetcher: appBlockedFetcher,
                dataInterface: AppClient.interface
            )
            .task { performFirstRun() }
            
            .environment(accountFetcher)
            
            .environment(\.profileCache, profileCache)
            .environment(\.privateCache, privateCache)
            .environment(\.imageCache, imageCache)
            
            .environment(\.appLatestFetcher, appLatestFetcher)
            .environment(\.appSupportFetcher, appSupportFetcher)
            .environment(\.globalBlocklist, appBlockedFetcher)
            .environment(\.localBlocklist, localBlockedFetcher)
            
            .environment(\.globalDirectoryFetcher, globalDirectoryFetcher)
            .environment(\.globalStatusLogFetcher, globalStatusFetcher)
            
            .environment(\.authenticate,    { authenticate($0) })
            .environment(\.credentialFetcher, credential(for:))
            
            .environment(\.pinAddress,  { pin($0) })
            .environment(\.unpinAddress,{ removePin($0) })
        
            .sheet(isPresented: $showOnboarding) { OnboardingView() }
        }
    }
    
    private func performFirstRun() {
        logger.debug("First run")
        if acceptedTerms < lolApp.termsUpdated.timeIntervalSince1970 {
            showOnboarding = true
        }
        authenticate(authKey)
        Task { [
            weak globalDirectoryFetcher,
            weak globalStatusFetcher,
            weak appSupportFetcher,
            weak localBlockedFetcher,
            weak pinnedFetcher,
            weak appLatestFetcher,
            weak appBlockedFetcher
        ] in
            async let directory: Void = globalDirectoryFetcher?.updateIfNeeded() ?? {}()
            async let status: Void = globalStatusFetcher?.updateIfNeeded() ?? {}()
            async let support: Void = appSupportFetcher?.updateIfNeeded() ?? {}()
            async let localBlocked: Void = localBlockedFetcher?.updateIfNeeded() ?? {}()
            async let pinned: Void = pinnedFetcher?.updateIfNeeded() ?? {}()
            async let latest: Void = appLatestFetcher?.updateIfNeeded() ?? {}()
            async let blocked: Void = appBlockedFetcher?.updateIfNeeded() ?? {}()
            let _ = await (directory, status, support, localBlocked, pinned, latest, blocked)
        }
    }
    
    private func credential(for address: AddressName) -> APICredential? {
        guard addressFetcher.results.contains(where: { $0.addressName == address }) else {
            return nil
        }
        return authKey
    }
    
    private func authenticate(_ credential: APICredential) {
        guard credential != addressFetcher.credential else { return }
        logger.debug("Authenticated")
        authKey = credential
        addressFetcher = .init(credential: credential)
        
        privateCache.removeAllObjects()
        
        Task { [addressFetcher] in
            await addressFetcher.updateIfNeeded(forceReload: true)
        }
    }
}

extension lolApp {
    func pin(_ address: AddressName) {
        Task { [weak pinnedFetcher] in
            await pinnedFetcher?.pin(address.lowercased())
        }
    }
    func removePin(_ address: AddressName) {
        Task { [weak pinnedFetcher] in
            await pinnedFetcher?.removePin(address)
        }
    }
}

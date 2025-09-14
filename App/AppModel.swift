//
//  AppModel.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/11/25.
//

import Blackbird
import omgapi
import os
import SwiftUI

let appLevelLogger = Logger(subsystem: "OMGApp", category: "app-events")

@MainActor
@Observable
class AppModel {
    
    static let termsUpdated: Date = .init(timeIntervalSince1970: 1757719870)
    
    let avatarCache: AvatarCache = .init()
    let profileCache: ProfileCache = .init()
    let privateCache: PrivateCache = .init()
    let imageCache: ImageCache = .init()
    
    let globalDirectoryFetcher: GlobalAddressDirectoryFetcher = .init()
    let globalStatusFetcher: GlobalStatusLogFetcher = .init()
    
    let appSupportFetcher: AppSupportFetcher = .init()
    let localBlockedFetcher: LocalBlockListFetcher = .init()
    let pinnedFetcher: PinnedListFetcher = .init()
    
    let appLatestFetcher: AppLatestFetcher = .`init`()
    let appBlockedFetcher: AddressBlockListFetcher = .init(address: "app", credential: "")
    
    var addressFetcher: AccountAddressFetcher = .init(credential: "")
    
    let authKey: Binding<APICredential>
    let acceptedTerms: Binding<TimeInterval>
    let showOnboarding: Binding<Bool>
    
    init(
        authKey: Binding<APICredential> = .constant(""),
        acceptedTerms: Binding<TimeInterval> = .constant(0),
        showOnboarding: Binding<Bool> = .constant(false)
    ) {
        self.authKey = authKey
        self.acceptedTerms = acceptedTerms
        self.showOnboarding = showOnboarding
    }
    
    func performFirstRun() {
        appLevelLogger.debug("Performing first run")
        if acceptedTerms.wrappedValue < AppModel.termsUpdated.timeIntervalSince1970 {
            appLevelLogger.debug("Presenting onboarding")
            showOnboarding.wrappedValue = true
        }
        authenticate(authKey.wrappedValue)
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
            let _ = await (
                directory,
                status,
                support,
                localBlocked,
                pinned,
                latest,
                blocked
            )
        }
    }
}

extension AppModel {
    func credential(for address: AddressName) -> APICredential? {
        guard addressFetcher.results.contains(where: { $0.addressName == address }) else {
            return nil
        }
        return authKey.wrappedValue
    }
    
    func authenticate(_ credential: APICredential) {
        appLevelLogger.debug("Authenticating: \(credential)")
        guard credential != addressFetcher.credential else { return }
        appLevelLogger.debug("Updating authenticated fetchers")
        authKey.wrappedValue = credential
        addressFetcher = .init(credential: authKey.wrappedValue)
        
        privateCache.removeAllObjects()
        
        Task { [addressFetcher] in
            await addressFetcher.updateIfNeeded(forceReload: true)
        }
    }
}

extension AppModel {
    func pin(_ address: AddressName) {
        appLevelLogger.debug("Pinning \(address.addressDisplayString)")
        Task { [weak pinnedFetcher] in
            await pinnedFetcher?.pin(address.lowercased())
        }
    }
    func removePin(_ address: AddressName) {
        appLevelLogger.debug("Unpinning \(address.addressDisplayString)")
        Task { [weak pinnedFetcher] in
            await pinnedFetcher?.removePin(address)
        }
    }
}

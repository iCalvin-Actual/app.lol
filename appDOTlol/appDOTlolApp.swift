//
//  appDOTlolApp.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Blackbird
import omgapi
import SwiftUI

struct AppClient {
    static var info: ClientInfo {
        ClientInfo(
            id: "5e171c460ba4b7a7ceaf86295ac169d2",
            secret: "6937ec29a6811d676615d783ab071bb8",
            scheme: "app-omg-lol",
            callback: "://oauth"
        )
    }
    static let interface = APIDataInterface() /*SampleData()*/
}

@main
struct appDOTlolApp: App {
    static var database: Blackbird.Database = {
        do {
            return try .init(path:
                        FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("appV1", conformingTo: .database)
                .absoluteString
            )
        } catch {
            return try! .inMemoryDatabase()
        }
    }()
    
    @StateObject
    var accountAddressesFetcher: AccountAddressDataFetcher
    @StateObject
    var globalBlocklistFetcher: AddressBlockListDataFetcher
    @StateObject
    var localBlocklistFetcher: LocalBlockListDataFetcher
    @StateObject
    var pinnedFetcher: PinnedListDataFetcher
    
    @StateObject
    var directoryFetcher: GlobalAddressDirectoryFetcher
    @StateObject
    var gardenFetcher: GlobalNowGardenFetcher
    @StateObject
    var statusFetcher: GlobalStatusLogFetcher
    @StateObject
    var supportFetcher: AppSupportFetcher
    @StateObject
    var appLatestFetcher: AppLatestFetcher
    
    init() {
        self._accountAddressesFetcher = StateObject(wrappedValue: AccountAddressDataFetcher(credential: "", interface: AppClient.interface))
        self._globalBlocklistFetcher = StateObject(wrappedValue: .init(address: "app", credential: nil, interface: AppClient.interface))
        self._localBlocklistFetcher = StateObject(wrappedValue: .init(interface: AppClient.interface))
        self._pinnedFetcher = StateObject(wrappedValue: .init(interface: AppClient.interface))
        self._directoryFetcher = StateObject(wrappedValue: .init(interface: AppClient.interface, db: Self.database))
        self._gardenFetcher = StateObject(wrappedValue: .init(interface: AppClient.interface, db: Self.database))
        self._statusFetcher = StateObject(wrappedValue: .init(interface: AppClient.interface, db: Self.database))
        self._supportFetcher = StateObject(wrappedValue: .init(interface: AppClient.interface, db: Self.database))
        self._appLatestFetcher = StateObject(wrappedValue: .`init`(interface: AppClient.interface, db: Self.database))
    }
    
    var body: some Scene {
        WindowGroup {
            OMGScene(
                client: AppClient.info,
                interface: AppClient.interface,
                db: Self.database
            )
            .environment(\.apiInterface, AppClient.interface)
            .environment(\.omgClient, AppClient.info)
            .environment(\.blackbird, Self.database)
            .environment(\.addressFetcher, accountAddressesFetcher)
            .environment(\.globalBlocklist, globalBlocklistFetcher)
            .environment(\.localBlocklist, localBlocklistFetcher)
            .environment(\.pinnedFetcher, pinnedFetcher)
            .environment(\.globalDirectoryFetcher, directoryFetcher)
            .environment(\.globalGardenFetcher, gardenFetcher)
            .environment(\.globalStatusLogFetcher, statusFetcher)
            .environment(\.appSupportFetcher, supportFetcher)
            .environment(\.appLatestFetcher, appLatestFetcher)
            .task { [directoryFetcher, gardenFetcher, statusFetcher] in
                async let _ = directoryFetcher.updateIfNeeded(forceReload: true)
                async let _ = gardenFetcher.updateIfNeeded(forceReload: true)
                async let _ = statusFetcher.updateIfNeeded(forceReload: true)
            }
        }
    }
}

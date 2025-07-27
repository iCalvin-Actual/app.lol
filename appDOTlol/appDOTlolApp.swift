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
    enum Error: String, Swift.Error {
        case notYourAddress
    }
    static let interface = APIDataInterface()
    /*SampleData()*/
    /* static let interface = SampleData() */
    static var info: ClientInfo {
        ClientInfo(
            id: "5e171c460ba4b7a7ceaf86295ac169d2",
            secret: "6937ec29a6811d676615d783ab071bb8",
            scheme: "app-omg-lol",
            callback: "://oauth"
        )
    }
    static let database: Blackbird.Database = {
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
}

@main
struct appDOTlolApp: App {
    
    static let termsUpdated: Date = .init(timeIntervalSince1970: 1727921377)
    
    let profileCache: ProfileCache = .init()
    let privateCache: PrivateCache = .init()
    
    init() { }
    
    var body: some Scene {
        WindowGroup {
            OMGScene(AppClient.interface)
                .environment(\.profileCache, profileCache)
                .environment(\.privateCache, privateCache)
        }
    }
}

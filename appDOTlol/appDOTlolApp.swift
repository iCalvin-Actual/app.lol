//
//  appDOTlolApp.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Blackbird
import omgapi
import SwiftUI

@main
struct appDOTlolApp: App {
    static var clientInfo: ClientInfo {
        ClientInfo(
            id: "5e171c460ba4b7a7ceaf86295ac169d2",
            secret: "6937ec29a6811d676615d783ab071bb8",
            scheme: "app-omg-lol",
            callback: "://oauth"
        )
    }
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
    let interface = APIDataInterface() /*SampleData()*/
    
    var body: some Scene {
        WindowGroup {
            omgui(
                client: Self.clientInfo,
                interface: interface,
                database: try! .inMemoryDatabase()
            )
        }
    }
}

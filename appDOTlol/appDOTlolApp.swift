//
//  appDOTlolApp.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Blackbird
import omgapi
import omgui
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
        let directory = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("blackbird", conformingTo: .database)
            .absoluteString
        
        return try! .init(path: directory)
    }()
    let interface = APIDataInterface()
    
    var documentDirectory: String {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("blackbird", conformingTo: .database).absoluteString
    }
    
    var body: some Scene {
        WindowGroup {
            omgui(
                client: Self.clientInfo,
                interface: interface,
<<<<<<< HEAD
                dbDestination: documentDirectory
=======
                database: Self.database
>>>>>>> develop
            )
        }
    }
}

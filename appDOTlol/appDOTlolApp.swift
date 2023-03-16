//
//  appDOTlolApp.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 3/5/23.
//

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
    let interface = SampleData()
    
    @StateObject
    var appModel: AppModel = AppModel(client: Self.clientInfo, dataInterface: SampleData())
    
    var body: some Scene {
        WindowGroup {
            omgui(state: appModel)
        }
    }
}

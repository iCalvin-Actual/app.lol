//
//  app_lolApp.swift
//  app.lol
//
//  Created by Calvin Chestnut on 2/12/23.
//

import UIDotAppDotLOL
import SwiftUI

@main
struct AppDotLOL: App {
    let appUI = UIDotAppDotLOL(interface: APIDataInterface())
    
    var body: some Scene {
        WindowGroup {
            appUI.body
            
        }
    }
}

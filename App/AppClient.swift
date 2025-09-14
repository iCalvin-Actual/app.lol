//
//  AppClient.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/9/25.
//

import Blackbird
import Foundation


struct AppClient {
    
    static let interface = APIDataInterface()
    static let sampleInterface = SampleData()
    
    static let info = Identifiers()
    
    static let database: Blackbird.Database = {
        do {
            return try .init(path:
                        FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("appV2", conformingTo: .database)
                .absoluteString
            )
        } catch {
            return try! .inMemoryDatabase()
        }
    }()
    
    enum Error: String, Swift.Error {
        case notYourAddress
    }
    
    struct Identifiers {
        let id: String = APIDataInterface.clientId
        let secret: String = APIDataInterface.clientSecret
        let urlScheme: String = "app-omg-lol"
        let callback: String = "://oauth"
        
        var redirectUrl: String { urlScheme + callback}
    }
}

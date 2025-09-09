//
//  AppClient.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/9/25.
//

import Blackbird
import Foundation

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
                .appendingPathComponent("appV2", conformingTo: .database)
                .absoluteString
            )
        } catch {
            return try! .inMemoryDatabase()
        }
    }()
}


//
//  GlobalListFetchers.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/11/25.
//

import Blackbird
import SwiftUI


// This class doesn't fetch results, it writes to the DB as part of the throwingReqeust
class GlobalListFetcher<T: BlackbirdListable>: ListFetcher<T> {
    let db: Blackbird.Database
    
    init(automation: AutomationPreferences = .init()) {
        self.db = AppClient.database
        super.init(items: [], limit: 42, filters: [], sort: T.defaultSort, automation: automation)
    }
}


class GlobalAddressDirectoryFetcher: GlobalListFetcher<AddressModel> {
    // Persist the last successful run date as an ISO8601 string in AppStorage.
    // Using a unique key to avoid collisions.
    @AppStorage("lol.lastFetch")
    private var lastFetch: String = ""

    @MainActor
    override func throwingRequest() async throws {
        // Decode last run date if present
        let formatter = ISO8601DateFormatter()
        let calendar = Calendar.current
        if let lastRun = formatter.date(from: lastFetch),
           calendar.isDateInToday(lastRun) {
            // Already ran today; skip work
            return
        }

        let garden = try await interface.fetchNowGarden()
        
        for model in garden {
            try await model.write(to: db)
        }
        
        let directory = try await interface.fetchAddressDirectory()
        
        for address in directory {
            
            print("Directory: Prepping model for \(address)")
            do {
                var model = try await interface.fetchAddressInfo(address)
                print("Directory: Fetching now for \(address)")
                if let listing = try await NowListing.read(from: db, id: address) {
                    let url = URL(string: String(listing.url.dropLast("/now".count)))
                    model.url = url
                }
                print("Directory: Writing model for \(address)")
                try await model.write(to: db)
            } catch {
                print("Directory: Fallback option for \(address)")
                try await AddressModel(name: address, url: URL(string: "https://\(address).omg.lol"), date: .distantPast).write(to: db)
            }
        }

        // Mark successful completion time
        lastFetch = formatter.string(from: Date())
    }
}
class GlobalStatusLogFetcher: GlobalListFetcher<StatusModel> {
    @MainActor
    override func throwingRequest() async throws {
        let statusLog = try await interface.fetchCompleteStatusLog()
        for model in statusLog {
            try await model.write(to: db)
        }
    }
}

class AppSupportFetcher: AddressPasteFetcher {
    init() {
        super.init(name: "app", title: "support")
    }
}
typealias AppLatestFetcher = AddressNowPageFetcher
extension AddressNowPageFetcher {
    static func `init`() -> AddressNowPageFetcher {
        .init(addressName: "app")
    }
}

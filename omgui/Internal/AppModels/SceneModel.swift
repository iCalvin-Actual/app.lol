//
//  SceneModel.swift
//
//
//  Created by Calvin Chestnut on 3/6/23.
//

import AuthenticationServices
import Blackbird
import Combine
import SwiftUI

@MainActor
@Observable
class SceneModel {
    
    let database: Blackbird.Database
    let interface: DataInterface
    
    // MARK: Properties
    
    // MARK: Lifecycle
    
    
    init(
        addressBook: AddressBook,
        interface: DataInterface,
        database: Blackbird.Database
    )
    {
        self.interface = interface
        self.database = database
    }
}

// MARK: - AddressBook

extension SceneModel {
    static var sample: SceneModel {
        let credential = ""
        let actingAddress = ""
        let book = AddressBook(
            auth: credential,
            me: actingAddress
        )
        
        return SceneModel(addressBook: book, interface: SampleData(), database: try! .inMemoryDatabase())
    }
}

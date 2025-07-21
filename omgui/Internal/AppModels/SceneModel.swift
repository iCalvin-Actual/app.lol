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
    
    let profileDrafts: DraftFetcher<ProfileMarkdown>
    
    init(
        addressBook: AddressBook.Scribbled,
        interface: DataInterface,
        database: Blackbird.Database
    )
    {
        self.interface = interface
        self.database = database
        
        self.profileDrafts = .init(addressBook.me, interface: interface, addressBook: addressBook, db: database)
    }
}

// MARK: - AddressBook

extension SceneModel {
    static var sample: SceneModel {
        let credential = ""
        let actingAddress = ""
        let book = AddressBook.Scribbled(
            auth: credential,
            me: actingAddress
        )
        
        return SceneModel(addressBook: book, interface: SampleData(), database: try! .inMemoryDatabase())
    }
}

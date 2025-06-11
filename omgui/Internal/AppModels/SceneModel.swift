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
    
    var database: Blackbird.Database
    
    let interface: DataInterface
    
    let addressBook: AddressBook
    
    // MARK: Caches
    
    var profileCache: NSCache<NSString, AddressSummaryDataFetcher> = .init()
    var privateCache: NSCache<NSString, AddressPrivateSummaryDataFetcher> = .init()
    
    // MARK: Properties
    
    var destinationConstructor: DestinationConstructor {
        .init(
            sceneModel: self
        )
    }
    
    // MARK: Lifecycle
    
    var cancellables: Set<AnyCancellable> = []
    
    let directoryFetcher: AddressDirectoryDataFetcher
    let gardenFetcher: NowGardenDataFetcher
    let statusFetcher: StatusLogDataFetcher
    let supportFetcher: AddressPasteDataFetcher
    
    let profileDrafts: DraftFetcher<ProfileMarkdown>
    
    init(
        addressBook: AddressBook,
        interface: DataInterface,
        database: Blackbird.Database
    )
    {
        self.addressBook = addressBook
        self.interface = interface
        self.database = database
        
        self.directoryFetcher = .init(addressBook: addressBook, interface: interface, db: database)
        self.gardenFetcher = .init(addressBook: addressBook, interface: interface, db: database)
        self.statusFetcher = .init(addressBook: addressBook, interface: interface, db: database)
        self.supportFetcher = .init(name: "app", title: "support", interface: interface, db: database)
        
        self.profileDrafts = .init(addressBook.actingAddress.wrappedValue, interface: interface, addressBook: addressBook, db: database)
        
        let myProfiles = addressBook.myAddresses
        let publicProfiles = (addressBook.pinnedAddresses + addressBook.following).filter({ !myProfiles.contains($0) })
        
        myProfiles.forEach({
            let privateAddress = $0
            Task {
                let _ = try addressPrivateSummary(privateAddress)
            }
        })
        publicProfiles.forEach({
            let _ = addressSummary($0)
        })
    }
}

// MARK: - AddressBook

extension SceneModel {
    enum AddressBookError: Error {
        case notYourAddress
    }
    
    // MARK: Summaries
    
    func appropriateFetcher(for address: AddressName) -> AddressSummaryDataFetcher {
        if addressBook.myAddresses.contains(address) {
            do {
                return try addressPrivateSummary(address)
            } catch {
                return addressSummary(address)
            }
        }
        return addressSummary(address)
    }
    func constructFetcher(for address: AddressName) -> AddressSummaryDataFetcher {
        AddressSummaryDataFetcher(name: address, addressBook: addressBook, interface: interface, database: database)
    }
    func privateSummary(for address: AddressName) -> AddressPrivateSummaryDataFetcher? {
        guard addressBook.credential(for: address) != nil else {
            return nil
        }
        return AddressPrivateSummaryDataFetcher(name: address, addressBook: addressBook, interface: interface, database: database)
    }
    func addressSummary(_ address: AddressName) -> AddressSummaryDataFetcher {
        if let model = profileCache.object(forKey: NSString(string: address)) ?? (addressBook.myAddresses.contains(where: { $0.lowercased() == address.lowercased() }) ? privateCache.object(forKey: NSString(string: address)) : nil) {
            return model
        } else {
            let model = constructFetcher(for: address)
            profileCache.setObject(model, forKey: NSString(string: address))
            return model
        }
    }
    func addressPrivateSummary(_ address: AddressName) throws -> AddressPrivateSummaryDataFetcher {
        if let model = privateCache.object(forKey: NSString(string: address)) {
            return model
        } else {
            guard let model = privateSummary(for: address) else {
                throw AddressBookError.notYourAddress
            }
            privateCache.setObject(model, forKey: NSString(string: address))
            return model
        }
    }
}

extension SceneModel {
    static var sample: SceneModel {
        let db = try! Blackbird.Database.inMemoryDatabase()
        let interface = SampleData()
        let credential = ""
        let actingAddress = ""
        let book = AddressBook(
            authKey: credential,
            actingAddress: .constant(actingAddress),
            accountAddressesFetcher: .init(credential: credential, interface: interface),
            globalBlocklistFetcher: .init(address: "app", credential: credential, interface: interface),
            localBlocklistFetcher: .init(interface: interface),
            addressBlocklistFetcher: .init(address: actingAddress, credential: credential, interface: interface),
            addressFollowingFetcher: .init(address: actingAddress, credential: credential, interface: interface),
            addressFollowersFetcher: .init(address: actingAddress, credential: credential, interface: interface),
            pinnedAddressFetcher: .init(interface: interface)
        )
        
        return SceneModel(addressBook: book, interface: SampleData(), database: db)
    }
}

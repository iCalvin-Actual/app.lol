//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 7/29/24.
//

import Blackbird
import Foundation
import WebKit


class ProfileMarkdownFetcher: DatabaseFetcher<ProfileMarkdown> {
    
    let addressName: AddressName
    let credential: APICredential
    
    init(name: AddressName, credential: APICredential) {
        self.addressName = name
        self.credential = credential
        super.init()
    }
    
    @MainActor
    override func fetchModels() async throws {
        self.result = try await ProfileMarkdown.read(from: db, id: addressName)
    }
    
    override func fetchRemote() async throws -> Int {
        guard !addressName.isEmpty else {
            return 0
        }
        let markdown = try await interface.fetchAddressProfile(addressName, credential: credential)
        try await markdown.write(to: db)
        return markdown.hashValue
    }
}

class AddressNowFetcher: DatabaseFetcher<NowModel> {
    let addressName: AddressName
    
    init(name: AddressName) {
        self.addressName = name
        super.init()
    }
    
    @MainActor
    override func fetchModels() async throws {
        self.result = try await NowModel.read(from: db, id: addressName)
    }
    
    override func fetchRemote() async throws -> Int {
        guard !addressName.isEmpty else {
            return 0
        }
        let now = try await interface.fetchAddressNow(addressName)
        try await now?.write(to: db)
        return now?.hashValue ?? 0
    }
    
    override var noContent: Bool {
        guard !loading else {
            return false
        }
        return loaded != nil && (error?.localizedDescription.contains("omgapi.APIError error 3") ?? false)
    }
}

class StatusFetcher: DatabaseFetcher<StatusModel> {
    let address: AddressName
    let id: String
    
    init(id: String, from address: String) {
        self.address = address
        self.id = id
        super.init()
    }
    
    @MainActor
    override func fetchModels() async throws {
        do {
            result = try await StatusModel.read(from: db, id: id)
        } catch {
            throw(error)
        }
    }
    
    @MainActor
    override func fetchRemote() async throws -> Int {
        let status = try await interface.fetchAddressStatus(id, from: address)
        try await status?.write(to: db)
        return status?.hashValue ?? 0
        
    }
    
    override func handle(_ incomingError: any Error) {
        // Check error
        super.handle(incomingError)
    }
}

@Observable
class PicFetcher: DatabaseFetcher<PicModel> {
    let address: AddressName
    let id: String
    
    var imageData: Data?
    
    init(id: String, from address: String) {
        self.address = address
        self.id = id
        super.init()
    }
    
    @MainActor
    override func fetchModels() async throws {
        do {
            result = try await PicModel.read(from: db, id: id)
        } catch {
            throw(error)
        }
    }
    
    @MainActor
    override func fetchRemote() async throws -> Int {
        do {
            let pic = try await interface.fetchPic(id, from: address)
            try await pic?.write(to: db)
            try await fetchImage()
            
            return pic?.hashValue ?? 0
        } catch {
            throw error
        }
    }
    
    @MainActor
    func fetchImage() async throws {
        if let content = result?.content {
            self.imageData = try await URLSession.shared.data(from: content).0
        } else {
            let pic = try await interface.fetchPic(id, from: address)
            try await pic?.write(to: db)
            if let pic {
                self.imageData = try await URLSession.shared.data(from: pic.content).0
            }
        }
    }
    
    override func handle(_ incomingError: any Error) {
        // Check error
        super.handle(incomingError)
    }
}

class AddressPasteFetcher: DatabaseFetcher<PasteModel> {
    let address: AddressName
    let title: String
    var credential: APICredential?
    
    init(name: AddressName, title: String, credential: APICredential? = nil) {
        self.address = name
        self.title = title
        self.credential = credential
        super.init()
    }
    
    func configure(credential: APICredential?, _ automation: AutomationPreferences = .init()) {
        self.credential = credential
        super.configure(automation)
    }
    
    @MainActor
    override func fetchModels() async throws {
        self.result = try await PasteModel.read(from: db, multicolumnPrimaryKey: [address, title])
    }
    
    @MainActor
    override func fetchRemote() async throws -> Int {
        guard !address.isEmpty, !title.isEmpty else {
            return 0
        }
        let paste = try await interface.fetchPaste(title, from: address, credential: credential)
        try await paste?.write(to: db)
        return paste?.hashValue ?? 0
    }
    
    func deleteIfPossible() async throws {
        guard let credential else {
            return
        }
        let _ = try await interface.deletePaste(title, from: address, credential: credential)
        try await result?.delete(from: db)
    }
}

class AddressPURLFetcher: DatabaseFetcher<PURLModel> {
    let address: AddressName
    let title: String
    var credential: APICredential?
    
    init(name: AddressName, title: String, credential: APICredential? = nil) {
        self.address = name
        self.title = title
        self.credential = credential
        super.init()
    }
    
    func configure(credential: APICredential?, _ automation: AutomationPreferences = .init()) {
        self.credential = credential
        super.configure(automation)
    }
    
//    var draftPoster: PURLDraftPoster? {
//        guard let credential else {
//            return super.draftPoster as? PasteDraftPoster
//        }
//        if let model {
//            return .init(
//                addressName,
//                title: model.name,
//                content: model.content ?? "",
//                interface: interface,
//                credential: credential
//            )
//        } else {
//            return .init(
//                addressName,
//                title: "",
//                interface: interface,
//                credential: credential
//            )
//        }
//    }
    
    @MainActor
    override func fetchModels() async throws {
        self.result = try await PURLModel.read(from: db, multicolumnPrimaryKey: [address, title])
    }
    
    override func fetchRemote() async throws -> Int {
        guard !address.isEmpty, !title.isEmpty else {
            return 0
        }
        let purl = try await interface.fetchPURL(title, from: address, credential: credential)
        try await purl?.write(to: db)
        return purl?.hashValue ?? 0
    }
    
    func deleteIfPossible() async throws {
        guard let credential else {
            return
        }
        let _ = try await interface.deletePURL(title, from: address, credential: credential)
        try await result?.delete(from: db)
        result = nil
    }
}

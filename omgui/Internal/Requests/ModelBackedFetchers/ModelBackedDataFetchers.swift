//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 7/29/24.
//

import Blackbird
import Foundation


class ProfileMarkdownDataFetcher: ModelBackedDataFetcher<ProfileMarkdown> {
    
    let addressName: AddressName
    let credential: APICredential
    
    init(name: AddressName, credential: APICredential, interface: DataInterface, db: Blackbird.Database) {
        self.addressName = name
        self.credential = credential
        super.init(interface: interface, db: db)
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

class AddressNowDataFetcher: ModelBackedDataFetcher<NowModel> {
    let addressName: AddressName
    
    init(name: AddressName, interface: DataInterface, db: Blackbird.Database) {
        self.addressName = name
        super.init(interface: interface, db: db)
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

class StatusDataFetcher: ModelBackedDataFetcher<StatusModel> {
    let address: AddressName
    let id: String
    
    var linkFetchers: [URLContentDataFetcher] {
        guard let links = result?.webLinks else {
            return []
        }
        return links.map({
            .init(url: $0.content, interface: interface)
        })
    }
    
    init(id: String, from address: String, interface: DataInterface, db: Blackbird.Database) {
        self.address = address
        self.id = id
        super.init(interface: interface, db: db)
    }
    
    @MainActor
    override func fetchModels() async throws {
        do {
            result = try await StatusModel.read(from: db, id: id)
        } catch {
            print("Error")
            throw(error)
        }
    }
    
    @MainActor
    override func fetchRemote() async throws -> Int {
        let status = try await interface.fetchAddressStatus(id, from: address)
        try await status?.write(to: db)
        return status?.hashValue ?? 0
        
    }
    
    func fetcher(for url: URL) -> URLContentDataFetcher? {
        linkFetchers.first(where: { $0.url == url })
    }
    
    override func handle(_ incomingError: any Error) {
        // Check error
        super.handle(incomingError)
    }
}

class AddressPasteDataFetcher: ModelBackedDataFetcher<PasteModel> {
    let address: AddressName
    let title: String
    let credential: APICredential?
    
    init(name: AddressName, title: String, credential: APICredential? = nil, interface: any DataInterface, db: Blackbird.Database) {
        self.address = name
        self.title = title
        self.credential = credential
        super.init(interface: interface, db: db)
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

class AddressPURLDataFetcher: ModelBackedDataFetcher<PURLModel> {
    let address: AddressName
    let title: String
    let credential: APICredential?
    
    init(name: AddressName, title: String, credential: APICredential? = nil, interface: any DataInterface, db: Blackbird.Database) {
        self.address = name
        self.title = title
        self.credential = credential
        super.init(interface: interface, db: db)
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

//
//  APIInterface.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 3/5/23.
//

import omgapi
import omgui
import Foundation

struct APIDataInterface: DataInterface {
    
    let api: omgapi.api = .init()
    
    static let clientId: String = "5e171c460ba4b7a7ceaf86295ac169d2"
    static let clientSecret: String = "6937ec29a6811d676615d783ab071bb8"
    static let redirect: String = "app-omg-lol://oauth"
    
    public init() { }
    
    public func fetchAccessToken(authCode: String, clientID: String, clientSecret: String, redirect: String) async throws -> String? {
        try await api.oAuthExchange(with: clientID, and: clientSecret, redirect: redirect, code: authCode)!
    }
    
    public func authURL() -> URL? {
        api.authURL(with: Self.clientId, redirect: "app-omg-lol://oauth")
    }
    
    public func fetchServiceInfo() async throws -> ServiceInfoModel {
        let info = try await api.serviceInfo()
        return ServiceInfoModel(members: info.members, addresses: info.addresses, profiles: info.profiles)
    }
    
    public func fetchThemes() async throws -> [ThemeModel] {
        return try await api.themes().map({ model in
            ThemeModel(
                id: model.id,
                name: model.name,
                created: model.created,
                updated: model.updated,
                author: model.author,
                license: model.license,
                description: model.description,
                preview: model.previewCss
            )
        })
    }
    
    public func fetchAddressDirectory() async throws -> [AddressName] {
        return try await api.addressDirectory()
    }
    
    public func fetchAccountInfo(_ address: AddressName, credential: APICredential) async throws -> AccountInfoModel? {
        guard !address.isEmpty else {
            return nil
        }
        let response = try await api.account(for: "\(address)@omg.lol", with: credential)
        
        return .init(name: response.name, created: response.created)
    }
    
    public func fetchAccountAddresses(_ credential: String) async throws -> [AddressName] {
        return try await api.addresses(with: credential)
    }
    
    public func fetchNowGarden() async throws -> [NowListing] {
        return try await api.nowGarden().map({ entry in
            NowListing(owner: entry.address, url: entry.url, updated: entry.updated.date)
        })
    }
    
    public func fetchAddressInfo(_ name: AddressName) async throws -> AddressModel {
        let profile = try await api.details(name)
        let url = URL(string: "https://\(name).omg.lol")
        let date = profile.registered.date
        return .init(name: name, url: url, registered: date)
    }
    
    public func fetchAddressNow(_ name: AddressName) async throws -> NowModel? {
        async let now = try api.now(for: name)
        async let page = try api.nowWebpage(for: name)
        let content = try await now.content
        let updated = try await now.updated
        let listed = try await now.listed
        let html = try await page.content
        return .init(
            owner: name,
            content: content,
            html: html,
            updated: updated,
            listed: listed
        )
    }
    
    public func saveAddressNow(_ name: AddressName, content: String, credential: APICredential) async throws -> NowModel? {
        guard let now = try await api.saveNow(for: name, content: content, credential: credential) else {
            return nil
        }
        
        return NowModel(
            owner: name,
            content: now.content,
            updated: now.updated,
            listed: now.listed
        )
    }
    
    public func fetchAddressPURLs(_ name: AddressName, credential: APICredential?) async throws -> [PURLModel] {
        let purls = try await api.purls(from: name, credential: credential)
        return purls.map { purl in
            PURLModel(owner: purl.address, value: purl.name, destination: purl.url, listed: purl.listed)
        }
    }
    
    public func fetchPURL(_ id: String, from address: AddressName, credential: APICredential?) async throws -> PURLModel? {
        let purl = try await api.purl(id, for: address, credential: credential)
        return PURLModel(owner: purl.address, value: purl.name, destination: purl.url, listed: purl.listed)
    }
    
    public func fetchPURLContent(_ id: String, from address: AddressName, credential: APICredential?) async throws -> String? {
        let purlContent = try await api.purlContent(id, for: address, credential: credential)
        return purlContent
    }
    
    public func savePURL(_ draft: PURLModel.Draft, to address: AddressName, credential: APICredential) async throws -> PURLModel? {
        let newPurl = PURL.Draft(name: draft.name, content: draft.content, listed: draft.listed)
        let _ = try await api.savePURL(newPurl, to: address, credential: credential)
        return try await fetchPURL(draft.name, from: address, credential: credential)
    }
    
    public func fetchAddressPastes(_ name: AddressName, credential: APICredential? = nil) async throws -> [PasteModel] {
        let pastes = try await api.pasteBin(for: name, credential: credential)
        return pastes.map { paste in
            PasteModel(owner: paste.author, name: paste.title, content: paste.content)
        }
    }
    
    public func fetchPaste(_ id: String, from address: AddressName, credential: APICredential? = nil) async throws -> PasteModel? {
        guard !address.isEmpty, !id.isEmpty else {
            return nil
        }
        do {
            guard let paste = try await api.paste(id, from: address, credential: credential) else {
                return nil
            }
            return PasteModel(owner: paste.author, name: paste.title, content: paste.content, listed: paste.listed)
        } catch let error as APIError {
            switch error {
            case .notFound:
                return nil
            default:
                throw error
            }
        }
    }
    
    public func savePaste(_ draft: PasteModel.Draft, to address: AddressName, credential: APICredential) async throws -> PasteModel? {
        let newPaste = Paste.Draft(title: draft.name, content: draft.content, listed: draft.listed)
        guard let paste = try await api.savePaste(newPaste, to: address, credential: credential) else {
            return nil
        }
        return PasteModel(owner: paste.author, name: paste.title, content: paste.content)
    }
    
    public func fetchStatusLog() async throws -> [StatusModel] {
        let log = try await api.latestStatusLog()
        return log.statuses.map { status in
            StatusModel(
                id: status.id,
                address: status.address,
                posted: status.created,
                status: status.content,
                emoji: status.emoji,
                linkText: status.externalURL?.absoluteString,
                link: status.externalURL
            )
        }
    }
    
    public func fetchAddressStatuses(addresses: [AddressName]) async throws -> [StatusModel] {
        var statuses: [StatusModel] = []
        try await withThrowingTaskGroup(of: [StatusModel].self, body: { group in
            for address in addresses {
                group.addTask {
                    async let log = try api.statusLog(from: address)
                    return try await log.statuses.map({ status in
                        StatusModel(
                            id: status.id,
                            address: status.address,
                            posted: status.created,
                            status: status.content,
                            emoji: status.emoji,
                            linkText: status.externalURL?.absoluteString,
                            link: status.externalURL
                        )
                    })
                }
                for try await log in group {
                    statuses.append(contentsOf: log)
                }
            }
        })
        return statuses
            .compactMap({ $0 })
    }
    
    public func fetchAddressStatus(_ id: String, from address: AddressName) async throws -> StatusModel? {
        let status = try await api.status(id, from: address)
        return .init(id: id, address: address, posted: status.created, status: status.content, emoji: status.emoji, linkText: status.externalURL?.absoluteString, link: status.externalURL)
    }
    
    public func saveStatusDraft(_ draft: StatusModel.Draft, to address: AddressName, credential: APICredential) async throws -> StatusModel? {
        let newStatus: Status.Draft = .init(id: draft.id, content: draft.content, emoji: draft.emoji, externalUrl: draft.externalUrl)
        let status = try await api.saveStatus(newStatus, to: address, credential: credential)
        return .init(id: status.id, address: status.address, posted: status.created, status: status.content, emoji: status.emoji, linkText: status.externalURL?.absoluteString, link: status.externalURL)
    }
    
    public func fetchAddressBio(_ name: AddressName) async throws -> AddressBioModel {
        let bio = try await api.bio(for: name)
        return .init(address: name, bio: bio.content)
    }
    
    public func fetchAddressProfile(_ name: AddressName, credential: APICredential? = nil) async throws -> AddressProfile? {
        var content: String?
        if let credential = credential {
            let profile = try await api.profile(name, with: credential)
            content = profile.content
        } else {
            let profile = try await api.publicProfile(name)
            content = profile.content
        }
        guard let content = content else {
            return nil
        }
        return .init(owner: name, content: content)
    }
    
    public func saveAddressProfile(_ name: AddressName, content: String, credential: APICredential) async throws -> AddressProfile? {
        let profile = try await api.saveProfile(content, for: name, with: credential)
        
        return .init(owner: name, content: profile.content)
    }
}


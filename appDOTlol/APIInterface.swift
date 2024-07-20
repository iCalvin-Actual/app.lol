//
//  APIInterface.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 3/5/23.
//

import omgapi
import omgui
import Foundation

final class APIDataInterface: DataInterface, Sendable {
    
    let api: omgapi.api = .init()
    
    static let clientId: String = "5e171c460ba4b7a7ceaf86295ac169d2"
    static let clientSecret: String = "6937ec29a6811d676615d783ab071bb8"
    static let redirect: String = "app-omg-lol://oauth"
    
    public init() { }
    
    public func fetchAccessToken(authCode: String, clientID: String, clientSecret: String, redirect: String) async throws -> String? {
        try await api.oAuthExchange(with: clientID, and: clientSecret, redirect: redirect, code: authCode)!
    }
    
    nonisolated 
    public func authURL() -> URL? {
        api.authURL(with: Self.clientId, redirect: Self.redirect)
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
    
    public func fetchAddressPURLs(_ name: AddressName, credential: APICredential?) async throws -> [PURLResponse] {
        let purls = try await api.purls(from: name, credential: credential)
        return purls.map { purl in
            PURLResponse(owner: purl.address, value: purl.name, destination: purl.url, listed: purl.listed)
        }
    }
    
    public func fetchPURL(_ id: String, from address: AddressName, credential: APICredential?) async throws -> PURLResponse? {
        let purl = try await api.purl(id, for: address, credential: credential)
        return PURLResponse(owner: purl.address, value: purl.name, destination: purl.url, listed: purl.listed)
    }
    
    public func deletePURL(_ id: String, from address: AddressName, credential: APICredential) async throws {
        try await api.deletePURL(id, for: address, credential: credential)
    }
    
    public func fetchPURLContent(_ id: String, from address: AddressName, credential: APICredential?) async throws -> String? {
        do {
            let purlContent = try await api.purlContent(id, for: address, credential: credential)
            return purlContent
        } catch {
            throw error
        }
    }
    
    public func savePURL(_ draft: PURLResponse.Draft, to address: AddressName, credential: APICredential) async throws -> PURLResponse? {
        let newPurl = PURL.Draft(name: draft.name, content: draft.content.urlString, listed: draft.listed)
        do {
            let _ = try await api.savePURL(newPurl, to: address, credential: credential)
            
            return try await fetchPURL(draft.name, from: address, credential: credential)
        } catch {
            throw error
        }
    }
    
    public func fetchAddressPastes(_ name: AddressName, credential: APICredential? = nil) async throws -> [PasteResponse] {
        let pastes = try await api.pasteBin(for: name, credential: credential)
        return pastes.map { paste in
            PasteResponse(owner: paste.author, name: paste.title, content: paste.content)
        }
    }
    
    public func fetchPaste(_ id: String, from address: AddressName, credential: APICredential? = nil) async throws -> PasteResponse? {
        guard !address.isEmpty, !id.isEmpty else {
            return nil
        }
        do {
            guard let paste = try await api.paste(id, from: address, credential: credential) else {
                return nil
            }
            return PasteResponse(owner: paste.author, name: paste.title, content: paste.content, listed: paste.listed)
        } catch let error as APIError {
            switch error {
            case .notFound:
                return nil
            default:
                throw error
            }
        }
    }
    
    public func deletePaste(_ id: String, from address: AddressName, credential: APICredential) async throws {
        try await api.deletePaste(id, for: address, credential: credential)
    }
    
    public func savePaste(_ draft: PasteResponse.Draft, to address: AddressName, credential: APICredential) async throws -> PasteResponse? {
        let newPaste = Paste.Draft(title: draft.name, content: draft.content, listed: draft.listed)
        guard let paste = try await api.savePaste(newPaste, to: address, credential: credential) else {
            return nil
        }
        return PasteResponse(owner: paste.author, name: paste.title, content: paste.content)
    }
    
    public func fetchStatusLog() async throws -> [StatusResponse] {
        let log = try await api.latestStatusLog()
        return log.statuses.map { status in
            StatusResponse(
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
    
    public func fetchAddressStatuses(addresses: [AddressName]) async throws -> [StatusResponse] {
        var statuses: [StatusResponse] = []
        try await withThrowingTaskGroup(of: [StatusResponse].self, body: { group in
            for address in addresses {
                group.addTask { [weak self] in
                    guard let self = self else { return [] }
                    async let log = try api.statusLog(from: address)
                    return try await log.statuses.map({ status in
                        StatusResponse(
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
    
    public func fetchAddressStatus(_ id: String, from address: AddressName) async throws -> StatusResponse? {
        let status = try await api.status(id, from: address)
        return .init(id: id, address: address, posted: status.created, status: status.content, emoji: status.emoji, linkText: status.externalURL?.absoluteString, link: status.externalURL)
    }
    
    public func deleteAddressStatus(_ draft: StatusResponse.Draft, from address: AddressName, credential: APICredential) async throws -> StatusResponse? {
        let deleteStatus: Status.Draft = .init(id: draft.id, content: draft.content, emoji: draft.emoji, externalUrl: draft.externalUrl)
        guard let status = try await api.deleteStatus(deleteStatus, from: address, credential: credential) else {
            return nil
        }
        return .init(id: status.id, address: address, posted: status.created, status: status.content, emoji: status.emoji, linkText: status.externalURL?.absoluteString, link: status.externalURL)
    }
    
    public func saveStatusDraft(_ draft: StatusResponse.Draft, to address: AddressName, credential: APICredential) async throws -> StatusResponse? {
        let newStatus: Status.Draft = .init(id: draft.id, content: draft.content, emoji: draft.emoji.isEmpty ? "💗" : draft.emoji, externalUrl: draft.externalUrl)
        let status = try await api.saveStatus(newStatus, to: address, credential: credential)
        return .init(id: status.id, address: status.address, posted: status.created, status: status.content, emoji: status.emoji, linkText: status.externalURL?.absoluteString, link: status.externalURL)
    }
    
    public func fetchAddressBio(_ name: AddressName) async throws -> AddressBioResponse {
        let bio = try await api.bio(for: name)
        return .init(address: name, bio: bio.content)
    }
    
    public func fetchAddressProfile(_ name: AddressName, credential: APICredential? = nil) async throws -> AddressProfile? {
        let content: String?
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

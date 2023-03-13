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
    
    public func fetchGlobalBlocklist() async throws -> [AddressName] {
        []
    }
    
    public func fetchServiceInfo() async throws -> ServiceInfoModel {
        let info = try await api.serviceInfo()
        return ServiceInfoModel(members: info.members, addresses: info.addresses, profiles: info.profiles)
    }
    
    public func fetchAddressDirectory() async throws -> [AddressName] {
        return try await api.addressDirectory()
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
        let now = try await api.now(for: name)
        return .init(owner: now.address, content: now.content, updated: now.updated, listed: now.listed)
    }
    
    public func fetchAddressPURLs(_ name: AddressName) async throws -> [PURLModel] {
        let purls = try await api.purls(from: name, credential: nil)
        return purls.map { purl in
            PURLModel(owner: purl.address, value: purl.name, destination: purl.url)
        }
    }
    
    public func fetchAddressPastes(_ name: AddressName) async throws -> [PasteModel] {
        let pastes = try await api.pasteBin(for: name, credential: nil)
        return pastes.map { paste in
            PasteModel(owner: paste.author, name: paste.title, content: paste.content)
        }
    }
    
    public func fetchPaste(_ id: String, from address: AddressName) async throws -> PasteModel? {
        let paste = try await api.paste(id, from: address, credential: nil)
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
    
    public func fetchAddressBio(_ name: AddressName) async throws -> AddressBioModel {
        let bio = try await api.bio(for: name)
        return .init(address: name, bio: bio.content)
    }
    
    public func fetchAddressProfile(_ name: AddressName) async throws -> AddressProfile? {
        let profile = try await api.publicProfile(name)
        guard let content = profile.content else {
            return nil
        }
        return .init(owner: name, content: content)
    }
}


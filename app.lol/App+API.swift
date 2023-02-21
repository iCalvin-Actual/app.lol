import api_core
import api_account
import api_now
import api_purl
import api_profile
import api_pastebin
import api_addresses
import api_statuslog
import SwiftUI
import UIDotAppDotLOL

struct APIDataInterface: OMGDataInterface {
    let api = omg_api()
    
    public init() { }
    public func fetchGlobalBlocklist() async -> [AddressName] {
        []
    }
    
    public func fetchServiceInfo() async -> ServiceInfoModel {
        do {
            let info = try await api.serviceInfo()
            return ServiceInfoModel(members: info.members, addresses: info.addresses, profiles: info.profiles) 
        } catch {
            return ServiceInfoModel(members: nil, addresses: nil, profiles: nil)
        }
    }
    
    public func fetchAddressDirectory() async -> [AddressName] {
        do {
            return try await api.addressDirectory()
        } catch {
            return []            
        }
    }
    
    public func fetchNowGarden() async -> [NowListing] {
        do {
            return try await api.nowGarden().map({ entry in
                NowListing(owner: entry.address, url: entry.url, updated: entry.updated.date)
            })
        } catch {
            return []
        }
    }
    
    public func fetchAddressInfo(_ name: AddressName) async -> AddressModel {
        do {
            let profile = try await api.details(name)
            let url = URL(string: "https://\(name).omg.lol")
            let date = profile.registered.date
            return .init(name: name, url: url, registered: date)
        } catch {
            return .init(name: name, url: URL(string: "https://\(name).omg.lol"), registered: Date())
        }
    }
    
    public func fetchAddressNow(_ name: AddressName) async -> NowModel? {
        do {
            let now = try await api.now(for: name)
            return .init(owner: now.address, content: now.content, updated: now.updated, listed: now.listed)
        } catch {
            return nil
        }
    }
    
    public func fetchAddressPURLs(_ name: AddressName) async -> [PURLModel] {
        do {
            let purls = try await api.purls(from: name, credential: nil)
            return purls.map { purl in
                PURLModel(owner: purl.address, value: purl.name, destination: purl.url)
            }
        } catch {
            return []
        }
    }
    
    public func fetchAddressPastes(_ name: AddressName) async -> [PasteModel] {
        do {
            let pastes = try await api.pasteBin(for: name, credential: nil)
            return pastes.map { paste in
                PasteModel(owner: paste.author, name: paste.title, content: paste.content)
            }
        } catch {
            return []
        }
    }
    
    public func fetchStatusLog() async -> [StatusModel] {
        do {
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
        } catch {
            return []
        }
    }
    
    public func fetchAddressStatuses(addresses: [AddressName]) async -> [StatusModel] {
        var statuses: [StatusModel?] = []
        do {
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
        } catch {
            return []
        }
    }
    
    public func fetchAddressProfile(_ name: AddressName) async -> String? {
        do {
            let profile = try await api.publicProfile(name)
            return profile.content
        } catch {
            return nil
        }
    }
}

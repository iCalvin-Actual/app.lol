//
//  RemoteListFetchers.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/11/25.
//

import Foundation

@Observable
class AccountAddressFetcher: ListFetcher<AddressModel> {
    override var title: String {
        "my addresses"
    }
    let credential: String
    
    init(credential: APICredential) {
        self.credential = credential
        super.init(limit: .max)
    }
    
    @MainActor
    override func throwingRequest() async throws {
        guard !credential.isEmpty else {
            results = []
            return
        }
        
        var results: [AddressModel] = []
        let addresses = try await interface.fetchAccountAddresses(credential)
        for address in addresses {
            results.append(try await interface.fetchAddressInfo(address))
        }
        
        self.results = results.sorted(with: .alphabet)
    }
    
    func clear() {
        self.results = []
    }
}

class AddressFollowingFetcher: ListFetcher<AddressModel> {
    var address: AddressName
    var credential: APICredential?
    
    override var title: String {
        "following"
    }
    
    init(address: AddressName, credential: APICredential?) {
        self.address = address
        self.credential = credential
        super.init(limit: .max)
    }
    
    func configure(address: AddressName, credential: APICredential?, _ automation: AutomationPreferences = .init()) {
        if self.address != address {
            results = []
        }
        self.address = address
        self.credential = credential
        super.configure(automation)
    }
    
    @MainActor
    override func throwingRequest() async throws {
        guard !address.isEmpty else {
            return
        }
        let fetched = try await interface.fetchAddressFollowing(address).map({ AddressModel(name: $0) })
        self.results = fetched
    }
    
    @MainActor
    func follow(_ toFollow: AddressName, credential: APICredential) async {
        do {
            try await interface.followAddress(toFollow, from: address, credential: credential)
            self.results.append(.init(name: toFollow))
        } catch {
            if error.localizedDescription.contains("You're already following"), !self.results.contains(where: { $0.addressName == toFollow }) {
                self.results.append(.init(name: toFollow))
            }
        }
    }
    
    @MainActor
    func unFollow(_ toRemove: AddressName, credential: APICredential) async {
        do {
            try await interface.unfollowAddress(toRemove, from: address, credential: credential)
            self.results.removeAll(where: { $0.addressName == toRemove })
        } catch {
            if error.localizedDescription.contains("You're not following"), self.results.contains(where: { $0.addressName == toRemove }) {
                self.results.removeAll(where: { $0.addressName == toRemove })
            }
        }
    }
}

class AddressFollowersFetcher: ListFetcher<AddressModel> {
    var address: AddressName
    var credential: APICredential?
    
    override var title: String {
        "followers"
    }
    
    init(address: AddressName, credential: APICredential?) {
        self.address = address
        self.credential = credential
        super.init(limit: .max)
    }
    
    func configure(address: AddressName, credential: APICredential?, _ automation: AutomationPreferences = .init()) {
        if self.address != address {
            results = []
        }
        self.address = address
        self.credential = credential
        super.configure(automation)
    }
    
    @MainActor
    override func throwingRequest() async throws {
        guard !address.isEmpty else {
            return
        }
        
        do {
            let results = try await interface.fetchAddressFollowers(address).map({ AddressModel(name: $0) })
            self.results = results
        } catch {
            throw error
        }
    }
}

class AddressBlockListFetcher: ListFetcher<AddressModel> {
    var address: AddressName
    var credential: APICredential?
    
    override var title: String {
        "blocked from \(address)"
    }
    
    init(address: AddressName, credential: APICredential?, automation: AutomationPreferences = .init()) {
        self.address = address
        self.credential = credential
        super.init(limit: .max)
    }
    
    func configure(address: AddressName, credential: APICredential?, _ automation: AutomationPreferences = .init()) {
        if self.address != address {
            results = []
        }
        self.address = address
        self.credential = credential
        super.configure(automation)
    }
    
    override func throwingRequest() async throws {
        
        guard !address.isEmpty else {
            return
        }
        let address = address
        let credential = credential
        guard let blocked = try await interface.fetchPaste("app.lol.blocked", from: address, credential: credential) else {
            return
        }
        self.results = blocked.content.components(separatedBy: .newlines).map({ String($0) }).filter({ !$0.isEmpty }).map({ AddressModel(name: $0) })
    }
    
    func block(_ toBlock: AddressName, credential: APICredential) async {
        loading = true
        let newValue = Array(Set(self.results.map({ $0.addressName }) + [toBlock]))
        let newContent = newValue.joined(separator: "\n")
        let draft = PasteModel.Draft(
            address: address,
            name: "app.lol.blocked",
            content: newContent,
            listed: false
        )
        let address = address
        let credential = credential
        let _ = try? await self.interface.savePaste(draft, to: address, credential: credential)
        await self.handleItems(newValue)
        
    }
    
    func unBlock(_ toUnblock: AddressName, credential: APICredential) async {
        loading = true
        let newValue = results.map({ $0.addressName }).filter({ $0 != toUnblock })
        let newContent = newValue.joined(separator: "\n")
        let draft = PasteModel.Draft(
            address: address,
            name: "app.lol.blocked",
            content: newContent,
            listed: false
        )
        let address = address
        let credential = credential
        let _ = try? await interface.savePaste(draft, to: address, credential: credential)
        await self.handleItems(newValue)
    }
    
    private func handleItems(_ addresses: [AddressName]) async {
        self.results = addresses.map({ AddressModel(name: $0) })
        loaded = .init()
        await fetchFinished()
    }
}

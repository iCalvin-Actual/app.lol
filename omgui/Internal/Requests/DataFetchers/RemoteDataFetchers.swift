//
//  DataFetchers.swift
//  omgui
//
//  Created by Calvin Chestnut on 7/29/24.
//

import Blackbird
import Combine
import Foundation
import _WebKit_SwiftUI

typealias AddressProfilePageDataFetcher = WebPageDataFetcher<AddressProfilePage>
typealias AddressNowPageDataFetcher = WebPageDataFetcher<NowModel>

@MainActor
final class WebPageDataFetcher<M: RemoteBackedBlackbirdModel>: ModelBackedDataFetcher<M>, Sendable {
    let addressName: AddressName
    
    var html: String?
    
    @Published
    var page = WebPage()
    
    nonisolated
    var baseURL: URL {
        var url = URL(string: "https://\(addressName).omg.lol")!
        if M.self is NowModel.Type {
            url.append(path: "now")
        }
        return url
    }
    
    init(addressName: AddressName, html: String? = nil, interface: DataInterface, db: Blackbird.Database) {
        self.addressName = addressName
        self.html = html
        super.init(interface: interface, db: db)
        if let html {
            page.load(html: html, baseURL: baseURL)
        }
    }
    
    override func fetchModels() async throws {
        self.result = try await M.read(from: db, id: addressName)
        if let resultContent = result?.htmlContent, html != resultContent {
            self.html = resultContent
            page.load(html: resultContent, baseURL: baseURL)
        }
        
    }
    
    nonisolated override func fetchRemote() async throws -> Int {
        guard baseURL.scheme?.contains("http") ?? false else {
            return 0
        }
        let (data, _) = try await URLSession.shared.data(from: baseURL)
        let html = await MainActor.run { [weak self] in
            let html = self?.html ?? ""
            guard let url = self?.baseURL else { return html }
            self?.page.load(URLRequest(url: url))
            let htmlData = String(data: data, encoding: .utf8)
            self?.html = htmlData
            return htmlData ?? ""
        }
        return html.hashValue
    }
}

class URLContentDataFetcher: DataFetcher {
    let url: URL
    
    @Published
    var html: String?
    
    init(url: URL, html: String? = nil, interface: DataInterface) {
        self.url = url
        self.html = html
        super.init(interface: interface)
    }
    
    override func throwingRequest() async throws {
        
        guard url.scheme?.contains("http") ?? false else {
            return
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        self.html = String(data: data, encoding: .utf8)
    }
}

class AddressAvailabilityDataFetcher: DataFetcher {
    
    var address: String
    
    var available: Bool?
    var result: AddressAvailabilityModel?
    
    init(address: AddressName, interface: DataInterface) {
        self.address = address
        super.init(interface: interface)
    }
    
    func fetchAddress(_ address: AddressName) async throws {
        self.available = false
        self.address = address
        await self.updateIfNeeded(forceReload: true)
    }
    
    override func throwingRequest() async throws {
        
        let address = address
        guard !address.isEmpty else {
            return
        }
        let result = try await interface.fetchAddressAvailability(address)
        self.result = result
    }
}

class AddressIconDataFetcher: ModelBackedDataFetcher<AddressIconModel> {
    let address: AddressName
    
    init(address: AddressName, interface: DataInterface, db: Blackbird.Database) {
        self.address = address
        super.init(interface: interface, db: db)
    }
    
    override func fetchModels() async throws {
        result = try await AddressIconModel.read(from: db, id: address)
    }
    
    override func fetchRemote() async throws -> Int {
        guard let url = address.addressIconURL else {
            return 0
        }
        let response = try await URLSession.shared.data(from: url)
        let model = AddressIconModel(owner: address, data: response.0)
        try await model.write(to: db)
        return model.hashValue
    }
}

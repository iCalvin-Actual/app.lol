//
//  DataFetchers.swift
//  omgui
//
//  Created by Calvin Chestnut on 7/29/24.
//

import Blackbird
import Combine
import Foundation
import WebKit
import os

private let logger = Logger(subsystem: "RemoteDataFetchers", category: "webpage")

typealias AddressProfilePageDataFetcher = WebPageDataFetcher<AddressProfilePage>
typealias AddressNowPageDataFetcher = WebPageDataFetcher<NowModel>

@MainActor
final class WebPageDataFetcher<M: RemoteBackedBlackbirdModel>: ModelBackedDataFetcher<M>, Sendable {
    let address: AddressName
    
    var html: String?
    
    @Published
    var page = WebPage()
    
    @Published
    var theme: ThemeModel?
    
    @MainActor
    var baseURL: URL {
        var url = URL(string: "https://\(address).omg.lol")!
        if M.self is NowModel.Type {
            url.append(path: "now")
        }
        return url
    }
    
    init(addressName: AddressName, html: String? = nil) {
        self.address = addressName
        self.html = html
        super.init()
        if let html {
            Task {
                await loadPage(html)
            }
        }
    }
    
    private func setObservers() async {
        do {
            for try await navigation in page.navigations {
                switch navigation {
                case .finished:
                    theme = await getTheme()
                default:
                    break
                }
            }
        } catch {
            logger.error("WebPageDataFetcher navigation error: \(String(describing: error))")
        }
    }
    
    private func loadPage(_ html: String? = nil) async {
        page.load(html: html ?? "", baseURL: baseURL)
        await setObservers()
    }
    
    private func loadPage(_ request: URLRequest) async {
        page.load(request)
        await setObservers()
    }
    
    private func getTheme() async -> ThemeModel? {
        let jsResult = try? await page.callJavaScript(#"""
                const links = Array.from(
                    document.querySelectorAll('link[rel~="stylesheet"]')
                );

                // Walk from the *end* so the first match we hit is actually the last one in source order.
                const rx = /\/css\/(?:themes\/)?([a-z0-9_-]+)\.css/i;

                for (let i = links.length - 1; i >= 0; i--) {
                    const m = rx.exec(links[i].href);
                    if (m) return m[1];   // "default", "dracula", …
                }
                return null;
            """#)
        guard let themeId = jsResult as? String else {
            return nil
        }
        let themes = try? await interface.fetchThemes()
        return themes?.first(where: { $0.id == themeId })
    }
    
    override func fetchModels() async throws {
        self.result = try await M.read(from: db, id: address)
        if let resultContent = result?.htmlContent, html != resultContent {
            self.html = resultContent
            await loadPage(resultContent)
        }
    }
    
    nonisolated override func fetchRemote() async throws -> Int {
        let (data, _) = try await URLSession.shared.data(from: baseURL)
        await loadPage(URLRequest(url: baseURL))
        let html = await MainActor.run { [weak self] in
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
        super.init()
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
        super.init()
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
    
    init(address: AddressName) {
        self.address = address
        super.init()
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

extension Optional<ThemeModel> {
    var backgroundBehavior: Bool {
        switch self?.id {
        case "default", "gradient", "neonknight", "seamless-future":
            return false
        case nil:
            return false
        default:
            return true
        }
    }
}

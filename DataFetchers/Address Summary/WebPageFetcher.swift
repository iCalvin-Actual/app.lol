//
//  WebPageFetcher.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/11/25.
//

import Foundation
import WebKit

typealias AddressProfilePageFetcher = WebFetcher<AddressProfilePage>
typealias AddressNowPageFetcher = WebFetcher<NowModel>

@MainActor
@Observable
class WebFetcher<M: RemoteBackedBlackbirdModel>: DatabaseFetcher<M>, Sendable {
    let address: AddressName
    
    var html: String?
    var theme: ThemeModel?
    
    @MainActor
    var baseURL: URL {
        var url = URL(string: "https://\(address.puny).omg.lol")!
        if M.self is NowModel.Type {
            url.append(path: "now")
        }
        return url
    }
    
    init(addressName: AddressName, html: String? = nil) {
        self.address = addressName
        self.html = html
        super.init()
    }
    
    override func fetchModels() async throws {
        self.result = try await M.read(from: db, id: address)
        if let resultContent = result?.htmlContent, html != resultContent {
            self.html = resultContent
        }
    }
    
    nonisolated override func fetchRemote() async throws -> Int {
        let (data, _) = try await URLSession.shared.data(from: baseURL)
        let html = await MainActor.run { [weak self] in
            let htmlData = String(data: data, encoding: .utf8)
            self?.html = htmlData
            return htmlData ?? ""
        }
        return html.hashValue
    }
}

@MainActor
@Observable
@available(iOS 26.0, *)
class WebPageFetcher<M: RemoteBackedBlackbirdModel>: WebFetcher<M>, Sendable {
    var page = WebPage()
    
    override init(addressName: AddressName, html: String? = nil) {
        super.init(addressName: addressName, html: html)
        Task {
            await loadPage(html)
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
            requestLevelLogger.error("WebPageFetcher navigation error: \(String(describing: error))")
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
        try await super.fetchModels()
        
        if let resultContent = result?.htmlContent, html != resultContent {
            await loadPage(resultContent)
        }
    }
    
    override func throwingRequest() async throws {
        await loadPage(URLRequest(url: baseURL))
        try await super.throwingRequest()
    }
}

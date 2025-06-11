//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 7/29/24.
//

import AuthenticationServices
import Combine
import SwiftUI

@MainActor
@Observable
final class AccountAuthDataFetcher: NSObject, Sendable {
    private var webSession: ASWebAuthenticationSession?
    
    private var url: URL? {
        interface.authURL()
    }
    
    var loaded = false
    var loading = false
    
    private var error: Error?
    private var requests: [AnyCancellable] = []
    
    private let anchor = ASPresentationAnchor()
    
    @ObservationIgnored
    var authKey: Binding<APICredential>?
    
    let client: ClientInfo
    let interface: DataInterface
    
    init(authKey: Binding<APICredential>?, client: ClientInfo, interface: DataInterface) {
        self.client = client
        self.interface = interface
        self.authKey = authKey
        super.init()
        
        self.recreateWebSession()
    }
    
    func configure(_ binding: Binding<APICredential>?) {
        self.authKey = binding
    }
    
    private func recreateWebSession() {
        guard let url else {
            return
        }
        webSession = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: client.urlScheme
        ) { (callbackUrl, error) in
            guard let callbackUrl = callbackUrl else {
                if let error = error {
                    print("DEBUG: Error \(error)")
                } else {
                    print("DEBUG: Unknown error")
                }
                return
            }
            let components = URLComponents(url: callbackUrl, resolvingAgainstBaseURL: true)
            
            guard let code = components?.queryItems?.filter ({ $0.name == "code" }).first?.value else {
                return
            }
            let client = self.client
            Task { [weak self] in
                guard let self else { return }
                let token = try await interface.fetchAccessToken(
                    authCode: code,
                    clientID: client.id,
                    clientSecret: client.secret,
                    redirect: client.redirectUrl
                )
                setToken(token)
            }
        }
        self.webSession?.presentationContextProvider = self
    }
    
    func setToken(_ newValue: APICredential?) {
        guard let newValue else {
            return
        }
        authKey?.wrappedValue = newValue
    }
    
    func perform() {
        recreateWebSession()
        webSession?.start()
    }
    
    func logout() {
        authKey?.wrappedValue = ""
    }
}

extension AccountAuthDataFetcher: ASWebAuthenticationPresentationContextProviding {
    nonisolated
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        anchor
    }
}

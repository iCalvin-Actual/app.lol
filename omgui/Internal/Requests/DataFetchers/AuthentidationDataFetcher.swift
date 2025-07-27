//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 7/29/24.
//

import AuthenticationServices
import Combine
import SwiftUI
import os

private let logger = Logger(subsystem: "AccountAuthDataFetcher", category: "auth")

@Observable
final class AccountAuthDataFetcher: Sendable {
    
    private let webSession: WebAuthenticationSession
    
    private var url: URL? {
        interface.authURL()
    }
    
    let authKey: Binding<APICredential>?
    
    let client: ClientInfo
    let interface: DataInterface
    
    init(authKey: Binding<APICredential>?, session: WebAuthenticationSession, client: ClientInfo, interface: DataInterface) {
        self.webSession = session
        self.client = client
        self.interface = interface
        self.authKey = authKey
    }
    
    private func authenticate() async throws {
        guard let url = interface.authURL() else {
            return
        }
        do {
            let callbackUrl = try await webSession.authenticate(using: url, callback: .customScheme(client.urlScheme), additionalHeaderFields: [:])
            let components = URLComponents(url: callbackUrl, resolvingAgainstBaseURL: true)
            
            guard let code = components?.queryItems?.filter ({ $0.name == "code" }).first?.value else {
                return
            }
            let client = self.client
            let token = try await interface.fetchAccessToken(
                authCode: code,
                clientID: client.id,
                clientSecret: client.secret,
                redirect: client.redirectUrl
            )
            setToken(token)
        } catch {
            logger.error("Received error: \(String(describing: error))")
        }
    }
    
    func setToken(_ newValue: APICredential?) {
        authKey?.wrappedValue = newValue ?? ""
    }
    
    func perform() {
        Task {
            do {
                try await authenticate()
            } catch {
                logger.error("Authentication error: \(String(describing: error))")
            }
        }
    }
    
    func logout() {
        setToken(nil)
    }
}

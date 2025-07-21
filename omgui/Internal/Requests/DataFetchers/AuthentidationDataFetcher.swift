//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 7/29/24.
//

import AuthenticationServices
import Combine
import SwiftUI

@Observable
final class AccountAuthDataFetcher: NSObject, Sendable {
    
    private let webSession: WebAuthenticationSession
    
    private var url: URL? {
        interface.authURL()
    }
    
//    var loaded = false
//    var loading = false
    
    let authKey: Binding<APICredential>?
    
    let client: ClientInfo
    let interface: DataInterface
    
    init(authKey: Binding<APICredential>?, session: WebAuthenticationSession, client: ClientInfo, interface: DataInterface) {
        self.webSession = session
        self.client = client
        self.interface = interface
        self.authKey = authKey
        super.init()
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
            print("Received error: \(error.localizedDescription)")
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
                print("Authentication error: \(error.localizedDescription)")
            }
        }
    }
    
    func logout() {
        setToken(nil)
    }
}

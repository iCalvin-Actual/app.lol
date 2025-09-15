//
//  HTMLContentView.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/15/25.
//

#if os(iOS)
import SwiftUI
import WebKit

struct HTMLContentView: UIViewRepresentable {
    @MainActor
    class Coordinator: NSObject, WKNavigationDelegate {
        
        let activeAddress: AddressName?
        var pendingContent: String?
        
        var baseURL: URL?

        var handleURL: ((_ url: URL?) -> Void)?
        
        init(activeAddress: AddressName?, baseURL: URL? = nil, pendingContent: String? = nil, handleURL: ((_: URL?) -> Void)? = nil) {
            self.activeAddress = activeAddress
            self.baseURL = baseURL
            self.pendingContent = pendingContent
            self.handleURL = handleURL
        }
        
        nonisolated
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
            switch await (navigationAction.navigationType, navigationAction.request.url?.host() == nil) {
            /// This... isn't a great experience.
            /// Hold onto the code until we're ready to handle these links natively
            /*
            case (.linkActivated, true):
                // Should handle natively one day
                guard let address = activeAddress, let path = navigationAction.request.url?.path(), let omgURL = URL(string: "https://\(address).omg.lol".appending(path)) else {
                    // Host is empty and path is too? Cancel that
                    return .cancel
                }
                let request = URLRequest(url: omgURL)
                Task {
                    await webView.load(request)
                }
                return .cancel
             */
            case (.linkActivated, _):
                let url = await navigationAction.request.url
                Task { @MainActor in
                    handleURL?(url)
                }
                return .cancel
            default:
                return .allow
            }
        }
        
        nonisolated
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            MainActor.assumeIsolated {
                showPendingContentIfNeeded(in: webView)
            }
        }
        
        @MainActor
        func showContent(_ url: URL?, in webView: WKWebView) {
            webView.navigationDelegate = self
            guard let url else { return }
            self.baseURL = url
            webView.load(URLRequest(url: url))
        }
        
        @MainActor
        func showContent(_ newContent: String?, in webView: WKWebView) {
            webView.navigationDelegate = self
            if webView.isLoading {
                pendingContent = newContent
            } else if let newContent = newContent {
                webView.loadHTMLString(newContent, baseURL: baseURL)
            }
        }
        
        @MainActor
        private func showPendingContentIfNeeded(in webView: WKWebView) {
            if let pending = pendingContent {
                pendingContent = nil
                webView.loadHTMLString(pending, baseURL: baseURL)
            }
        }
    }
    
    let activeAddress: AddressName?
    let htmlContent: String?
    let baseURL: URL?
    
    @Binding
    var activeURL: URL?
    
    init(activeAddress: AddressName?, htmlContent: String?, baseURL: URL?, activeURL: Binding<URL?>) {
        self.activeAddress = activeAddress
        self.htmlContent = htmlContent
        self.baseURL = baseURL
        self._activeURL = activeURL
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(activeAddress: activeAddress, baseURL: baseURL) { url in
            activeURL = url
        }
    }
    
    func makeUIView(context: HTMLContentView.Context) -> WKWebView {
        let wkWebView = WKWebView()
        wkWebView.backgroundColor = .clear
        wkWebView.allowsLinkPreview = true
        wkWebView.allowsBackForwardNavigationGestures = true
        wkWebView.scrollView.contentInsetAdjustmentBehavior = .never
//        wkWebView.scrollView.contentInset = .init(top: 0, left: 0, bottom: 100, right: 0)
        return wkWebView
    }
    
    func updateUIView(_ uiView: WKWebView, context: HTMLContentView.Context) {
        if context.coordinator.baseURL != baseURL {
            context.coordinator.showContent(baseURL, in: uiView)
        }
    }
}

struct HTMLContentView_Previews: PreviewProvider {
    @State
    static var content: String = ""
    @State
    static var url: URL?
    
    static var previews: some View {
        TabView {
            HTMLContentView(activeAddress: "preview", htmlContent: content, baseURL: nil, activeURL: $url)
                .onAppear {
                    Task {
                        let new = try await SampleData().fetchAddressProfile("some")
                        Self.content = new?.content ?? "Failed"
                    }
                }
        }
    }
}
#endif

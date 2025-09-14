//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 5/23/24.
//

#if canImport(SafariServices)
import SafariServices
#endif
import SwiftUI

#if canImport(UIKit) && !os(tvOS)
struct SafariView: UIViewControllerRepresentable {

    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {

    }
}

#Preview {
    SafariView(url: URL(string: "www.apple.com")!)
}
#endif

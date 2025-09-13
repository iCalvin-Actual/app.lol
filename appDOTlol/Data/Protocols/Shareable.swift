//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/13/23.
//

import Foundation
import SwiftUI

protocol Sharable {
    var primaryCopy: CopyPacket? { get }
    var copyText: [CopyPacket] { get }
    var primaryURL: SharePacket? { get }
    var shareURLs: [SharePacket] { get }
}

extension Sharable {
    var primaryCopy: CopyPacket? { nil }
    var primaryURL: SharePacket? { nil }
    var moreCopy: [CopyPacket] {
        []
    }
    var shareURLs: [SharePacket] {
        []
    }
}

extension AddressModel: Sharable {
    var primaryCopy: CopyPacket? {
        .init(name: "address", content: addressName)
    }
    var copyText: [CopyPacket] {[ ]}
    
    var primaryURL: SharePacket? {
        guard !addressName.isEmpty, let urlSafeAddress = addressName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return nil
        }
        return .init(name: "Profile url", content: URL(string: "https://\(urlSafeAddress).omg.lol")!)
    }
    var shareURLs: [SharePacket] {[ ]}
}

extension AddressProfilePage: Sharable {
    var primaryCopy: CopyPacket? {
        .init(name: "name", content: owner)
    }
    var copyText: [CopyPacket] {[ ]}
    
    var primaryURL: SharePacket? {
        guard !owner.isEmpty, let urlSafeAddress = owner.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return nil
        }
        return .init(name: "web url", content: URL(string: "https://\(urlSafeAddress).omg.lol")!)
    }
    
    var shareURLs: [SharePacket] {[ ]}
}

extension NowModel: Sharable {
    var primaryCopy: CopyPacket? {
        .init(name: "/now url", content: "https://\(owner).omg.lol/now")
    }
    var copyText: [CopyPacket] {[ ]}
    
    var primaryURL: SharePacket? {
        guard !owner.isEmpty, let urlSafeAddress = owner.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return nil
        }
        return .init(name: "/now page", content: URL(string: "https://\(urlSafeAddress).omg.lol/now")!)
    }
    var shareURLs: [SharePacket] { [primaryURL].compactMap({ $0 }) }
}

extension NowListing: Sharable {
    var primaryCopy: CopyPacket? {
        .init(name: "/Now URL", content: url)
    }
    var copyText: [CopyPacket] {[ ]}
    
    var primaryURL: SharePacket? {
        guard !addressName.isEmpty else {
            return nil
        }
        return .init(name: "/Now page", content: URL(string: url)!)
    }
    var shareURLs: [SharePacket] {[ ]}
}

extension StatusModel: Sharable {
    var primaryCopy: CopyPacket? {
        .init(name: "status text", content: status)
    }
    var copyText: [CopyPacket] {
        [
            .init(name: "emoji", content: displayEmoji),
            .init(name: "url", content: urlString),
            .init(name: "address", content: owner)
        ]
    }
    
    var primaryURL: SharePacket? {
        return .init(name: "status link", content: URL(string: urlString)!)
    }
    var shareURLs: [SharePacket] {
        [
            .init(name: "\(owner.addressDisplayString) statuslog", content: URL(string: "https://\(owner).status.lol")!),
            .init(name: "profile url", content: URL(string: "https://\(owner).omg.lol")!),
            .init(name: "/now url", content: URL(string: "https://\(owner).omg.lol/now")!)
        ]
    }
}

extension PURLModel: Sharable {
    private var address: CopyPacket {
        .init(name: "Address", content: owner)
    }
    var primaryCopy: CopyPacket? {
        guard !content.isEmpty else {
            return address
        }
        return .init(name: "Copy URL", content: content)
    }
    var copyText: [CopyPacket] {
        if content.isEmpty {
            return [
                address
            ]
        } else {
            return []
        }
    }
    
    var primaryURL: SharePacket? {
        guard let url = URL(string: content) else {
            return nil
        }
        return .init(name: "Destination", content: url)
    }
    var shareURLs: [SharePacket] {
        [
            .init(name: "PURL", content: URL(string: "https://\(owner).url.lol/\(name)")!),
            .init(name: "Profile", content: URL(string: "https://\(owner).omg.lol")!)
        ]
    }
}

extension PasteModel: Sharable {
    private var addressCopy: CopyPacket {
        .init(name: "Address", content: owner)
    }
    var primaryCopy: CopyPacket? {
        guard !content.isEmpty else {
            return addressCopy
        }
        return .init(name: "Copy Content", content: content)
    }
    var copyText: [CopyPacket] {
        if let primaryURL {
            return [
                .init(name: "Copy URL", content: primaryURL.content.absoluteString)
            ]
        } else {
            return []
        }
    }
    
    var primaryURL: SharePacket? {
        guard let url = URL(string: "https://\(addressName).paste.lol/\(name)") else {
            return nil
        }
        return .init(name: "Paste URL", content: url)
    }
    var shareURLs: [SharePacket] {[ ]}
}

extension Sharable where Self: Menuable {
    @ViewBuilder
    func shareSection() -> some View {
#if os(iOS) || os(macOS)
        if let option = primaryURL {
            shareLink(option)
        }
        if !shareURLs.isEmpty {
            Menu {
                ForEach(shareURLs) { option in
                    shareLink(option)
                }
            } label: {
                Label("share", systemImage: "square.and.arrow.up")
            }
        }
        if let option = primaryCopy {
            Button {
                #if canImport(UIKit)
                UIPasteboard.general.string = option.content
                #elseif canImport(AppKit)
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                pasteboard.setString(option.content, forType: .string)
                #endif
            } label: {
                Label("copy \(option.name)", systemImage: "doc.on.clipboard")
            }
        }
        if !copyText.isEmpty {
            Menu {
                ForEach(copyText) { option in
                    Button(option.name) {
                        #if canImport(UIKit)
                        UIPasteboard.general.string = option.content
                        #elseif canImport(AppKit)
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.setString(option.content, forType: .string)
                        #endif
                    }
                }
            } label: {
                Label("copy", systemImage: "doc.on.clipboard")
            }
        }
#endif
        Divider()
    }
    
    #if !os(tvOS)
    @ViewBuilder
    private func shareLink(_ option: SharePacket) -> some View {
        ShareLink(item: option.content) {
            Label("share \(option.name)", systemImage: "square.and.arrow.up")
        }
    }
    #endif
}

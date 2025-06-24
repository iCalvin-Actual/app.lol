//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import SwiftUI
import Foundation

protocol AddressManagable {
    var owner: AddressName { get }
}

protocol Menuable {
    associatedtype M: View
    
    @MainActor
    func contextMenu(in scene: SceneModel, fetcher: Request?) -> M
}

@MainActor
extension Menuable {
    @ViewBuilder
    func editingSection(in scene: SceneModel) -> some View {
        if let editable = self as? Editable, scene.addressBook.myAddresses.contains(editable.owner) {
            NavigationLink {
                scene.destinationConstructor.destination(editable.editingDestination)
            } label: {
                Label("edit", systemImage: "pencil.line")
            }
            Divider()
        }
    }
}

@MainActor
struct ContextMenuBuilder<T: Menuable> {
    @ViewBuilder
    func contextMenu(for item: T, fetcher: Request? = nil, sceneModel: SceneModel) -> some View {
        item.contextMenu(in: sceneModel, fetcher: fetcher)
    }
}

extension AddressManagable where Self: Menuable {
    @MainActor
    @ViewBuilder
    func manageSection(_ scene: SceneModel, fetcher: Request?) -> some View {
        let name = owner
        let book = scene.addressBook
        let isBlocked = book.isBlocked(name)
        let isPinned = book.isPinned(name)
        let canFollow = book.canFollow(name)
        let canUnfollow = book.canUnFollow(name)
        NavigationLink(value: NavigationDestination.address(name)) {
            Label("view profile", systemImage: "person.fill")
        }
        if !isBlocked {
            if canFollow {
                Button(action: {
                    Task {
                        await book.follow(name)
                        await fetcher?.updateIfNeeded(forceReload: true)
                    }
                }, label: {
                    Label("follow \(name.addressDisplayString)", systemImage: "plus.circle")
                })
            } else if canUnfollow {
                Button(action: {
                    Task {
                        await book.unFollow(name)
                        await fetcher?.updateIfNeeded(forceReload: true)
                    }
                }, label: {
                    Label("un-follow \(name.addressDisplayString)", systemImage: "minus.circle")
                })
            }
            
            if isPinned {
                Button(action: {
                    Task { [book, fetcher] in
                        await book.removePin(name)
                        await fetcher?.updateIfNeeded(forceReload: true)
                    }
                }, label: {
                    Label("un-Pin \(name.addressDisplayString)", systemImage: "pin.slash")
                })
            } else {
                Button(action: {
                    Task { [book, fetcher] in
                        await book.pin(name)
                        await fetcher?.updateIfNeeded(forceReload: true)
                    }
                }, label: {
                    Label("pin \(name.addressDisplayString)", systemImage: "pin")
                })
            }
            
            Divider()
            Menu {
                Button(role: .destructive, action: {
                    Task {
                        await book.block(name)
                        await fetcher?.updateIfNeeded(forceReload: true)
                    }
                }, label: {
                    Label("block", systemImage: "eye.slash.circle")
                })
                
                ReportButton(addressInQuestion: name)
            } label: {
                Label("safety", systemImage: "hand.raised")
            }
            Divider()
        } else {
            if book.canUnblock(name) {
                Button(action: {
                    Task { [book, fetcher] in
                        await book.unblock(name)
                        await fetcher?.updateIfNeeded(forceReload: true)
                    }
                }, label: {
                    Label("un-block", systemImage: "eye.circle")
                })
            }
            
            ReportButton(addressInQuestion: name)
        }
    }
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

extension Listable where Self: Menuable {
    func contextMenu(in scene: SceneModel) -> some View {
        EmptyView()
    }
}

extension ProfileMarkdown.Draft: Menuable {
    @ViewBuilder
    @MainActor
    func contextMenu(in scene: SceneModel, fetcher: Request?) -> some View {
        Group {
            self.editingSection(in: scene)
        }
    }
}

extension AddressModel: Menuable {
    @ViewBuilder
    @MainActor
    func contextMenu(in scene: SceneModel, fetcher: Request?) -> some View {
        Group {
            self.manageSection(scene, fetcher: fetcher)
            self.editingSection(in: scene)
            self.shareSection()
        }
    }
}

extension NowListing: Menuable {
    @ViewBuilder
    func contextMenu(in scene: SceneModel, fetcher: Request?) -> some View {
        Group {
            self.manageSection(scene, fetcher: fetcher)
            self.editingSection(in: scene)
            self.shareSection()
        }
    }
}

extension PURLModel: Menuable {
    @ViewBuilder
    func contextMenu(in scene: SceneModel, fetcher: Request?) -> some View {
        Group {
            self.manageSection(scene, fetcher: fetcher)
            self.editingSection(in: scene)
            self.shareSection()
        }
    }
}

extension PasteModel: Menuable {
    @ViewBuilder
    func contextMenu(in scene: SceneModel, fetcher: Request?) -> some View {
        Group {
            self.manageSection(scene, fetcher: fetcher)
            self.editingSection(in: scene)
            self.shareSection()
        }
    }
}

extension StatusModel: Menuable {
    @ViewBuilder
    func contextMenu(in scene: SceneModel, fetcher: Request?) -> some View {
        Group {
            self.manageSection(scene, fetcher: fetcher)
            self.editingSection(in: scene)
            self.shareSection()
        }
    }
}

struct ReportButton: View {
    @Environment(\.openURL)
    var openURL
    
    let addressInQuestion: AddressName?
    
    let overrideAction: (() -> Void)?
    
    init(addressInQuestion: AddressName? = nil, overrideAction: (() -> Void)? = nil) {
        self.addressInQuestion = addressInQuestion
        self.overrideAction = overrideAction
    }
    
    var body: some View {
        Button(action: overrideAction ?? {
            let subject = "app.lol content report"
            let body = "/*\nPlease describe the offending behavior, provide links where appropriate.\nWe will review the offending content as quickly as we can and respond appropriately.\n */ \nOffending address: \(addressInQuestion ?? "unknown")\nmy omg.lol address: \n\n"
            let coded = "mailto:app@omg.lol?subject=\(subject)&body=\(body)"
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

            if let coded = coded, let emailURL = URL(string: coded) {
                openURL(emailURL)
            }
        }, label: {
            Label("report", systemImage: "exclamationmark.bubble")
        })
    }
}

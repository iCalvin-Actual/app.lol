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

typealias ContextMenuFetchers = (
    following: AddressFollowingDataFetcher?,
    blocked: AddressBlockListDataFetcher?,
    localBlocked: LocalBlockListDataFetcher?,
    pinned: PinnedListDataFetcher?
)
protocol Menuable {
    associatedtype M: View
    
    @MainActor
    func contextMenu(
        with book: AddressBook,
        fetcher: Request?,
        menuFetchers: ContextMenuFetchers
    ) -> M
}

@MainActor
extension Menuable {
    @ViewBuilder
    func editingSection(with addressBook: AddressBook) -> some View { }
}

@MainActor
struct ContextMenuBuilder<T: Menuable> {
    @ViewBuilder
    func contextMenu(
        for item: T,
        fetcher: Request? = nil,
        addressBook: AddressBook,
        menuFetchers: ContextMenuFetchers
    ) -> some View {
        item.contextMenu(with: addressBook, fetcher: fetcher, menuFetchers: menuFetchers)
    }
}

extension AddressManagable where Self: Menuable {
    
    @MainActor
    @ViewBuilder
    func manageSection(
        _ book: AddressBook,
        fetcher: Request?,
        menuFetchers: ContextMenuFetchers
    ) -> some View {
        let name = owner
        let isBlocked = book.appliedBlocked.contains(name)
        let isPinned = book.pinned.contains(name)
        let canFollow = !book.followers.contains(name)
        let canUnfollow = book.followers.contains(name)
        NavigationLink(value: NavigationDestination.address(name)) {
            Label("view profile", systemImage: "person.fill")
        }
        if !isBlocked {
            if canFollow {
                Button(action: {
                    Task { [weak followingFetcher = menuFetchers.following, weak fetcher] in
                        await followingFetcher?.follow(name, credential: book.auth)
                        await fetcher?.updateIfNeeded(forceReload: true)
                    }
                }, label: {
                    Label("follow \(name.addressDisplayString)", systemImage: "plus.circle")
                })
            } else if canUnfollow {
                Button(action: {
                    Task { [weak followingFetcher = menuFetchers.following, weak fetcher] in
                        await followingFetcher?.unFollow(name, credential: book.auth)
                        await fetcher?.updateIfNeeded(forceReload: true)
                    }
                }, label: {
                    Label("un-follow \(name.addressDisplayString)", systemImage: "minus.circle")
                })
            }
            
            if isPinned {
                Button(action: {
                    Task { [weak pinnedFetcher = menuFetchers.pinned, weak fetcher] in
                        await pinnedFetcher?.removePin(name)
                        await fetcher?.updateIfNeeded(forceReload: true)
                    }
                }, label: {
                    Label("un-Pin \(name.addressDisplayString)", systemImage: "pin.slash")
                })
            } else {
                Button(action: {
                    Task { [weak pinnedFetcher = menuFetchers.pinned, weak fetcher] in
                        await pinnedFetcher?.pin(name)
                        await fetcher?.updateIfNeeded(forceReload: true)
                    }
                }, label: {
                    Label("pin \(name.addressDisplayString)", systemImage: "pin")
                })
            }
            
            Divider()
            Menu {
                Button(role: .destructive, action: {
                    Task { [weak fetcher, weak addressBlockedFetcher = menuFetchers.blocked, weak localBlockedFetcher = menuFetchers.localBlocked] in
                        await addressBlockedFetcher?.block(name, credential: book.auth)
                        await localBlockedFetcher?.insert(name)
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
            if book.blocked.contains(name) {
                Button(action: {
                    Task { [weak fetcher, weak addressBlockedFetcher = menuFetchers.blocked, weak localBlockedFetcher = menuFetchers.localBlocked] in
                        await addressBlockedFetcher?.unBlock(name, credential: book.auth)
                        await localBlockedFetcher?.remove(name)
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
    func contextMenu(for book: AddressBook) -> some View {
        EmptyView()
    }
}

extension ProfileMarkdown.Draft: Menuable {
    @ViewBuilder
    @MainActor
    func contextMenu(
        with book: AddressBook,
        fetcher: Request?,
        menuFetchers: ContextMenuFetchers
    ) -> some View {
        Group {
            self.editingSection(with: book)
        }
    }
}

extension AddressModel: Menuable {
    @ViewBuilder
    @MainActor
    func contextMenu(
        with book: AddressBook,
        fetcher: Request?,
        menuFetchers: ContextMenuFetchers
    ) -> some View {
        Group {
            self.manageSection(book, fetcher: fetcher, menuFetchers: menuFetchers)
            self.editingSection(with: book)
            self.shareSection()
        }
    }
}

extension NowListing: Menuable {
    @ViewBuilder
    func contextMenu(
        with book: AddressBook,
        fetcher: Request?,
        menuFetchers: ContextMenuFetchers
    ) -> some View {
        Group {
            self.manageSection(book, fetcher: fetcher, menuFetchers: menuFetchers)
            self.editingSection(with: book)
            self.shareSection()
        }
    }
}

extension PURLModel: Menuable {
    @ViewBuilder
    func contextMenu(
        with book: AddressBook,
        fetcher: Request?,
        menuFetchers: ContextMenuFetchers
    ) -> some View {
        Group {
            self.manageSection(book, fetcher: fetcher, menuFetchers: menuFetchers)
            self.editingSection(with: book)
            self.shareSection()
        }
    }
}

extension PasteModel: Menuable {
    @ViewBuilder
    func contextMenu(
        with book: AddressBook,
        fetcher: Request?,
        menuFetchers: ContextMenuFetchers
    ) -> some View {
        Group {
            self.manageSection(book, fetcher: fetcher, menuFetchers: menuFetchers)
            self.editingSection(with: book)
            self.shareSection()
        }
    }
}

extension StatusModel: Menuable {
    @ViewBuilder
    func contextMenu(
        with book: AddressBook,
        fetcher: Request?,
        menuFetchers: ContextMenuFetchers
    ) -> some View {
        Group {
            self.manageSection(book, fetcher: fetcher, menuFetchers: menuFetchers)
            self.editingSection(with: book)
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

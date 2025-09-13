//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 8/3/24.
//

import Foundation
import SwiftUI

extension AddressModel: Manageable { }
extension NowListing: Manageable { }

extension PicModel: Editable {
    var editingDestination: NavigationDestination {
        .pic(addressName, id: id)
    }
}

extension PURLModel: Editable {
    var editingDestination: NavigationDestination {
        .purl(addressName, id: name)
    }
}

extension PasteModel: Editable {
    var editingDestination: NavigationDestination {
        .paste(owner, id: name)
    }
}

extension StatusModel: Editable {
    var editingDestination: NavigationDestination {
        .status(owner, id: id)
    }
}

extension Manageable where Self: Menuable {
    @MainActor
    @ViewBuilder
    func manageSection(
        _ book: AddressBook,
        fetcher: Request?,
        menuFetchers: ContextMenuClosures
    ) -> some View {
        let name = owner
        let signedIn = book.signedIn
        let isBlocked = book.appliedBlocked.contains(name)
        let isPinned = book.pinned.contains(name)
        let canFollow = !book.followers.contains(name) && signedIn
        let canUnfollow = book.followers.contains(name) && signedIn
        if !isBlocked {
            if canFollow {
                Button(action: {
                    Task { [follow = menuFetchers.follow, weak fetcher] in
                        follow(name)
                        await fetcher?.updateIfNeeded(forceReload: true)
                    }
                }, label: {
                    Label("follow \(name.addressDisplayString)", systemImage: "plus.circle")
                })
            } else if canUnfollow {
                Button(action: {
                    Task { [unfollow = menuFetchers.unFollow, weak fetcher] in
                        unfollow(name)
                        await fetcher?.updateIfNeeded(forceReload: true)
                    }
                }, label: {
                    Label("un-follow \(name.addressDisplayString)", systemImage: "minus.circle")
                })
            }
            
            if isPinned {
                Button(action: {
                    Task { [unpin = menuFetchers.unPin, weak fetcher] in
                        unpin(name)
                        await fetcher?.updateIfNeeded(forceReload: true)
                    }
                }, label: {
                    Label("un-Pin \(name.addressDisplayString)", systemImage: "pin.slash")
                })
            } else {
                Button(action: {
                    Task { [pin = menuFetchers.pin, weak fetcher] in
                        pin(name)
                        await fetcher?.updateIfNeeded(forceReload: true)
                    }
                }, label: {
                    Label("pin \(name.addressDisplayString)", systemImage: "pin")
                })
            }
            
            Divider()
            Menu {
                Button(role: .destructive, action: {
                    Task { [block = menuFetchers.block, weak fetcher] in
                        block(name)
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
                    Task { [unblock = menuFetchers.unBlock, weak fetcher] in
                        unblock(name)
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

//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import SwiftUI
import Foundation

protocol Menuable {
    associatedtype M: View
    
    @MainActor
    func contextMenu(
        with book: AddressBook,
        fetcher: Request?,
        menuFetchers: ContextMenuClosures
    ) -> M
}

extension ProfileMarkdown.Draft: Menuable {
    @ViewBuilder
    @MainActor
    func contextMenu(
        with book: AddressBook,
        fetcher: Request?,
        menuFetchers: ContextMenuClosures
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
        menuFetchers: ContextMenuClosures
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
        menuFetchers: ContextMenuClosures
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
        menuFetchers: ContextMenuClosures
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
        menuFetchers: ContextMenuClosures
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
        menuFetchers: ContextMenuClosures
    ) -> some View {
        Group {
            self.manageSection(book, fetcher: fetcher, menuFetchers: menuFetchers)
            self.editingSection(with: book)
            self.shareSection()
        }
    }
}

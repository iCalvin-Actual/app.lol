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
        appActions: AppActions
    ) -> M
}

extension ProfileMarkdown.Draft: Menuable {
    @ViewBuilder
    @MainActor
    func contextMenu(
        with book: AddressBook,
        fetcher: Request?,
        appActions: AppActions
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
        appActions: AppActions
    ) -> some View {
        Group {
            self.manageSection(book, fetcher: fetcher, appActions: appActions)
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
        appActions: AppActions
    ) -> some View {
        Group {
            self.manageSection(book, fetcher: fetcher, appActions: appActions)
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
        appActions: AppActions
    ) -> some View {
        Group {
            self.manageSection(book, fetcher: fetcher, appActions: appActions)
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
        appActions: AppActions
    ) -> some View {
        Group {
            self.manageSection(book, fetcher: fetcher, appActions: appActions)
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
        appActions: AppActions
    ) -> some View {
        Group {
            self.manageSection(book, fetcher: fetcher, appActions: appActions)
            self.editingSection(with: book)
            self.shareSection()
        }
    }
}

extension PicModel: Menuable {
    @ViewBuilder
    func contextMenu(
        with book: AddressBook,
        fetcher: Request?,
        appActions: AppActions
    ) -> some View {
        Group {
            self.manageSection(book, fetcher: fetcher, appActions: appActions)
            self.editingSection(with: book)
            self.shareSection()
        }
    }
}

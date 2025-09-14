//
//  ContextMenuBuilder.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/11/25.
//

import SwiftUI

@MainActor
struct ContextMenuBuilder<T: Menuable> {
    @ViewBuilder
    func contextMenu(
        for item: T,
        fetcher: Request? = nil,
        addressBook: AddressBook,
        appActions: AppActions
    ) -> some View {
        item.contextMenu(with: addressBook, fetcher: fetcher, appActions: appActions)
    }
}

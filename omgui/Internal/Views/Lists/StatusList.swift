//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import Combine
import SwiftUI

struct StatusList: View {
    @ObservedObject
    var fetcher: StatusLogDataFetcher
    
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    @Environment(\.horizontalSizeClass)
    var sizeClass
    
    let filters: [FilterOption]
    
    var menuBuilder: ContextMenuBuilder<StatusModel>?
    
    var usingRegular: Bool {
        if #available(iOS 18.0, visionOS 2.0, *) {
            return TabBar.usingRegularTabBar(sizeClass: sizeClass)
        } else {
            return sizeClass == .regular && UIDevice.current.userInterfaceIdiom == .pad
        }
    }
    
    var body: some View {
        ListView<StatusModel, EmptyView>(
            filters: .everyone,
            dataFetcher: fetcher
        )
        .toolbarRole(.editor)
        .toolbar {
            ToolbarItem(placement: .principal) {
                if let first = fetcher.addresses.first, fetcher.addresses.count == 1 {
                    AddressNameView(first, suffix: "/statuses")
                }
            }
        }
    }
}

#Preview {
    let sceneModel = SceneModel.sample
    
    StatusList(fetcher: .init(addressBook: sceneModel.addressBook, interface: sceneModel.interface, db: sceneModel.database), filters: .everyone)
        .environment(sceneModel)
}

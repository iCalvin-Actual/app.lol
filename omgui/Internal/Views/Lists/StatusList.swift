//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import Combine
import SwiftUI

struct StatusList: View {
    @Environment(\.horizontalSizeClass)
    var sizeClass
    
    @ObservedObject
    var fetcher: StatusLogDataFetcher
    let filters: [FilterOption]
    
    var menuBuilder: ContextMenuBuilder<StatusModel>?
    
    var usingRegular: Bool {
        if #available(iOS 18.0, visionOS 2.0, *) {
            return TabBar.usingRegularTabBar(sizeClass: sizeClass)
        } else {
            #if canImport(UIKit)
            return sizeClass == .regular && UIDevice.current.userInterfaceIdiom == .pad
            #else
            return true
            #endif
        }
    }
    
    var body: some View {
        ListView<StatusModel, EmptyView>(
            filters: .everyone,
            dataFetcher: fetcher
        )
#if !os(tvOS)
        .toolbarRole(.editor)
        #endif
    }
}

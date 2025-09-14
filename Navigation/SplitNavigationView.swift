//
//  SplitNavigationView.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/14/25.
//

import SwiftUI


struct SplitNavigationView<V: View>: View {
    @Binding
        var selected: NavigationItem?
    @Binding
        var addAddress: Bool
    
    let tabModel: NavigationModel
    let tabContent: (NavigationItem) -> V
    
    var body: some View {
        NavigationSplitView {
            Sidebar(
                selected: $selected,
                addAddress: $addAddress,
                navigationModel: tabModel
            )
        } detail: {
            if let selected {
                tabContent(selected)
            }
        }
    }
}

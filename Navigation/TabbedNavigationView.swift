//
//  TabbedNavigationView.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/14/25.
//

import SwiftUI


struct TabbedNavigationView<V: View>: View {
    @Binding
        var selected: NavigationItem?
    
    let tabModel: NavigationModel
    
    let tabContent: (NavigationItem) -> V
    
    var body: some View {
        TabView(selection: $selected) {
            ForEach(tabModel.tabs) { item in
                Tab(item.displayString, systemImage: item.iconName, value: item, role: item == .search ? .search : nil) {
                    tabContent(item)
                }
            }
        }
    }
}

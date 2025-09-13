//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 8/2/24.
//

import SwiftUI


extension NavigationItem {
    @ViewBuilder
    var sidebarView: some View {
        label
    }
    
    var label: some View {
        Label(title: {
            Text(displayString)
        }) {
            Image(systemName: iconName)
        }
    }
}

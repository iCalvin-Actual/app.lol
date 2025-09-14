//
//  FilterOptionsButton.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/14/25.
//

import SwiftUI


struct FilterOptionsMenu: View {
    @Binding
    var filters: [FilterOption]
    
    var filterOptions: [FilterOption]
    
    private func button(_ filter: FilterOption) -> some View {
        Button {
            withAnimation {
                if filters.contains(filter) {
                    filters = .everyone
                } else {
                    filters = [filter]
                }
            }
        } label: {
            if filters.contains(filter) {
                Label(filter.displayString, systemImage: "checkmark")
            } else {
                Text(filter.displayString)
            }
        }
    }
    
    var body: some View {
        Menu {
            ForEach(filterOptions) { filter in
                button(filter)
            }
        } label: {
            Label("Filter", systemImage: "line.3.horizontal.decrease")
        }
        .buttonStyle(.borderless)
        .foregroundStyle(.secondary)
    }
}

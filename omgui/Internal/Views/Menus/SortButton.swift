//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct SortOrderMenu: View {
    @Binding
    var sort: Sort
    
    @Binding
    var filters: [FilterOption]
    
    var sortOptions: [Sort]
    
    var filterOptions: [FilterOption]
    
    private func button(_ sort: Sort) -> some View {
        Button {
            withAnimation {
                self.sort = sort
            }
        } label: {
            if self.sort == sort {
                Label(sort.displayString, systemImage: "checkmark")
            } else {
                Text(sort.displayString)
            }
        }
    }
    
    private func button(_ filter: FilterOption) -> some View {
        Button {
            withAnimation {
                if filters.contains(filter) {
                    filters.removeAll(where: { filter.rawValue == $0.rawValue })
                } else {
                    filters.append(filter)
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
            if sortOptions.count > 1 {
                ForEach(sortOptions) { sort in
                    button(sort)
                }
                if !filterOptions.isEmpty {
                    Divider()
                }
            }
            ForEach(filterOptions) { filter in
                button(filter)
            }
        } label: {
            Label("sort", systemImage: "arrow.up.arrow.down.square")
        }
    }
}

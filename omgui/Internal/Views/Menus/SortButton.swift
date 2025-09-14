//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
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

struct SortOrderMenu: View {
    @Binding
    var sort: Sort
    
    var sortOptions: [Sort]
    
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
    
    var body: some View {
        Menu {
            if sortOptions.count > 1 {
                ForEach(sortOptions) { sort in
                    button(sort)
                }
            }
        } label: {
            Label("Sort", systemImage: "arrow.up.arrow.down")
        }
    }
}

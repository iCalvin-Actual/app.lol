//
//  SortOrderButton.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/14/25.
//

import SwiftUI


struct SortOrderMenu: View {
    @Binding
        var sort: Sort
    
    let sortOptions: [Sort]
    
    var body: some View {
        Menu {
            if sortOptions.count > 1 {
                ForEach(sortOptions) { sort in
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
            }
        } label: {
            Label("Sort", systemImage: "arrow.up.arrow.down")
        }
    }
}

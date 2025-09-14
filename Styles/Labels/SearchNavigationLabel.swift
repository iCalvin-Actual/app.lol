//
//  Search.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/14/25.
//

import SwiftUI


struct SearchNavigationLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
                .padding(4)
            configuration.title
        }
        .foregroundStyle(.secondary)
    }
}

//
//  SearchNavigationButtonStyle.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/14/25.
//

import SwiftUI


struct SearchNavigationButtonStyle: ButtonStyle {
    let selected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .lineLimit(1)
            .bold(selected)
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(selected ? .white : .primary)
            .frame(minHeight: 44)
#if os(visionOS)
            .background(Material.regular)
            .clipShape(Capsule())
#else
            .glassEffect(glass, in: Capsule())
#endif
    }
    
#if !os(visionOS)
    var glass: Glass {
        if selected {
            return .regular.tint(Color.accentColor)
        }
        return .regular
    }
#endif
}

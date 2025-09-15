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
        // Build the core label once
        let base = coreBody(configuration: configuration)
#if os(visionOS)
        // visionOS path does not use Glass
        return base
            .background(Material.regular)
            .clipShape(Capsule())
#else
        // Use Glass on iOS 26+, otherwise fallback to material background
        if #available(iOS 26.0, *) {
            return base
                .glassEffect(glass, in: Capsule())
        } else {
            return base
                .background(selected ? Color.accentColor : Color.clear)
                .background(Material.regular)
                .clipShape(Capsule())
        }
#endif
    }
    
    @ViewBuilder
    func coreBody(configuration: Configuration) -> some View {
            configuration.label
                .lineLimit(1)
                .bold(selected)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(selected ? .white : .primary)
                .frame(minHeight: 44)
    }
    
#if !os(visionOS)
    @available(iOS 26.0, *)
    var glass: Glass {
        if selected {
            return .regular.tint(Color.accentColor)
        }
        return .regular
    }
#endif
}

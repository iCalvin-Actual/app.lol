//
//  Bool+.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/14/25.
//

import SwiftUI

extension Bool {
    @MainActor
    static func usingRegularTabBar(sizeClass: UserInterfaceSizeClass?, width: CGFloat? = nil) -> Bool {
        let width = width ?? .minimumRegularWidth
        #if canImport(UIKit)
        switch UIDevice.current.userInterfaceIdiom {
        case .vision,
                .mac,
                 .tv:
            return true
        case .pad:
            return (sizeClass ?? .regular) != .compact && width >= CGFloat.minimumRegularWidth
        default:
            return false
        }
        #elseif os(macOS)
        return true
        #endif
    }
}

fileprivate extension CGFloat {
    static let minimumRegularWidth: CGFloat = 665
}

//
//  ToolbarPlacement+.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/14/25.
//

import SwiftUI

extension ToolbarItemPlacement {
    static var safePrincipal: ToolbarItemPlacement {
        #if os(macOS)
        return .principal
        #else
        return .topBarLeading
        #endif
    }
}

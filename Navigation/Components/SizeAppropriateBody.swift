//
//  SizeAppropriateBody.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/14/25.
//

import SwiftUI

struct SizeAppropriateView<C: View, R: View>: View {
    
    let compact: () -> C
    let regular: () -> R
    
    let overrideSizeClass: UserInterfaceSizeClass?
    let preferredDefault: UserInterfaceSizeClass
    
    init(
        compact: @escaping () -> C,
        regular: @escaping () -> R,
        overrideSizeClass: UserInterfaceSizeClass? = nil,
        preferredDefault: UserInterfaceSizeClass = .compact
    ) {
        self.compact = compact
        self.regular = regular
        self.overrideSizeClass = overrideSizeClass
        self.preferredDefault = preferredDefault
    }
    
    var appliedSizeClass: UserInterfaceSizeClass? {
        overrideSizeClass ?? sizeClass
    }
    
    var body: some View {
        switch (appliedSizeClass, preferredDefault) {
        case (nil, .compact), (.compact, _):
            compact()
        case (nil, .regular), (.regular, _):
            regular()
        default:
            if preferredDefault == .compact {
                compact()
            } else {
                regular()
            }
        }
    }
    
    @Environment(\.horizontalSizeClass)
        var sizeClass
}

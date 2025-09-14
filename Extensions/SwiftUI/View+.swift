//
//  SwiftUI+.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/14/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func ifLet<I, V: View>(_ `optional`: I?, @ViewBuilder makeContent: (Self, I) -> V) -> some View {
        if let optional {
            makeContent(self, optional)
        } else {
            self
        }
    }
    @ViewBuilder
    func when<V: View>(_ conditional: Bool, @ViewBuilder makeContent: (Self) -> V) -> some View {
        if conditional {
            makeContent(self)
        } else {
            self
        }
    }
}

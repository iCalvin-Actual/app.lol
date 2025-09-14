//
//  Gradient+.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/14/25.
//

import SwiftUI


extension Gradient {
    /// Returns a new Gradient rotated by 180 degrees (half a turn).
    /// This effectively inverts the gradient by shifting each stop's location by 0.5 with wrap-around.
    func inverted() -> LinearGradient {
        var newStops: [Gradient.Stop] = []
        for set in stops.reversed() {
            newStops.append(.init(color: set.color, location: 1.0 - set.location))
        }
        return LinearGradient(stops: newStops, startPoint: .init(x: 0, y: 0), endPoint: .init(x: 1, y: 1))
    }
}

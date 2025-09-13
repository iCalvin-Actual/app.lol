//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 8/3/24.
//

import Foundation
import SwiftUI

typealias APICredential = String
typealias AddressName = String

extension AddressName {
    static let autoUpdatingAddress = "|_app.omg.lol.current_|"
    
    var addressIconURL: URL? {
        URL(string: "https://profiles.cache.lol/\(self)/picture")
    }
}

extension String {
    
    var boolValue: Bool {
        switch self.lowercased() {
        case "true", "t", "yes", "y":
            return true
        case "false", "f", "no", "n", "":
            return false
        default:
            if let int = Int(self) {
                return int != 0
            }
            return false
        }
    }
    
    /*
     Used to massage text input to force a valid URL.
     Assume https://\(self).com
     But if the field provides a scheme/domain it will be used
     */
    var urlString: String {
        var newText = self
        if !newText.contains("://") {
            newText = "https://" + newText
        }
        if !newText.contains(".") {
            newText = newText + ".com"
        }
        return newText
    }
    
    func clearWhitespace() -> String {
        filter { !$0.isWhitespace }
    }
}

extension Optional<String> {
    var boolValue: Bool {
        self?.boolValue ?? false
    }
}

extension Gradient {
    /// Returns a new Gradient whose stops are rotated by the given number of degrees around the unit interval.
    /// A rotation of 360 degrees yields the original gradient. Positive values rotate forward; negative values rotate backward.
    /// - Parameter degrees: The rotation in degrees.
    /// - Returns: A rotated Gradient.
    func rotated(byDegrees degrees: Double) -> Gradient {
        let fraction = degrees.truncatingRemainder(dividingBy: 360) / 360
        return rotated(by: fraction)
    }

    /// Returns a new Gradient whose stops are rotated by the given fraction of a full turn.
    /// - Parameter turns: The rotation as a fraction of a full cycle (1.0 == 360 degrees).
    /// - Returns: A rotated Gradient.
    func rotated(by turns: Double) -> Gradient {
        guard !stops.isEmpty else { return self }

        // Normalize shift to [0, 1)
        let shift = ((turns.truncatingRemainder(dividingBy: 1) + 1).truncatingRemainder(dividingBy: 1))

        // Shift each stop's location with wrap-around in [0, 1]
        let shiftedStops = stops.map { stop -> Gradient.Stop in
            var newLocation = stop.location + shift
            if newLocation >= 1 { newLocation -= 1 }
            return Gradient.Stop(color: stop.color, location: newLocation)
        }

        // Re-sort by location to keep gradient well-formed
        let sortedStops = shiftedStops.sorted { $0.location < $1.location }
        return Gradient(stops: sortedStops)
    }
}

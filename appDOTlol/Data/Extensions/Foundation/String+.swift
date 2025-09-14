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

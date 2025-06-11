//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import Foundation

extension String {
    func clearWhitespace() -> String {
        filter { !$0.isWhitespace }
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
}
extension Optional<String> {
    var boolValue: Bool {
        self?.boolValue ?? false
    }
}

extension AddressName {
    static let autoUpdatingAddress = "|_app.omg.lol.current_|"
    
    var addressIconURL: URL? {
        URL(string: "https://profiles.cache.lol/\(self)/picture")
    }
}

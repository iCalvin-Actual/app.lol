//
//  ThemeModel+.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/11/25.
//

import Foundation


extension Optional<ThemeModel> {
    var backgroundBehavior: Bool {
        switch self?.id {
        case "default", "gradient", "neonknight", "seamless-future":
            return false
        case nil:
            return false
        default:
            return true
        }
    }
}

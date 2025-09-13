//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI
import Foundation

extension Color {
//    static let lolBackground: Color =   Color("lolBackground")
    static let lolAccent: Color =       .init(hex: "e34199")
    
    static let lolPink: Color =         .init(hex: .hexPink)
    static let lolOrange: Color =       .init(hex: .hexOrange)
    static let lolYellow: Color =       .init(hex: .hexYellow)
    static let lolGreen: Color =        .init(hex: .hexGreen)
    static let lolTeal: Color =         .init(hex: .hexTeal)
    static let lolBlue: Color =         .init(hex: .hexBlue)
    static let lolPurple: Color =       .init(hex: .hexPurple)
    
    static var lolRandom: [Color] {
        String.lolRandom.map({ Color(hex: $0) })
    }
    
    static func lolRandom(_ input: String = .lolRandom.randomElement() ?? "000000", not: Color? = nil) -> Color {
        let colors: [Color] = String.lolRandom.map({ .init(hex: $0) })
        
        if let not, let undesiredIndex = colors.firstIndex(of: not) {
            let value = modFromString(input, cnt: colors.count - 1)
            let appliedValue: Int = undesiredIndex <= value ? value + 1 : value
            return colors[appliedValue]
        } else {
            return colors[modFromString(input, cnt: colors.count)]
        }
    }
    
    static func lolRandomAlternative(_ input: String = .lolRandom.randomElement() ?? "000000") -> Color {
        let colors: [Color] = String.lolRandom.map({ .init(hex: $0) })
        
        let ogValue = modFromString(input, cnt: colors.count) + 1
        
        return colors[ogValue > colors.endIndex ? ogValue : 0]
    }
    
    private static func modFromString(_ input: String, cnt: Int) -> Int {
        let hash = input.staticHash
        
        return abs(hash % cnt)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

fileprivate
extension String {
    static var hexGreen: String    { "0be899" }
    static var hexYellow: String   { "ffdf66" }
    static var hexTeal: String     { "65d8e7" }
    static var hexPink: String     { "f782ac" }
    static var hexPurple: String   { "d0bfff" }
    static var hexBlue: String     { "a5d8ff" }
    static var hexOrange: String   { "ffd8a8" }
    
    static var lolRandom: [String] {
        [
            .hexPink,
            .hexOrange,
            .hexYellow,
            .hexGreen,
            .hexTeal,
            .hexBlue,
            .hexPurple,
        ]
    }
}

//
//  File.swift
//
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

enum AddressContent: String, Identifiable, CaseIterable {
    
    var id: String { displayString }
    
    case profile
    case now
    case purl
    case pastebin
    case statuslog
    
    var displayString: String {
        switch self {
        case .profile:
            return "Profile"
        case .now:
            return "Now"
        case .purl:
            return "PURLs"
        case .pastebin:
            return "Pastes"
        case .statuslog:
            return "Logs"
        }
    }
    var icon: String {
        switch self {
        case .profile:
            return "person.circle"
        case .now:
            return "clock"
        case .purl:
            return "link"
        case .pastebin:
            return "list.clipboard"
        case .statuslog:
            return "bubble.left"
        }
    }
    
    var color: Color {
        switch self {
        case .profile:
            return .lolYellow
        case .now:
            return .lolGreen
        case .purl:
            return .lolTeal
        case .pastebin:
            return .lolOrange
        case .statuslog:
            return .lolPurple
        }
    }
    
    func destination(_ name: AddressName) -> NavigationDestination {
        switch self {
        case .profile:
            return .webpage(name)
        case .now:
            return .now(name)
        case .purl:
            return .purls(name)
        case .pastebin:
            return .pastebin(name)
        case .statuslog:
            return .statusLog(name)
        }
    }
}

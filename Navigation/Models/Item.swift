//
//  NavigationItem.swift
//  
//
//  Created by Calvin Chestnut on 3/10/23.
//

import Foundation
import SwiftUI

enum NavigationItem: Codable, Hashable, Identifiable, RawRepresentable {
    var id: String { rawValue }
    
    case account
    case safety
    case community
    case nowGarden
    case somePics
    case search
    case lists
    case learn
    case appLatest
    case appSupport
    
    case newPaste
    case newPURL
    case newStatus
    
    case pinnedAddress  (_ address: AddressName)
    
    var rawValue: String {
        switch self {
        case .account:                  return "account"
        case .safety:                   return "safety"
        case .community:                return "community"
        case .somePics:                 return "pics"
        case .nowGarden:                return "garden"
        case .search:                   return "search"
        case .lists:                    return "lists"
        case .learn:                    return "about"
            
        case .appLatest:                return "appNow"
        case .appSupport:               return "appSupport"
        
        case .newStatus:                return "new status"
        case .newPURL:                  return "new PURL"
        case .newPaste:                 return "new paste"
            
        case .pinnedAddress(let address):
                                        return "pinned.\(address)"
        }
    }
    
    init?(rawValue: String) {
        let splitString = rawValue.components(separatedBy: ".")
        switch splitString.first {
        case "account":     self = .account
        case "safety":      self = .safety
        case "community":   self = .community
        case "pics":        self = .somePics
        case "garden":      self = .nowGarden
        case "search":      self = .search
        case "lists":       self = .lists
        case "appNow":      self = .appLatest
        case "appSupport":  self = .appSupport
            
        case "new status":
            self = .newStatus
        case "new PURL":
            self = .newPURL
        case "new paste":
            self = .newPaste
            
        case "pinned":
            guard splitString.count > 1 else {
                return nil
            }
            self = .pinnedAddress(splitString[1])
            
        default:
            return nil
        }
    }
    
    var displayString: String {
        switch self {
        case .account:      return "/me"
        case .safety:       return "/safety"
        case .community:    return "/social"
        case .somePics:     return "/pics"
        case .nowGarden:    return "/now"
        case .search:       return "/directory"
        case .lists:        return "/me"
        case .learn:        return "/about"
        case .appLatest:    return "/latest"
        case .appSupport:   return "/support"
            
        case .newStatus:    return "/new"
        case .newPURL:      return "purl/new"
        case .newPaste:     return "paste/new"
            
        case .pinnedAddress(let address):
            return address.addressDisplayString
        }
    }
    
    var iconName: String {
        switch self {
        case .account:
            return "person"
        case .search:
            return "magnifyingglass"
        case .nowGarden:
            return "sun.horizon"
        case .somePics:
            return "camera.macro"
        case .community:
            return "star.bubble"
        case .pinnedAddress:
            return "person"
        case .safety:
            return "hand.raised"
        case .lists:
            return "person.crop.square.filled.and.at.rectangle"
        case .learn:
            return "book.closed"
        case .appLatest:
            return "app.badge"
        case .appSupport:
            return "questionmark.circle"
        case .newStatus, .newPURL, .newPaste:
            return "pencil.and.scribble"
        }
    }
    
    var role: TabRole? {
        switch self {
        case .search:
            return .search
        default:
            return nil
        }
    }
    
    var destination: NavigationDestination {
        switch self {
        case .account:
            return .account
        case .search:
            return .search
        case .nowGarden:
            return .nowGarden
        case .community:
            return .community
        case .somePics:
            return .somePics
        case .pinnedAddress(let name):
            return .address(name, page: .profile)
        case .safety:
            return .safety
        case .lists:
            return .lists
        case .appLatest:
            return .latest
        case .appSupport:
            return .support
        default:
            return .account
        }
    }
    
    @ViewBuilder
    var label: some View {
        Label(title: {
            Text(displayString)
        }) {
            Image(systemName: iconName)
        }
    }
}

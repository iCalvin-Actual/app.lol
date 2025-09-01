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
    case search
    case lists
    case learn
    case appLatest
    case appSupport
    
    case newPaste
    case newPURL
    case newStatus
    
    case following      (_ address: AddressName)
    case pinnedAddress  (_ address: AddressName)
    
    var rawValue: String {
        switch self {
        case .account:                  return "account"
        case .safety:                   return "safety"
        case .community:                return "community"
        case .nowGarden:                return "garden"
        case .search:                   return "search"
        case .lists:                    return "lists"
        case .learn:                    return "about"
            
        case .appLatest:                return "appNow"
        case .appSupport:               return "appSupport"
        
        case .newStatus:                return "new status"
        case .newPURL:                  return "new PURL"
        case .newPaste:                 return "new paste"
            
        case .following(let address):   return "following.\(address)"
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
            
        case "following":
            guard splitString.count > 1 else {
                self = .following(.autoUpdatingAddress)
                return
            }
            self = .following(splitString[1])
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
        case .community:    return "/statusLog"
        case .nowGarden:    return "/now"
        case .search:       return "/directory"
        case .lists:        return "/me"
        case .learn:        return "/about"
        case .appLatest:    return "/latest"
        case .appSupport:   return "/support"
            
        case .newStatus:    return "/new"
        case .newPURL:      return "purl/new"
        case .newPaste:     return "paste/new"
            
        case .following(let address):
            return (address == .autoUpdatingAddress ? "" : "\(address.addressDisplayString).") + "following"
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
        case .community:
            return "star.bubble"
        case .following:
            return "person.2"
        case .pinnedAddress:
            return "pin"
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
        case .following(let address):
            return .following(address)
        case .pinnedAddress(let name):
            return .address(name, page: .profile)
        case .safety:
            return .safety
        case .newStatus:
            return .editStatus(.autoUpdatingAddress, id: "")
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
}

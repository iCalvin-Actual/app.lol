//
//  NavigationDestination.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import Foundation
import SwiftUI

enum NavigationDestination: Codable, Hashable, Identifiable, RawRepresentable {
    var id: String { rawValue }
    
    case account
    case safety
    case community
    case directory
    case nowGarden
    case lists
    
    case about
    case latest
    case support
    
    case saved      (_ feature: AppFeature)
    case comingSoon (_ feature: AppFeature)
    
    case address    (_ name: AddressName)
    case following  (_ name: AddressName)
    case webpage    (_ name: AddressName)
    case now        (_ name: AddressName)
    case editNow    (_ name: AddressName)
    case purls      (_ name: AddressName)
    case pastebin   (_ name: AddressName)
    case statusLog  (_ name: AddressName)
    
    case paste  (_ name: AddressName, id: String)
    case purl   (_ name: AddressName, id: String)
    case status (_ name: AddressName, id: String)
    
    case editWebpage(_ name: AddressName)
    case editPaste  (_ name: AddressName, id: String)
    case editPURL   (_ name: AddressName, id: String)
    case editStatus (_ name: AddressName, id: String)
    
    var rawValue: String {
        switch self {
            
        case .account:      return "account"
        case .safety:       return "safety"
        case .community:    return "community"
        case .directory:    return "directory"
        case .nowGarden:    return "garden"
        case .lists:        return "lists"
        case .about:        return "about"
        case .latest:       return "latest"
        case .support:      return "support"
            
        case .saved(let feature):       return "saved.\(feature.rawValue)"
        case .comingSoon(let feature):  return "coming.\(feature.rawValue)"
            
        case .address(let address):     return "address.\(address)"
        case .following(let address):   return "following.\(address)"
        case .webpage(let address):     return "webpage.\(address)"
        case .now(let address):         return "now.\(address)"
        case .purls(let address):       return "purls.\(address)"
        case .pastebin(let address):    return "pastes.\(address)"
        case .statusLog(let address):   return "status.\(address)"
            
        case .status(let address, let id):      return "status.\(address).\(id)"
        case .paste(let address, let id):       return "paste.\(address).\(id)"
        case .purl(let address, let id):        return "purl.\(address).\(id)"

        case .editWebpage(let address): return "webpage.\(address).edit"
        case .editNow(let address):     return "now.\(address).edit"
        case .editStatus(let address, let id):  return "status.\(address).\(id).edit"
        case .editPURL(let address, let id):    return "purl.\(address).\(id).edit"
        case .editPaste(let address, let id):   return "paste.\(address).\(id).edit"
        }
    }
    
    init?(rawValue: String) {
        let splitString = rawValue.components(separatedBy: ".")
        switch splitString.first {
        case "account":     self = .account
        case "safety":      self = .safety
        case "community":   self = .community
        case "directory":   self = .directory
        case "garden":      self = .nowGarden
        case "lists":       self = .lists
        case "about":       self = .about
        case "latest":      self = .latest
        case "support":     self = .support
        case "following":
            guard splitString.count > 1, !splitString[1].isEmpty else {
                self = .following(.autoUpdatingAddress)
                return
            }
            self = .following(splitString[1])
        case "address":
            guard splitString.count > 1 else {
                return nil
            }
            self = .address(splitString[1])
        case "saved":
            guard splitString.count > 1, let feature = AppFeature(rawValue: splitString[1]) else {
                return nil
            }
            self = .saved(feature)
        case "coming":
            guard splitString.count > 1, let feature = AppFeature(rawValue: splitString[1]) else {
                return nil
            }
            self = .comingSoon(feature)
        case "webpage":
            guard splitString.count > 1 else {
                return nil
            }
            if splitString.last == "edit" {
                self = .editWebpage(splitString[1])
            } else {
                self = .webpage(splitString[1])
            }
        case "now":
            guard splitString.count > 1 else {
                return nil
            }
            if splitString.last == "edit" {
                self = .editNow(splitString[1])
            } else {
                self = .now(splitString[1])
            }
        case "paste":
            guard splitString.count > 2 else {
                return nil
            }
            let address = splitString[1]
            let title = splitString[2]
            self = .paste(address, id: title)
        case "pastes":
            guard splitString.count > 1 else {
                return nil
            }
            self = .pastebin(splitString[1])
        case "purls":
            guard splitString.count > 1 else {
                return nil
            }
            self = .purls(splitString[1])
        case "purl":
            guard splitString.count > 2 else {
                return nil
            }
            let address = splitString[1]
            let title = splitString[2]
            self = .purl(address, id: title)
        case "status":
            switch splitString.count {
            case 0, 1:
                self = .community
            case 2:
                self = .statusLog(splitString[1])
            default:
                if splitString.last == "edit" {
                    self = .editStatus(splitString[1], id: splitString[2])
                } else {
                    self = .status(splitString[1], id: splitString[2])
                }
            }
        default:
            return nil
        }
    }
}

extension NavigationDestination {
    public var color: Color {
        switch self {
        case .community:
            return .lolPink
        case .lists:
            return .lolPurple
        case .about:
            return .lolTeal.opacity(0.42)
        default:
            return .lolRandom(rawValue, not: .lolOrange)
        }
    }
    
    public var secondaryColor: Color {
        .lolOrange
    }
    
    public var gradient: Gradient {
        switch self {
        default:
            return .init(colors: [color, secondaryColor])
        }
    }
}

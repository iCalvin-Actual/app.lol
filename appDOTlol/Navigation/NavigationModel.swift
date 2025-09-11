//
//  NavigationModel.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import Combine
import Foundation
import SwiftUI

@MainActor
@Observable
class NavigationModel {
    enum Section: String, Identifiable, Hashable {
        var id: String { rawValue }
        
        case account
        case directory
        case now
        case status
        case saved
        case weblog
        case comingSoon
        case more
        case new
        case app
        
        var displayName: String {
            switch self {
            case .account:      return "my account"
            case .directory:    return "pinned"
            case .now:          return "/now pages"
            case .status:       return "status.lol"
            case .saved:        return "cache.app.lol"
            case .weblog:       return "blog.app.lol"
            case .comingSoon:   return "Coming Soon"
            case .more:         return ""
            case .new:          return "New"
            case .app:          return "app.lol"
            }
        }
    }
    
    var tabs: [NavigationItem] {
        [
            .community,
            .nowGarden,
            .search
        ]
    }
    
    var sections: [Section] {
        [.more, .directory, .app]
    }
    
    var sectionsForLists: [Section] {
        [.app, .more]
    }
    
    var addressBook: AddressBook
    
    init(addressBook: AddressBook) {
        self.addressBook = addressBook
    }
    
    func items(for section: Section, sizeClass: UserInterfaceSizeClass?, context: ViewContext) -> [NavigationItem] {
        switch section {
            
        case .directory:
            return addressBook.pinned.sorted().map({ .pinnedAddress($0) })
            
        case .now:
            return [.nowGarden]
            
        case .status:
            return [.community]
            
        case .app:
            if context == .detail {
                #if !canImport(UIKit)
                return [.appLatest, .appSupport, .safety]
                #else
                return []
                #endif
            } else {
                return [.appLatest, .appSupport, .safety]
            }
            
        case .more:
            return [.search, .community, .nowGarden]
            
        default:
            return []
            
        }
    }
}

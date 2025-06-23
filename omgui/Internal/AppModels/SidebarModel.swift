//
//  SidebarModel.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import Combine
import Foundation
import SwiftUI

@MainActor
class SidebarModel: ObservableObject {
    enum Section: String, Identifiable {
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
            case .directory:    return "address book"
            case .now:          return "/now pages"
            case .status:       return "status.lol"
            case .saved:        return "cache.app.lol"
            case .weblog:       return "blog.app.lol"
            case .comingSoon:   return "Coming Soon"
            case .more:         return "omg.lol"
            case .new:          return "New"
            case .app:          return "app.lol"
            }
        }
    }
    
    var tabs: [NavigationItem] {
        [
            .community,
            .lists,
            .search
        ]
    }
    
    var sections: [Section] {
        [.directory, .status, .now, .app]
    }
    
    var sectionsForLists: [Section] {
        [.app]
    }
    
    let sceneModel: SceneModel
    var addressBook: AddressBook { sceneModel.addressBook }
    
    @Published
    var pinnedFetcher: PinnedListDataFetcher
    
    init(sceneModel: SceneModel) {
        self.sceneModel = sceneModel
        self.pinnedFetcher = sceneModel.addressBook.pinnedAddressFetcher
    }
    
    func items(for section: Section, sizeClass: UserInterfaceSizeClass?, context: ViewContext) -> [NavigationItem] {
        switch section {
            
        case .directory:
            var destinations: [NavigationItem] = []
            if #unavailable(iOS 18.0) {
                destinations.append(.search)
            }
            destinations.append(
                contentsOf: addressBook.pinnedAddresses.sorted().map({ .pinnedAddress($0) })
            )
            return destinations
            
        case .now:
            let destinations = [
                NavigationItem.nowGarden
            ]
            return destinations
            
        case .status:
            let destinations = [
                NavigationItem.community
            ]
            return destinations
            
        case .app:
            if context == .detail {
                var destinations: [NavigationItem] = [.appSupport, .safety, .appLatest]
                if #unavailable(iOS 18.0) {
                    destinations.insert(.account, at: 0)
                }
                return destinations
            } else {
                var destinations: [NavigationItem] = [.appSupport, .appLatest]
                if #available(iOS 18.0, *) {
                    if TabBar.usingRegularTabBar(sizeClass: sizeClass) {
                        destinations.insert(.account, at: 0)
                    }
                } else {
                    destinations.insert(.account, at: 0)
                }
                return destinations
            }
            
        case .more:
            return [.learn]
            
        default:
            return []
            
        }
    }
}

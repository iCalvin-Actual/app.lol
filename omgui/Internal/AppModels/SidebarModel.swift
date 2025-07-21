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
@Observable
class SidebarModel {
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
            .nowGarden,
            .search
        ]
    }
    
    var sections: [Section] {
        [.directory, .status, .now, .app]
    }
    
    var sectionsForLists: [Section] {
        [.app]
    }
    
    var pinnedFetcher: PinnedListDataFetcher?
    
    init(pinnedFetcher: PinnedListDataFetcher?) {
        self.pinnedFetcher = pinnedFetcher
    }
    
    func items(for section: Section, sizeClass: UserInterfaceSizeClass?, context: ViewContext) -> [NavigationItem] {
        switch section {
            
        case .directory:
            var destinations: [NavigationItem] = []
            if #unavailable(iOS 18.0) {
                destinations.append(.search)
            }
            destinations.append(
                contentsOf: pinnedFetcher?.results.map(({ $0.addressName })).sorted().map({ .pinnedAddress($0) }) ?? []
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
                #if !canImport(UIKit)
                return [.appLatest, .appSupport, .safety]
                #else
                return []
                #endif
            } else {
                return [.account, .appLatest, .appSupport, .safety]
            }
            
        case .more:
            return [.learn]
            
        default:
            return []
            
        }
    }
}

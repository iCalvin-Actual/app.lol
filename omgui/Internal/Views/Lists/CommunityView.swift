//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 4/30/23.
//

import SwiftUI

struct CommunityView: View {
    
    let communityFetcher: StatusLogDataFetcher
    
    init(_ fetcher: StatusLogDataFetcher) {
        self.communityFetcher = fetcher
    }
    
    @State
    private var active: List = .community
    private var timeline: Timeline = .today
    
    var listLabel: String {
        switch active {
        case .community:            return "community"
        case .following(let name):  return "following from \(name.addressDisplayString)"
        case .me:                   return "my addresses"
        }
    }
    
    enum List {
        case community
        case following(AddressName)
        case me
    }
    
    enum Timeline {
        case today
        case week
        case month
        case all
    }
    
    var body: some View {
        StatusList(fetcher: communityFetcher, filters: .everyone)
            .environment(\.viewContext, .column)
    }
}

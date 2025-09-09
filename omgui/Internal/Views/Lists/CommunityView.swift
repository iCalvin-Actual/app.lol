//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 4/30/23.
//

import SwiftUI

struct CommunityView: View {
    enum Timeline {
        case today
        case week
        case month
        case all
    }
    private var timeline: Timeline = .today
    
    var listLabel: String {
        "community"
    }
    
    let communityFetcher: StatusLogDataFetcher
    
    init(communityFetcher: StatusLogDataFetcher) {
        self.communityFetcher = communityFetcher
    }
    
    var body: some View {
        ListView<StatusModel>(
            filters: .everyone,
            dataFetcher: communityFetcher
        )
        .task { [weak communityFetcher] in
            await communityFetcher?.updateIfNeeded()
        }
    }
}


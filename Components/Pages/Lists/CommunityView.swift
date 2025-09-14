//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 4/30/23.
//

import SwiftUI

struct CommunityView: View {
    
    let communityFetcher: StatusLogFetcher
    
    init(communityFetcher: StatusLogFetcher) {
        self.communityFetcher = communityFetcher
    }
    
    var body: some View {
        ListView<StatusModel>(
            filters: .everyone,
            dataFetcher: communityFetcher
        )
        .task { [weak communityFetcher] in
            let _ = await communityFetcher?.updateIfNeeded()
        }
    }
}


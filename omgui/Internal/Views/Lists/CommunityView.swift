//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 4/30/23.
//

import SwiftUI

struct CommunityView: View {
    @Environment(\.statusLogFetcher)
    var communityFetcher: StatusLogDataFetcher?
    @Environment(\.addressBook)
    var addressBook
    
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
    
    var body: some View {
        if let communityFetcher {
            ListView<StatusModel, EmptyView>(
                filters: .everyone,
                dataFetcher: communityFetcher
            )
            .task { [weak communityFetcher] in
                guard let communityFetcher else { return }
                communityFetcher.configure(addressBook: addressBook)
                await communityFetcher.updateIfNeeded()
            }
#if !os(tvOS)
            .toolbarRole(.editor)
#endif
        }
    }
}

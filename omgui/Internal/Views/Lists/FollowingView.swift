//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/13/23.
//

import Combine
import SwiftUI

struct FollowingView: View {
    @Environment(SceneModel.self)
    var scene
    
    @State
    var needsRefresh: Bool = false
    
    var body: some View {
        followingView
            .onAppear(perform: { needsRefresh = false })
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ThemedTextView(text: "following")
                }
            }
    }
    
    @ViewBuilder
    var followingView: some View {
        if scene.addressBook.signedIn {
            StatusList(
                fetcher: StatusLogDataFetcher(
                    addresses: scene.addressBook.following,
                    addressBook: scene.addressBook,
                    interface: scene.interface,
                    db: scene.database
                ),
                filters: [.fromOneOf(scene.addressBook.following)]
            )
        } else {
            signedOutView
        }
    }
    
    @ViewBuilder
    var signedOutView: some View {
        Text("Signed Out")
    }
}

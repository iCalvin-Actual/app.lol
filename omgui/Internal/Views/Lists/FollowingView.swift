//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/13/23.
//

import Combine
import SwiftUI

struct FollowingView: View {
    @Environment(\.addressBook)
    var addressBook
    
    @State
    var needsRefresh: Bool = false
    
    var body: some View {
        followingView
            .onAppear(perform: { needsRefresh = false })
    }
    
    @ViewBuilder
    var followingView: some View {
        if addressBook.signedIn {
            StatusList(
                addressBook.following,
                addressBook: addressBook
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

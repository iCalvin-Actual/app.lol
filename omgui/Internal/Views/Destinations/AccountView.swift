//
//  SwiftUIView.swift
//
//
//  Created by Calvin Chestnut on 5/2/23.
//

import SwiftUI

struct AccountView: View {
    @SceneStorage("app.lol.address")
    var actingAddress: AddressName = ""
    
    @Environment(\.colorScheme)
    var colorScheme
    
    @Environment(SceneModel.self)
    var sceneModel
    @Environment(AccountAuthDataFetcher.self)
    var authFetcher
    
    @State
    var searchAddress: String = ""
    @State
    var presentUpsell: Bool = false
    @State
    var forceUpdateState: Bool = false
    
    var availabilityText: String {
        "Enter an address to check availability"
    }
    
    var body: some View {
        ListsView(sceneModel: sceneModel)
    }
}

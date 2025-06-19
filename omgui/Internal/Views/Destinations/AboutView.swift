//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 9/2/24.
//

import SwiftUI


struct AboutView: View {
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass
    
    @State var presented: URL?
    
    var body: some View {
        RemoteHTMLContentView(activeAddress: sceneModel.addressBook.actingAddress.wrappedValue, startingURL: URL(string: "https://home.omg.lol/info/referred-by/app")!, activeURL: $presented, scrollEnabled: .constant(true))
            .ignoresSafeArea(.container, edges: (horizontalSizeClass == .regular && UIDevice.current.userInterfaceIdiom == .pad) ? [.bottom] : [])
            .sheet(item: $presented, content: { url in
                SafariView(url: url)
                    .ignoresSafeArea(.container, edges: (horizontalSizeClass == .regular && UIDevice.current.userInterfaceIdiom == .pad) ? [.bottom] : [])
            })
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ThemedTextView(text: "info & help")
                }
            }
    }
}

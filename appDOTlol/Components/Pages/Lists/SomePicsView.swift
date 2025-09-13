//
//  SomePicsView.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/13/25.
//

import SwiftUI

struct SomePicsView: View {
    let photoFetcher: PhotoFeedFetcher
    
    var body: some View {
        ListView(dataFetcher: photoFetcher)
    }
}

//
//  File 2.swift
//  
//
//  Created by Calvin Chestnut on 3/15/23.
//

import SwiftUI

struct GardenView: View {
    let fetcher: NowGardenFetcher
    
    var body: some View {
        ListView<NowListing>(dataFetcher: fetcher)
    }
}

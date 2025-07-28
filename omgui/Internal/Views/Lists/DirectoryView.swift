//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/12/23.
//

import Blackbird
import SwiftUI

struct DirectoryView: View {
    
    let fetcher: AddressDirectoryDataFetcher
    
    var body: some View {
        ListView<AddressModel>(
            filters: .everyone,
            dataFetcher: fetcher
        )
    }
}

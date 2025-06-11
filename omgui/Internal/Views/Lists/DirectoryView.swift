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
        ListView<AddressModel, EmptyView>(
            filters: .everyone,
            dataFetcher: fetcher
        )
    }
}

#Preview {
    let sceneModel = SceneModel.sample
    let accountAuthFetcher = AccountAuthDataFetcher(authKey: nil, client: .sample, interface: SampleData())
    DirectoryView(fetcher: .init(addressBook: sceneModel.addressBook, interface: sceneModel.interface, db: sceneModel.database))
        .environment(sceneModel)
        .environment(accountAuthFetcher)
}

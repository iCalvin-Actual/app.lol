//
//  ShareablePackets.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/11/25.
//

import Foundation

struct SharePacket: Identifiable, Hashable {
    
    var id: String { [name, content.absoluteString].joined() }
    
    let name: String
    let content: URL
}

struct CopyPacket: Identifiable {
    
    var id: String { [name, content].joined() }
    
    let name: String
    let content: String
}

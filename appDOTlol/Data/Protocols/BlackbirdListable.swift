//
//  BlackbirdListable.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/11/25.
//

import Blackbird
import Foundation


protocol BlackbirdListable: BlackbirdModel, Listable {
    static var sortingKey: BlackbirdColumnKeyPath { get }
    static var ownerKey: BlackbirdColumnKeyPath { get }
    static var dateKey: BlackbirdColumnKeyPath { get }
}
extension BlackbirdListable {
    static var fullTextSearchableColumns: [PartialKeyPath<Self> : BlackbirdModelFullTextSearchableColumn] { [
        ownerKey: .text,
        dateKey: .filterOnly
    ]}
    static var primaryKey: [PartialKeyPath<Self>] { [ownerKey] }
}

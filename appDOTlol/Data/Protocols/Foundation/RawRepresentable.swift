//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 8/2/24.
//

import Foundation


extension String: @retroactive RawRepresentable {
    public var rawValue: String { self }
    public init?(rawValue: String) {
        self = rawValue
    }
}

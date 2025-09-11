//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 8/2/24.
//

import SwiftUI

extension String: @retroactive Identifiable {
    public var id: String { rawValue }
}

extension PresentationDetent: @retroactive Identifiable {
    public var id: Int {
        self.hashValue
    }
}

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}

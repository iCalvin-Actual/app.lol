//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 8/2/24.
//

import Foundation

extension AddressModel {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(addressName)
    }
}

extension PasteModel {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(owner)
        hasher.combine(name)
        hasher.combine(content)
        hasher.combine(listed)
    }
}

extension PURLModel {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(owner)
        hasher.combine(name)
        hasher.combine(content)
        hasher.combine(listed)
    }
}

extension String {
    var staticHash: Int {
        self.unicodeScalars.reduce(0) { sum, scalar in
            sum + Int(scalar.value)
        }
    }
}

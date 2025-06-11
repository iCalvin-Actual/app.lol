//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import Punycode
import SwiftUI

struct AddressNameView: View {
    let name: AddressName
    let font: Font
    let suffix: String?
    
    init(_ name: AddressName, font: Font = .body, suffix: String? = nil) {
        self.name = name
        self.font = font
        self.suffix = suffix
    }
    
    var body: some View {
        ThemedTextView(text: name.addressDisplayString, font: font, suffix: suffix)
    }
}

extension AddressName {
    var punified: String {
        guard self.prefix(1) != "@" else { return self }
        if let upperIndex = self.range(of: "xn--")?.upperBound {
            return String(suffix(from: upperIndex)).punycodeDecoded ?? self
        }
        return self
    }
    
    var addressDisplayString: String {
        guard self.prefix(1) != "@" else { return self }
        
        return "@\(self.punified)"
    }
}

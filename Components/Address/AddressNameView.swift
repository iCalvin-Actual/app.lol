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

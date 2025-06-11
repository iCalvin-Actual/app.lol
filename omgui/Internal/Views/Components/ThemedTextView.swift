//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct ThemedTextView: View {
    let text: String
    let font: Font
    let design: Font.Design
    let suffix: String?
    
    init(text: String, font: Font = .title3, design: Font.Design = .serif, suffix: String? = nil) {
        self.text = text
        self.font = font
        self.design = design
        self.suffix = suffix
    }
    
    var body: some View {
        appropriateText
            .truncationMode(.middle)
            .font(font)
            .fontDesign(design)
            .foregroundStyle(.primary)
    }
    
    @ViewBuilder
    var appropriateText: some View {
        if let suffix {
            suffixedText(suffix: suffix)
        } else {
            soloText
        }
    }
    
    @ViewBuilder
    var soloText: Text {
        Text(text)
            .bold()
    }
    
    @ViewBuilder
    func suffixedText(suffix: String) -> some View {
        soloText
        +
        Text(suffix)
    }
}

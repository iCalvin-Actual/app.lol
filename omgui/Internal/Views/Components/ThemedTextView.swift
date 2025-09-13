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
        Text(makeAttributedText(text: text, suffix: suffix))
            .truncationMode(.tail)
            .font(font)
            .fontDesign(design)
            .foregroundStyle(.primary)
    }
    
    private func makeAttributedText(text: String, suffix: String?) -> AttributedString {
        var result = AttributedString(text)
        // Apply bold to the base text only
        result.inlinePresentationIntent = [.stronglyEmphasized]

        if let suffix, !suffix.isEmpty {
            var tail = AttributedString(suffix)
            // Ensure suffix is not bold
            tail.inlinePresentationIntent = []
            result.append(tail)
        }

        return result
    }
}

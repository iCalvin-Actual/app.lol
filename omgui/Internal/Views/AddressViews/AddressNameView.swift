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

private extension Character {
    // Variation Selector-16 (U+FE0F) is used to request emoji presentation.
    var containsEmojiVS16: Bool {
        unicodeScalars.contains { $0.value == 0xFE0F }
    }
    
    // Zero Width Joiner (U+200D) used in complex emoji sequences.
    var containsZWJ: Bool {
        unicodeScalars.contains { $0.value == 0x200D }
    }
    
    // True if any scalar is marked as emoji.
    var hasEmojiScalar: Bool {
        unicodeScalars.contains { $0.properties.isEmoji }
    }
    
    // Disallow whitespace/newlines in emoji-only checks.
    var isWhitespaceOrNewline: Bool {
        unicodeScalars.contains { CharacterSet.whitespacesAndNewlines.contains($0) }
    }
    
    // Treat any alphanumeric cluster as non-emoji for our purposes.
    var isAlphanumeric: Bool {
        // If every scalar in this Character is an alphanumeric, consider it alphanumeric.
        unicodeScalars.allSatisfy { CharacterSet.alphanumerics.contains($0) }
    }
    
    // True if this character will be presented as emoji in typical rendering.
    var isPresentedAsEmoji: Bool {
        // Exclude alphanumerics outright (prevents digits/letters like "1337" from being treated as emoji)
        if isAlphanumeric { return false }
        
        // If any scalar is explicitly emoji presentation.
        if unicodeScalars.contains(where: { $0.properties.isEmojiPresentation }) {
            return true
        }
        // Many characters require VS16 to present as emoji.
        if hasEmojiScalar && containsEmojiVS16 {
            return true
        }
        // ZWJ sequences that include emoji scalars are emoji.
        if hasEmojiScalar && containsZWJ {
            return true
        }
        // Flags (regional indicator pairs) have scalars marked as emoji.
        return hasEmojiScalar
    }
}

private extension String {
    // True if the string is composed only of emoji grapheme clusters (no letters/digits/whitespace).
    var isEmojiOnly: Bool {
        guard !isEmpty else { return false }
        for ch in self {
            if ch.isWhitespaceOrNewline {
                return false
            }
            if !ch.isPresentedAsEmoji {
                return false
            }
        }
        return true
    }
}

extension AddressName {
    var puny: String {
        // Only punycode encode when the address is entirely emoji
        if self.isEmojiOnly {
            return "xn--\(String(punycodeEncoded ?? self))"
        } else {
            return self
        }
    }
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

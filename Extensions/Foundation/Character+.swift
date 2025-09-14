//
//  Character+.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/14/25.
//

import Foundation


extension Character {
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


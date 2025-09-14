//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 8/3/24.
//

import Foundation
import SwiftUI

typealias APICredential = String
typealias AddressName = String

extension AddressName {
    var addressDisplayString: String {
        guard self.prefix(1) != "@" else { return self }
        
        return "@\(self.punified)"
    }
    
    var addressIconURL: URL? {
        URL(string: "https://profiles.cache.lol/\(self)/picture")
    }
    
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
}

extension String {
    
    var boolValue: Bool {
        switch self.lowercased() {
        case "true", "t", "yes", "y":
            return true
        case "false", "f", "no", "n", "":
            return false
        default:
            if let int = Int(self) {
                return int != 0
            }
            return false
        }
    }
    
    /*
     Used to massage text input to force a valid URL.
     Assume https://\(self).com
     But if the field provides a scheme/domain it will be used
     */
    var urlString: String {
        var newText = self
        if !newText.contains("://") {
            newText = "https://" + newText
        }
        if !newText.contains(".") {
            newText = newText + ".com"
        }
        return newText
    }
    
    func clearWhitespace() -> String {
        filter { !$0.isWhitespace }
    }
    
    /// Replaces <i>, <b>, and span tags with markdown equivalents where possible.
    func replacingHTMLTagsWithMarkdown() -> String {
        var result = self

        // Replace <i> and <em> tags with *...*
        let italicPatterns = [
            ("<i>([\\s\\S]*?)</i>", "*$1*"),
            ("<em>([\\s\\S]*?)</em>", "*$1*")
        ]
        for (pattern, replacement) in italicPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                result = regex.stringByReplacingMatches(in: result, options: [], range: NSRange(result.startIndex..., in: result), withTemplate: replacement)
            }
        }

        // Replace <b> and <strong> tags with **...**
        let boldPatterns = [
            ("<b>([\\s\\S]*?)</b>", "**$1**"),
            ("<strong>([\\s\\S]*?)</strong>", "**$1**")
        ]
        for (pattern, replacement) in boldPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                result = regex.stringByReplacingMatches(in: result, options: [], range: NSRange(result.startIndex..., in: result), withTemplate: replacement)
            }
        }

        // Replace <span style="font-style: italic">...</span> and <span style='font-style:italic'>...</span> to *...*
        let spanItalicPattern = "<span[^>]*style=[\"']?[^>]*font-style:\\s*italic;?[^>]*[\"']?[^>]*>([\\s\\S]*?)</span>"
        if let regex = try? NSRegularExpression(pattern: spanItalicPattern, options: .caseInsensitive) {
            result = regex.stringByReplacingMatches(in: result, options: [], range: NSRange(result.startIndex..., in: result), withTemplate: "*$1*")
        }
        // Replace <span style="font-weight: bold">...</span> and similar to **...**
        let spanBoldPattern = "<span[^>]*style=[\"']?[^>]*font-weight:\\s*bold;?[^>]*[\"']?[^>]*>([\\s\\S]*?)</span>"
        if let regex = try? NSRegularExpression(pattern: spanBoldPattern, options: .caseInsensitive) {
            result = regex.stringByReplacingMatches(in: result, options: [], range: NSRange(result.startIndex..., in: result), withTemplate: "**$1**")
        }
        return result
    }
    
    /// Replaces HTML <a href="...">text</a> tags with Markdown [text](url) formatting.
    func replacingHTMLLinksWithMarkdown() -> String {
        let pattern = #"<a\s+href=[\"']([^\"'>]+)[\"'][^>]*>([\s\S]*?)<\/a>"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return self
        }
        let range = NSRange(self.startIndex..<self.endIndex, in: self)
        var result = self
        let matches = regex.matches(in: self, options: [], range: range).reversed()
        for match in matches {
            guard match.numberOfRanges == 3,
                  let urlRange = Range(match.range(at: 1), in: self),
                  let textRange = Range(match.range(at: 2), in: self) else { continue }
            let url = self[urlRange]
            let text = self[textRange]
            let markdown = "[\(text)](\(url))"
            if let fullRange = Range(match.range, in: result) {
                result.replaceSubrange(fullRange, with: markdown)
            }
        }
        return result
            .replacingHTMLImagesWithMarkdown()
            .replacingHTMLTagsWithMarkdown()
            .replacingHTMLTagsWithMarkdown()
            .replacingOccurrences(of: "<p>", with: "")
            .replacingOccurrences(of: "</p>", with: "\r\n")
    }
    
    /// Replaces HTML <img src=... alt=...> tags with Markdown ![alt](src) formatting.
    func replacingHTMLImagesWithMarkdown() -> String {
        let pattern = #"<img[^>]*src=[\"']([^\"'>]+)[\"'][^>]*alt=[\"']([^\"'>]*)[\"'][^>]*>|<img[^>]*alt=[\"']([^\"'>]*)[\"'][^>]*src=[\"']([^\"'>]+)[\"'][^>]*>|<img[^>]*src=[\"']([^\"'>]+)[\"'][^>]*>"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return self
        }
        let range = NSRange(self.startIndex..<self.endIndex, in: self)
        var result = self
        let matches = regex.matches(in: self, options: [], range: range).reversed()
        for match in matches {
            var src: Substring = ""
            var alt: Substring = ""
            if match.numberOfRanges >= 3 {
                // <img ... src=... alt=...>
                if let srcRange = Range(match.range(at: 1), in: self),
                   let altRange = Range(match.range(at: 2), in: self) {
                    src = self[srcRange]
                    alt = self[altRange]
                }
                // <img ... alt=... src=...>
                else if let altRange = Range(match.range(at: 3), in: self),
                        let srcRange = Range(match.range(at: 4), in: self) {
                    src = self[srcRange]
                    alt = self[altRange]
                }
                // <img ... src=...>
                else if let srcRange = Range(match.range(at: 5), in: self) {
                    src = self[srcRange]
                }
            }
            let markdown = "![\(alt)](\(src))"
            if let fullRange = Range(match.range, in: result) {
                result.replaceSubrange(fullRange, with: markdown)
            }
        }
        return result
    }
}

extension String {
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

extension Optional<String> {
    var boolValue: Bool {
        self?.boolValue ?? false
    }
}

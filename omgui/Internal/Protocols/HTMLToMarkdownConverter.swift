//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 8/3/24.
//

import Foundation

enum HTMLToMarkdownConverter {
    
    /// Converts the HTML-tags in the given string to their corresponding markdown tags.
    ///
    /// - SeeAlso: See type `HTMLToMarkdownConverter.Tags` for a list of supported HTML-tags.
    static func convert(_ htmlAsString: String) -> String {
        // Convert "basic" HTML-tags that don't use an attribute.
        let markdownAsString = Tags.allCases.reduce(htmlAsString) { result, textFormattingTag in
            result
                .replacingOccurrences(of: textFormattingTag.openingHtmlTag, with: textFormattingTag.openingTag)
                .replacingOccurrences(of: textFormattingTag.openAndCloseHtmlTag, with: textFormattingTag.openingTag)
                .replacingOccurrences(of: textFormattingTag.closingHtmlTag, with: textFormattingTag.closingTag)
        }
        
        // Hyperlinks use an attribute and therefore need to be handled differently.
        return convertHtmlLinksToMarkdown(markdownAsString)
    }
    
    // MARK: - Private methods
    
    /// Converts hyperlinks in HTML-format to their corresponding markdown representations.
    ///
    /// - Note: Currently we only support a basic HTML syntax without any attributed other than `href`.
    ///         E.g. `<a href="URL">TEXT</a>` will be converted to `[TEXT](URL)`
    ///
    /// - Parameter htmlAsString: The string containing hyperlinks in HTML-format.
    ///
    /// - Returns: A string with hyperlinks converted to their corresponding markdown representations.
    private static func convertHtmlLinksToMarkdown(_ htmlAsString: String) -> String {
        htmlAsString.replacingOccurrences(of: "<a href=\"(.+)\">(.+)</a>",
                                          with: "[$2]($1)",
                                          options: .regularExpression,
                                          range: nil)
    }
}

extension HTMLToMarkdownConverter {
    
    /// The supported tags inside a string we can format.
    enum Tags: String, CaseIterable {
        case br
        case h1
        case h2
        case h3
        case h4
        case h5
        case h6
        case hr
        case ul
        case li
        case strong
        case em
        case s
        case code
        case p
        
        // Hyperlinks need to be handled differently, as they not only have simple opening and closing tag, but also use the attribute `href`.
        // See private method `Text.convertHtmlLinksToMarkdown(:)` for further details.
        // case a
        
        var openingHtmlTag: String {
            "<\(rawValue)>"
        }
        
        var openAndCloseHtmlTag: String {
            "<\(rawValue) />"
        }
        
        var closingHtmlTag: String {
            "</\(rawValue)>"
        }
        
        var openingTag: String {
            switch self {
            default:
                return markdownTag
            }
        }
        
        var closingTag: String {
            switch self {
            case .ul:
                return "\r\n"
            case .li:
                return "\r\n"
            case .p, .h1, .h2, .h3, .h4, .h5, .h6:
                return "\r\n"
            default:
                return markdownTag
            }
        }
        
        var markdownTag: String {
            switch self {
            case .br:
                return "\r\n"
            case .hr:
                return "---\n\n"
            case .li:
                return "- "
            case .ul:
                return ""
            case .h1:
                return "# "
            case .h2:
                return "## "
            case .h3:
                return "### "
            case .h4:
                return "#### "
            case .h5:
                return "##### "
            case .h6:
                return "###### "
            case .p:
                return ""
            case .strong:
                return "**"
                
            case .em:
                return "*"
                
            case .s:
                return "~~"
                
            case .code:
                return "`"
            }
        }
    }
}

//
//  File.swift
//
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI
import WebKit
import MarkdownUI

struct AddressSummaryView: View {
    @Environment(\.showAddressPage)
    var showPage
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass
    @Environment(\.destinationConstructor)
    var destinationConstructor
    @Environment(\.apiInterface)
    var apiInterface
    @Environment(\.blackbird)
    var database
    @Environment(\.addressSummaryFetcher)
    var summaryFetchers
    
    @State
    var addressSummaryFetcher: AddressSummaryFetcher = .init(name: "", addressBook: .init())
    
    @State var presentBio: Bool = false
    @State var expandBio: PresentationDetent = .medium
    
    @State var addressPage: AddressContent
    
    let address: AddressName
    let addressBook: AddressBook
    
    private var allPages: [AddressContent] {
        [
            .profile,
            .now,
            .statuslog,
            .pastebin,
            .purl
        ]
    }
    
    init(_ addressName: AddressName, addressBook: AddressBook, page: AddressContent = .profile) {
        self.address = addressName
        self.addressBook = addressBook
        self.addressPage = page
    }
    
    var body: some View {
        sizeAppropriateBody
            .toolbar {
                ToolbarItem(placement: .safePrincipal) {
                    AddressPrincipalView(addressSummaryFetcher: addressSummaryFetcher, addressPage: $addressPage)
                }
            }
            .environment(\.viewContext, .profile)
            .task { @MainActor in
                let newFetcher = summaryFetchers(address) ?? .init(name: address, addressBook: addressBook)
                self.addressSummaryFetcher = newFetcher
                await newFetcher.updateIfNeeded()
            }
    }
    
    @ViewBuilder
    var sizeAppropriateBody: some View {
        if horizontalSizeClass == .regular {
            destination(addressPage)
        } else {
            destination(addressPage)
        }
    }
    
    @Environment(\.colorSchemeContrast) var contrast
    @ViewBuilder
    func destination(_ item: AddressContent? = nil) -> some View {
        let workingItem = item ?? .profile
        destinationConstructor?.destination(workingItem.destination(addressSummaryFetcher.addressName), contrast: contrast)
            .id(addressSummaryFetcher.addressName)
            .background(Color.clear)
            .navigationSplitViewColumnWidth(min: 250, ideal: 600)
    }
    
    func fetcherForContent(_ content: AddressContent) -> Request {
        switch content {
        case .pic:
            return addressSummaryFetcher.pasteFetcher
        case .now:
            return addressSummaryFetcher.nowFetcher
        case .pastebin:
            return addressSummaryFetcher.pasteFetcher
        case .purl:
            return addressSummaryFetcher.purlFetcher
        case .profile:
            return addressSummaryFetcher.profileFetcher
        case .statuslog:
            return addressSummaryFetcher.statusFetcher
        }
    }
}

struct AddressBioView: View {
    @Environment(\.colorSchemeContrast) var contrast
    @Environment(\.pinAddress) var pin
    @Environment(\.unpinAddress) var unpin
    @Environment(\.blockAddress) var block
    @Environment(\.unblockAddress) var unblock
    @Environment(\.followAddress) var follow
    @Environment(\.unfollowAddress) var unfollow
    @Environment(\.presentListable) var present
    @Environment(\.viewContext) var viewContext
    
    let fetcher: AddressSummaryFetcher
    let page: Binding<AddressContent>
    
    var address: AddressName { fetcher.addressName }
    
    let menuBuilder = ContextMenuBuilder<AddressModel>()
    
    func intToDisplay(_ page: AddressContent) -> String? {
        switch page {
        case .statuslog:
            guard fetcher.statusFetcher.loaded != nil else { return nil }
            return "\(fetcher.statusFetcher.results.count)"
        default:
            return ""
        }
    }
    
    func disable(_ page: AddressContent) -> Bool {
        intToDisplay(page) == nil
    }
    
    var containerCorner: CGFloat {
        16
    }
    
    var bio: String? {
        let safeBio = fetcher.bioFetcher.bio?.bio?.replacingHTMLLinksWithMarkdown()
        if safeBio?.isEmpty ?? false { return nil }
        return safeBio
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top, spacing: 4) {
                AddressIconView(
                    address: address,
                    size: 88,
                    showMenu: false,
                    contentShape:  RoundedRectangle(cornerRadius: containerCorner)
                )
                VStack {
                    HStack(alignment: .firstTextBaseline) {
                        AddressNameView(address, font: .body)
                        
                        Spacer()
                        
                        Menu {
                            menuBuilder.contextMenu(
                                for: .init(name: address),
                                addressBook: fetcher.addressBook,
                                menuFetchers: (
                                    navigate: present ?? { _ in },
                                    follow: follow,
                                    block: block,
                                    pin: pin,
                                    unFollow: unfollow,
                                    unBlock: unblock,
                                    unPin: unpin
                                )
                            )
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                        .tint(.primary)
                    }
                    .foregroundStyle(.secondary)
                    Spacer()
                    HStack(spacing: 4) {
                        button(.profile, grow: true)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        button(.now, span: false, grow: true)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .foregroundStyle(Material.regular)
                    .labelIconToTitleSpacing(4)
                }
//                .frame(idealHeight: 60, maxHeight: 66)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 4) {
                button(.pastebin)
                    .disabled(!fetcher.pasteFetcher.hasContent)
                    .foregroundStyle(fetcher.pasteFetcher.hasContent ? Material.regular : Material.ultraThin)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                button(.statuslog)
                    .disabled(!fetcher.statusFetcher.hasContent)
                    .foregroundStyle(fetcher.statusFetcher.hasContent ? Material.regular : Material.ultraThin)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                button(.pic)
                    .disabled(!fetcher.picFetcher.hasContent)
                    .foregroundStyle(fetcher.picFetcher.hasContent ? Material.regular : Material.ultraThin)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                button(.purl)
                    .disabled(!fetcher.purlFetcher.hasContent)
                    .foregroundStyle(fetcher.purlFetcher.hasContent ? Material.regular : Material.ultraThin)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .labelStyle(.iconOnly)
        
            if let bio = fetcher.bioFetcher.bio?.bio?.replacingHTMLLinksWithMarkdown(), !bio.isEmpty
            {
                Divider()
                ScrollView {
                    Markdown(bio)
                        .multilineTextAlignment(.leading)
                        .tint(.lolAccent)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Material.ultraThin)
                .clipShape(UnevenRoundedRectangle(
                    topLeadingRadius: 8,
                    bottomLeadingRadius: containerCorner,
                    bottomTrailingRadius: containerCorner,
                    topTrailingRadius: 8,
                    style: .circular
                ))
                .frame(height: 200)
            }
        }
        .padding(16)
        .frame(maxWidth: 500, alignment: .top)
        .presentationCompactAdaptation(.popover)
        .task {
            await fetcher.updateIfNeeded(forceReload:
            true)
        }
    }
    
    @ViewBuilder
    func button(_ addressContent: AddressContent, text: any StringProtocol = "", span: Bool = true, grow: Bool = false) -> some View {
        Button {
            page.wrappedValue = addressContent
        } label: {
            Label(addressContent.displayString, systemImage: addressContent.icon)
                .bold()
                .frame(
                    maxWidth: span ? .infinity : nil,
                    maxHeight: grow ? .infinity : nil,
                    alignment: addressContent == .profile ? .leading : .center
                )
        }
        .padding(2)
        .padding(.horizontal, 4)
        .font(.callout)
        .fontDesign(.rounded)
        .frame(minHeight: 44)
        .background(addressContent.color)
        .colorScheme(.light)
    }
}

struct AddressPrincipalView: View {
    @Environment(\.showAddressPage) var showPage
    @Environment(\.addressBook) var addressBook
    @Environment(\.dismiss) var dismiss
    
    let addressSummaryFetcher: AddressSummaryFetcher
    
    @Binding var addressPage: AddressContent
    
    @State var presentBio: Bool = false
    
    var address: AddressName { addressSummaryFetcher.addressName }
    
    var body: some View {
        Button {
            withAnimation {
                presentBio.toggle()
            }
        } label: {
            AddressBioButton(address: address, page: $addressPage, theme: addressSummaryFetcher.profileFetcher.theme)
        }
        .buttonStyle(.borderless)
        .popover(isPresented: $presentBio) {
            AddressBioView(
                fetcher: addressSummaryFetcher,
                page: .init(
                    get: { addressPage },
                    set: {
                        presentBio = false
                        addressPage = $0
                    }
                )
            )
            .padding(2)
            .environment(\.showAddressPage, showPage)
            .environment(\.visibleAddressPage, addressPage)
            .environment(\.addressBook, addressBook)
        }
    }
}

struct AddressBioButton: View {
    let address: AddressName
    
    @Binding
    var page: AddressContent
    
    let theme: ThemeModel?
    
    var body: some View {
        HStack(spacing: 2) {
            #if !os(macOS) && !os(visionOS)
            AddressIconView(address: address, size: 30, showMenu: false, contentShape: Circle())
                .frame(width: 30, height: 30)
            #endif
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                AddressNameView(address, font: .headline)
                    .bold()
                    .foregroundStyle(theme?.foregroundColor ?? .primary)
                    .lineLimit(2)
                if page == .now {
                    ThemedTextView(text: page.displayString, font: .headline)
                }
            }
#if os(macOS)
            .padding(.horizontal)
#endif
        }
    }
}

extension AttributedString {
    init(styledMarkdown markdownString: String) throws {
        var output = try AttributedString(
            markdown: markdownString,
            options: .init(
                allowsExtendedAttributes: true,
                interpretedSyntax: .full,
                failurePolicy: .returnPartiallyParsedIfPossible
            ),
            baseURL: nil
        )

        for (intentBlock, intentRange) in output.runs[AttributeScopes.FoundationAttributes.PresentationIntentAttribute.self].reversed() {
            guard let intentBlock = intentBlock else { continue }
            for intent in intentBlock.components {
                switch intent.kind {
                case .header(level: let level):
                    switch level {
                    case 1:
                        output[intentRange].font = .system(.title).bold()
                    case 2:
                        output[intentRange].font = .system(.title2).bold()
                    case 3:
                        output[intentRange].font = .system(.title3).bold()
                    default:
                        break
                    }
                default:
                    break
                }
            }
            
            if intentRange.lowerBound != output.startIndex {
                output.characters.insert(contentsOf: "\n", at: intentRange.lowerBound)
            }
        }

        self = output
    }
}

extension String {
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


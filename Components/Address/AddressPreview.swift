//
//  AddressPreview.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/14/25.
//

import MarkdownUI
import SwiftUI


struct AddressPreview: View {
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
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Menu {
                            menuBuilder.contextMenu(
                                for: .init(name: address),
                                addressBook: fetcher.addressBook,
                                appActions: (
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
                        .buttonStyle(.borderless)
#if os(visionOS)
                        .tint(.clear)
#else
                        .foregroundStyle(.primary)
#endif
                    }
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
                .foregroundStyle(.primary)
        }
        .buttonStyle(.borderless)
        .padding(2)
        .padding(.horizontal, 4)
        .font(.callout)
        .fontDesign(.rounded)
        .frame(minHeight: 44)
        .background(addressContent.color)
        .colorScheme(.dark)
    }
}

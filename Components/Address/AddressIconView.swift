
import SwiftUI


struct AddressIconView<S: Shape>: View {
    @Environment(\.addressBook)
        var addressBook
    
    @Environment(\.pinAddress)
        var pin
    @Environment(\.blockAddress)
        var block
    @Environment(\.followAddress)
        var follow
    
    @Environment(\.unpinAddress)
        var unpin
    @Environment(\.unblockAddress)
        var unblock
    @Environment(\.unfollowAddress)
        var unfollow
    
    @Environment(\.presentListable)
        var present
    
    @Environment(\.avatarCache)
        var imageCache
    @Environment(\.addressSummaryFetcher)
        var summaryCache
    
    private let menuBuilder = ContextMenuBuilder<AddressModel>()
    
    var summaryFetcher: AddressSummaryFetcher? {
        summaryCache(address)
    }
    @State
        var iconFetcher: AddressIconFetcher = .init(address: "")
    
    @State
    var showPopover: Bool = false
    
    let address: AddressName
    
    let size: CGFloat
    let showMenu: Bool
    let contentShape: S
    
    init(
        address: AddressName,
        size: CGFloat = 40,
        showMenu: Bool = true,
        contentShape: S = RoundedRectangle(cornerRadius: 8)
    ) {
        self.address = address
        self.size = size
        self.showMenu = showMenu
        self.contentShape = contentShape
    }
    
    var body: some View {
        Group {
            if showMenu { menu }
            else { iconView }
        }
        .task { await configureFetcher() }
    }
    
    @ViewBuilder
    var iconView: some View {
        if let result = iconFetcher.result?.data, !result.isEmpty {
            #if canImport(UIKit)
            if let image = UIImage(data: result) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(contentShape)
            } else {
                Color.lolRandom(address)
                    .frame(width: size, height: size)
                    .clipShape(contentShape)
            }
            #elseif canImport(AppKit)
            if let image = NSImage(data: result) {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(contentShape)
            } else {
                Color.lolRandom(address)
                    .frame(width: size, height: size)
                    .clipShape(contentShape)
            }
            #endif
        } else {
            AsyncImage(url: address.addressIconURL) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(contentShape)
            } placeholder: {
                Color.lolRandom(address)
                    .frame(width: size, height: size)
                    .clipShape(contentShape)
            }
        }
    }
    
    @ViewBuilder
    private var menu: some View {
        Button {
            withAnimation {
                showPopover.toggle()
            }
        } label: {
            iconView
        }
        .popover(isPresented: $showPopover) {
            if let summaryFetcher {
                AddressPreview(
                    fetcher: summaryFetcher,
                    page: .init(
                        get: { .profile },
                        set: {
                            showPopover = false
                            present?(.address(address, page: $0))
                        }
                    )
                )
                .padding(2)
            }
        }
    }
    
    private func configureFetcher() async {
        if address != iconFetcher.address {
            if let cachedFetcher = imageCache.object(forKey: NSString(string: address)) {
                iconFetcher = cachedFetcher
            } else {
                let newFetcher = AddressIconFetcher(address: address)
                iconFetcher = newFetcher
                imageCache.setObject(newFetcher, forKey: NSString(string: address))
            }
            await iconFetcher.updateIfNeeded()
        }
    }
}


import SwiftUI


struct AddressIconView<S: Shape>: View {
    @Environment(\.addressBook) var addressBook
    
    @Environment(\.pinAddress) var pin
    @Environment(\.unpinAddress) var unpin
    @Environment(\.blockAddress) var block
    @Environment(\.unblockAddress) var unblock
    @Environment(\.followAddress) var follow
    @Environment(\.unfollowAddress) var unfollow
    @Environment(\.presentListable) var present
    
    @Environment(\.imageCache) var imageCache
    @Environment(\.addressSummaryFetcher) var summaryCache
    
    let address: AddressName
    let size: CGFloat
    
    let showMenu: Bool
    let contentShape: S
    
    let menuBuilder = ContextMenuBuilder<AddressModel>()
    
    var summaryFetcher: AddressSummaryFetcher? {
        summaryCache(address)
    }
    @State var iconFetcher: AddressIconFetcher?
    
    @State
    var showPopover: Bool = false
    
    init(
        address: AddressName,
        size: CGFloat = 40.0,
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
            if showMenu {
                menu
            } else {
                iconView
            }
        }
        .task {
            if let cachedFetcher = imageCache.object(forKey: NSString(string: address)) {
                iconFetcher = cachedFetcher
            } else {
                let newFetcher = AddressIconFetcher(address: address)
                iconFetcher = newFetcher
                imageCache.setObject(newFetcher, forKey: NSString(string: address))
            }
            guard let iconFetcher else { return }
            await iconFetcher.updateIfNeeded()
        }
    }
    
    @ViewBuilder
    var menu: some View {
        Button {
            withAnimation {
                showPopover.toggle()
            }
        } label: {
            iconView
        }
        .popover(isPresented: $showPopover) {
            if let summaryFetcher {
                AddressBioView(
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
    
    @ViewBuilder
    var iconView: some View {
        if let result = iconFetcher?.result?.data, !result.isEmpty {
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
}

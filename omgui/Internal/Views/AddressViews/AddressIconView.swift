
import SwiftUI


struct AddressIconView<S: Shape>: View {
    
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
    let addressBook: AddressBook
    let size: CGFloat
    
    let showMenu: Bool
    let contentShape: S
    
    let menuBuilder = ContextMenuBuilder<AddressModel>()
    
    @StateObject var newSummaryFetcher: AddressSummaryDataFetcher
    
    var summaryFetcher: AddressSummaryDataFetcher {
        summaryCache(address) ?? newSummaryFetcher
    }
    var iconFetcher: AddressIconDataFetcher {
        imageCache.object(forKey: NSString(string: address)) ?? summaryFetcher.iconFetcher
    }
    
    @State
    var showPopover: Bool = false
    
    init(
        address: AddressName,
        addressBook: AddressBook,
        size: CGFloat = 40.0,
        showMenu: Bool = true,
        contentShape: S = RoundedRectangle(cornerRadius: 8)
    ) {
        self.address = address
        self.addressBook = addressBook
        self.size = size
        self.showMenu = showMenu
        self.contentShape = contentShape
        self._newSummaryFetcher = .init(wrappedValue: .init(name: address, addressBook: addressBook, interface: APIDataInterface()))
    }
    
    var body: some View {
        if showMenu {
            menu
        } else {
            iconView
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
            .task {
                await summaryFetcher.updateIfNeeded()
                if imageCache.object(forKey: NSString(string: address)) == nil {
                    imageCache.setObject(iconFetcher, forKey: NSString(string: address))
                }
            }
        }
    }
}


import SwiftUI


struct AddressIconView<S: Shape>: View {
    @Environment(\.addressBook)
    var addressBook
    
    @Environment(\.addressFollowingFetcher) var following
    @Environment(\.addressBlockListFetcher) var blocked
    @Environment(\.localBlocklist) var localBlocked
    @Environment(\.pinnedFetcher) var pinned
    
    let address: AddressName
    let size: CGFloat
    
    let showMenu: Bool
    let contentShape: S
    
    let menuBuilder = ContextMenuBuilder<AddressModel>()
    
    init(
        address: AddressName,
        size: CGFloat = 42.0,
        showMenu: Bool = true,
        contentShape: S = RoundedRectangle(cornerRadius: 12)
    ) {
        self.address = address
        self.size = size
        self.showMenu = showMenu
        self.contentShape = contentShape
    }
    
    var body: some View {
        #if os(macOS)
        iconView
        #else
        if showMenu {
            menu
        } else {
            iconView
        }
        #endif
    }
    
    @ViewBuilder
    var menu: some View {
        Menu {
            menuBuilder.contextMenu(
                for: .init(name: address),
                addressBook: addressBook,
                menuFetchers: (
                    following,
                    blocked,
                    localBlocked,
                    pinned
                )
            )
        } label: {
            iconView
        }
    }
    
    @ViewBuilder
    var iconView: some View {
        AsyncImage(url: address.addressIconURL) { image in
            image.resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .clipShape(contentShape)
        } placeholder: {
            Color.lolRandom(address)
        }
        .frame(width: size, height: size)
        .clipShape(contentShape)
    }
}

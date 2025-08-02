
import SwiftUI


struct AddressIconView<S: Shape>: View {
    
    @Environment(\.pinAddress) var pin
    @Environment(\.unpinAddress) var unpin
    @Environment(\.blockAddress) var block
    @Environment(\.unblockAddress) var unblock
    @Environment(\.followAddress) var follow
    @Environment(\.unfollowAddress) var unfollow
    
    let address: AddressName
    let addressBook: AddressBook
    let size: CGFloat
    
    let showMenu: Bool
    let contentShape: S
    
    let menuBuilder = ContextMenuBuilder<AddressModel>()
    
    init(
        address: AddressName,
        addressBook: AddressBook,
        size: CGFloat = 40.0,
        showMenu: Bool = true,
        contentShape: S = RoundedRectangle(cornerRadius: 12)
    ) {
        self.address = address
        self.addressBook = addressBook
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
                    follow: follow,
                    block: block,
                    pin: pin,
                    unFollow: unfollow,
                    unBlock: unblock,
                    unPin: unpin
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

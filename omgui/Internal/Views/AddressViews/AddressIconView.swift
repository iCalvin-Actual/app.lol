
import SwiftUI


struct AddressIconView<S: Shape>: View {
    @Environment(\.addressBook)
    var addressBook
    
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
        if let addressBook {
            Menu {
                menuBuilder.contextMenu(for: .init(name: address), addressBook: addressBook)
            } label: {
                iconView
            }
        }
    }
    
    @ViewBuilder
    var iconView: some View {
        let data = addressBook?.appropriateFetcher(for: address).iconFetcher.result?.data
        let fallback = AsyncImage(url: address.addressIconURL) { image in
            image.resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .clipShape(contentShape)
        } placeholder: {
            Color.lolRandom(address)
        }
        .frame(width: size, height: size)
        .clipShape(contentShape)
        
        #if canImport(UIKit)
        if let data = data, let dataImage = UIImage(data: data) {
            Image(uiImage: dataImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .clipShape(contentShape)
        }
        else { fallback }
        #else
        if let data = data, let dataImage = NSImage(data: data) {
            Image(nsImage: dataImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .clipShape(contentShape)
        }
        else {
            fallback
        }
        #endif
    }
}

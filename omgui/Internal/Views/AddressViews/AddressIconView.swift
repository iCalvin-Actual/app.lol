
import SwiftUI


struct AddressIconView: View {
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    
    let address: AddressName
    let size: CGFloat
    
    let showMenu: Bool
    
    let menuBuilder = ContextMenuBuilder<AddressModel>()
    
    init(address: AddressName, size: CGFloat = 42.0, showMenu: Bool = true) {
        self.address = address
        self.size = size
        self.showMenu = showMenu
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
        Menu {
            menuBuilder.contextMenu(for: .init(name: address), sceneModel: sceneModel)
        } label: {
            iconView
        }
    }
    
    @ViewBuilder
    var iconView: some View {
        if let data = sceneModel.appropriateFetcher(for: address).iconFetcher.result?.data, let dataImage = UIImage(data: data) {
            Image(uiImage: dataImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            AsyncImage(url: address.addressIconURL) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.lolRandom(address)
            }
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

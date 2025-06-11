

import SwiftUI

struct MyPastesView: View {
    
    @SceneStorage("app.lol.addresses.mine.filter")
    var filter: FilterOption = .none
    @SceneStorage("app.lol.address")
    var actingAddress: AddressName = ""
    
    let addressFetcher: AddressPasteBinDataFetcher
    
    let singleAddressMode: Bool
    
    init(
        singleAddress: Bool,
        injectedScene: SceneModel
    ) {
        singleAddressMode = singleAddress
        addressFetcher = .init(name: injectedScene.addressBook.actingAddress.wrappedValue, credential: injectedScene.addressBook.apiKey, addressBook: injectedScene.addressBook, interface: injectedScene.interface, db: injectedScene.database)
    }
    
    var body: some View {
        ListView<PasteModel, EmptyView>(dataFetcher: addressFetcher)
            .safeAreaInset(edge: .bottom, content: {
                HStack {
                    if !singleAddressMode {
                        Button(action: toggleFilter) {
                            ZStack(alignment: .bottom) {
                                Image(systemName: "person.3")
                                    .opacity(filter != .mine ? 1 : 0)
                                Image(systemName: "person.fill")
                                    .scaleEffect(filter == .mine ? 1 : 1.1)
                                    .padding(.bottom, 2)
                            }
                            .bold()
                            .foregroundStyle(Color.white)
                            .frame(width: 44, height: 44)
                            .padding(8)
                            .background(Color.lolAccent)
                            .mask(Circle())
                        }
                    }
                    Spacer()
                    NavigationLink(value: NavigationDestination.paste(actingAddress, id: "")) {
                        Image(systemName: "pencil.and.scribble")
                            .bold()
                            .foregroundStyle(Color.white)
                            .frame(width: 44, height: 44)
                            .padding(8)
                            .background(Color.lolAccent)
                            .mask(Circle())
                    }
                }
                .font(.headline)
                .padding(.horizontal)
            })
    }
    
    private func toggleFilter() {
        withAnimation {
            switch filter {
            case .mine:
                filter = .none
            default:
                filter = .mine
            }
        }
    }
}

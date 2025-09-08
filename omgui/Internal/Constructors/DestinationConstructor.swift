//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/10/23.
//

import SwiftUI

@MainActor
struct DestinationConstructor {
    
    let addressBook: AddressBook
    
    @ViewBuilder
    func destination(_ destination: NavigationDestination? = nil) -> some View {
        destinationBuilder(destination)
    }
    

    @ViewBuilder
    func destinationBuilder(_ destination: NavigationDestination?) -> some View {
        if let destination {
            viewContent(destination)
                .background(destination.gradient)
            #if os(macOS)
                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
            #endif
        } else {
            viewContent(destination)
        }
    }
        
    @ViewBuilder
    func viewContent(_ destination: NavigationDestination?) -> some View {
        let destination = destination ?? .community
        switch destination {
        case .community:
            CommunityView()
        case .address(let name, let page):
            AddressSummaryView(name, addressBook: addressBook, page: page)
                .environment(\.visibleAddress, name)
        case .webpage(let name):
            AddressProfileView(name)
        case .now(let name):
            AddressNowView(name)
        case .safety:
            SafetyView()
        case .nowGarden:
            GardenView()
        case .pastebin(let address):
            AddressPastesView(address, addressBook: addressBook)
        case .paste(let address, id: let title):
            PasteView(title, from: address)
                .environment(\.viewContext, .detail)
        case .purls(let address):
            AddressPURLsView(address, addressBook: addressBook)
        case .purl(let address, id: let title):
            PURLView(id: title, from: address)
                .environment(\.viewContext, .detail)
        case .statusLog(let address):
            StatusList([address], addressBook: addressBook)
        case .status(let address, id: let id):
            StatusView(address: address, id: id)
                .environment(\.viewContext, .detail)
        case .account:
            AccountView()
        case .lists:
            AccountView()
        case .search:
            SearchLanding()
        case .latest:
            AddressNowView("app")
                .environment(\.viewContext, .detail)
                .navigationTitle("@app /now")
                .toolbarTitleDisplayMode(.inline)
        case .support:
            PasteView("support", from: "app")
                .environment(\.viewContext, .detail)
                .navigationTitle("support")
                .toolbarTitleDisplayMode(.inline)
//        case .following:
//            FollowingView(addressBook)
//        case .followingAddresses:
//            if let fetcher = addressBook.followingFetcher {
//                ListView<AddressModel, ListRow<AddressModel>>(filters: .none, dataFetcher: fetcher, rowBuilder: { _ in return nil as ListRow<AddressModel>? })
//            }
//        case .followingStatuses:
//            if let fetcher = addressBook.followingStatusLogFetcher {
//                StatusList(fetcher: fetcher)
//            }
//        case .following(let name):
//            ListView<AddressModel, ListRow<AddressModel>>(filters: .none, dataFetcher: fetcher.followingFetcher(for: name, credential: accountModel.credential(for: name, in: addressBook)), rowBuilder: { _ in return nil as ListRow<AddressModel>? })
//        case .addressStatuses:
//            MyStatusesView(singleAddress: true, addressBook: addressBook, accountModel: accountModel)
//        case .addressPURLs:
//            MyPURLsView(singleAddress: true, addressBook: addressBook, accountModel: accountModel)
//        case .addressPastes:
//            MyPastesView(singleAddress: true, addressBook: addressBook, accountModel: accountModel)
//        case .myStatuses:
//            MyStatusesView(singleAddress: false, addressBook: addressBook, accountModel: accountModel)
//        case .myPURLs:
//            MyPURLsView(singleAddress: false, addressBook: addressBook, accountModel: accountModel)
//        case .myPastes:
//            MyPastesView(singleAddress: false, addressBook: addressBook, accountModel: accountModel)
//        case .editPURL(let address, title: let title):
//            if let credential = accountModel.credential(for: address, in: addressBook) {
//                NamedItemDraftView(fetcher: fetcher.draftPurlPoster(title, for: address, credential: credential))
//            } else {
//                // Unauthorized
//                EmptyView()
//            }
//        case .editPaste(let address, title: let title):
//            if let credential = accountModel.credential(for: address, in: addressBook) {
//                NamedItemDraftView(fetcher: fetcher.draftPastePoster(title, for: address, credential: credential))
//            } else {
//                // Unauthorized
//                EmptyView()
//            }
//        case .editWebpage(let name):
//            if let poster = addressBook.profilePoster(for: name) {
//                EditPageView(poster: poster)
//            } else {
//                // Unauthenticated
//                EmptyView()
//            }
//        case .editNow(let name):
//            if let poster = addressBook.nowPoster(for: name) {
//                EditPageView(poster: poster)
//            } else {
//                // Unauthenticated
//                EmptyView()
//            }
//        case .editStatus(let address, id: let id):
//            if address == .autoUpdatingAddress && id.isEmpty {
//                StatusDraftView(draftPoster: fetcher.draftStatusPoster(for: address, credential: accountModel.authKey))
//            } else if let credential = accountModel.credential(for: address, in: addressBook) {
//                StatusDraftView(draftPoster: fetcher.draftStatusPoster(id, for: address, credential: credential))
//            } else {
//                // Unauthenticated
//                EmptyView()
//            }
        default:
            EmptyView()
        }
    }
}

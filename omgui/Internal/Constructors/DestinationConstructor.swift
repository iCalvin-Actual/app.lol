//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/10/23.
//

import SwiftUI

@MainActor
struct DestinationConstructor {
    let sceneModel: SceneModel

    @ViewBuilder
    func destination(_ destination: NavigationDestination? = nil) -> some View {
        if let destination {
            viewContent(destination)
                .background(destination.gradient)
        } else {
            viewContent(destination)
        }
    }
        
    @ViewBuilder
    func viewContent(_ destination: NavigationDestination? = nil) -> some View {
        let destination = destination ?? .community
        switch destination {
        case .directory:
            SearchLanding(sceneModel: sceneModel)
//            DirectoryView(fetcher: sceneModel.directoryFetcher)
        case .community:
            CommunityView(sceneModel.statusFetcher)
        case .address(let name):
            AddressSummaryView(addressSummaryFetcher: sceneModel.addressSummary(name))
        case .webpage(let name):
            AddressProfileView(fetcher: sceneModel.addressSummary(name).profileFetcher, mdFetcher: sceneModel.addressSummary(name).markdownFetcher, draftFetcher: sceneModel.profileDrafts)
        case .now(let name):
            AddressNowView(fetcher: sceneModel.addressSummary(name).nowFetcher)
        case .safety:
            SafetyView(addressBook: sceneModel.addressBook)
        case .nowGarden:
            GardenView(fetcher: sceneModel.gardenFetcher)
        case .pastebin(let address):
            AddressPastesView(fetcher: sceneModel.addressSummary(address).pasteFetcher)
        case .paste(let address, id: let title):
            PasteView(
                fetcher: sceneModel.appropriateFetcher(for: address).pasteFetcher(for: title)
            )
        case .purls(let address):
            AddressPURLsView(fetcher: sceneModel.addressSummary(address).purlFetcher)
        case .purl(let address, id: let title):
            PURLView(
                fetcher: sceneModel.appropriateFetcher(for: address).purlFetcher(for: title)
            )
        case .statusLog(let address):
            StatusList(
                fetcher: sceneModel.appropriateFetcher(for: address).statusFetcher,
                filters: [FilterOption.fromOneOf([address])]
            )
        case .status(let address, id: let id):
            StatusView(fetcher: sceneModel.appropriateFetcher(for: address).statusFetcher(for: id))
        case .account:
            AccountView()
        case .lists:
            ListsView(sceneModel: sceneModel)
        case .about:
            AboutView()
        case .latest:
            AddressNowView(fetcher: sceneModel.addressSummary("app").nowFetcher)
        case .support:
            PasteView(fetcher: sceneModel.supportFetcher)
//        case .following:
//            FollowingView(addressBook)
//        case .followingAddresses:
//            if let fetcher = addressBook.followingFetcher {
//                ListView<AddressModel, ListRow<AddressModel>, EmptyView>(filters: .none, dataFetcher: fetcher, rowBuilder: { _ in return nil as ListRow<AddressModel>? })
//            }
//        case .followingStatuses:
//            if let fetcher = addressBook.followingStatusLogFetcher {
//                StatusList(fetcher: fetcher)
//            }
//        case .following(let name):
//            ListView<AddressModel, ListRow<AddressModel>, EmptyView>(filters: .none, dataFetcher: fetcher.followingFetcher(for: name, credential: accountModel.credential(for: name, in: addressBook)), rowBuilder: { _ in return nil as ListRow<AddressModel>? })
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

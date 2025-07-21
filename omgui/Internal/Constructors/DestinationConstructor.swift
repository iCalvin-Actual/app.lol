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
    let appSupportFetcher: AppSupportFetcher
    let appLatestFetcher: AppLatestFetcher

    @ViewBuilder
    func destination(_ destination: NavigationDestination? = nil) -> some View {
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
    func viewContent(_ destination: NavigationDestination? = nil) -> some View {
        let destination = destination ?? .community
        switch destination {
        case .community:
            CommunityView(addressBook.statusFetcher)
        case .address(let name):
            AddressSummaryView(addressSummaryFetcher: addressBook.addressSummary(name))
                .environment(\.visibleAddress, name)
        case .webpage(let name):
            if let profileFetcher = addressBook.addressSummary(name).profileFetcher {
                AddressProfileView(fetcher: profileFetcher, mdFetcher: addressBook.addressSummary(name).markdownFetcher)
            }
        case .now(let name):
            if let nowFetcher = addressBook.addressSummary(name).nowFetcher {
                AddressNowView(fetcher: nowFetcher)
            }
        case .safety:
            SafetyView()
        case .nowGarden:
            GardenView(fetcher: addressBook.gardenFetcher)
        case .pastebin(let address):
            AddressPastesView(fetcher: addressBook.addressSummary(address).pasteFetcher)
        case .paste(let address, id: let title):
            PasteView(
                fetcher: addressBook.appropriateFetcher(for: address).pasteFetcher(for: title)
            )
        case .purls(let address):
            AddressPURLsView(fetcher: addressBook.addressSummary(address).purlFetcher)
        case .purl(let address, id: let title):
            PURLView(
                fetcher: addressBook.appropriateFetcher(for: address).purlFetcher(for: title)
            )
        case .statusLog(let address):
            StatusList(
                fetcher: addressBook.appropriateFetcher(for: address).statusFetcher,
                filters: [FilterOption.fromOneOf([address])]
            )
        case .status(let address, id: let id):
            StatusView(fetcher: addressBook.appropriateFetcher(for: address).statusFetcher(for: id))
        case .account:
            AccountView(viewModel: .init(scribble: addressBook.scribble))
        case .lists:
            AccountView(viewModel: .init(scribble: addressBook.scribble))
        case .search:
            SearchLanding(viewModel: .init(scribble: addressBook.scribble))
        case .latest:
            AddressNowView(fetcher: appLatestFetcher)
        case .support:
            PasteView(fetcher: appSupportFetcher)
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

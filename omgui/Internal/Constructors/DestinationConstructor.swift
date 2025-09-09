//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/10/23.
//

import SwiftUI

@MainActor
@Observable
class DestinationConstructor {
    
    var addressBook: AddressBook = .init()
    
    var directoryFetcher: AddressDirectoryDataFetcher = .init(addressBook: .init())
    var gardenFetcher: NowGardenDataFetcher = .init(addressBook: .init())
    var statusFetcher: StatusLogDataFetcher = .init(addressBook: .init())
    
    var addressFollowingFetcher: AddressFollowingDataFetcher = .init(address: "", credential: "")
    var addressFollowersFetcher: AddressFollowersDataFetcher = .init(address: "", credential: "")
    var addressBlockedFetcher: AddressBlockListDataFetcher = .init(address: "", credential: "")
    
    var searchFetcher: SearchResultsDataFetcher = .init(
        addressBook: .init(),
        filters: [.address],
        query: "",
        interface: APIDataInterface()
    )
    
    init(addressBook: AddressBook) {
        self.configure(addressBook)
    }
    
    func refresh() {
        Task { [
            weak directoryFetcher,
            weak gardenFetcher,
            weak statusFetcher,
            weak addressFollowingFetcher,
            weak addressFollowersFetcher,
            weak addressBlockedFetcher,
            weak searchFetcher
        ] in
            async let directory: Void = directoryFetcher?.updateIfNeeded(forceReload: true) ?? {}()
            async let garden: Void = gardenFetcher?.updateIfNeeded(forceReload: true) ?? {}()
            async let status: Void = statusFetcher?.updateIfNeeded(forceReload: true) ?? {}()
            async let following: Void = addressFollowingFetcher?.updateIfNeeded(forceReload: true) ?? {}()
            async let followers: Void = addressFollowersFetcher?.updateIfNeeded(forceReload: true) ?? {}()
            async let blocked: Void = addressBlockedFetcher?.updateIfNeeded(forceReload: true) ?? {}()
            async let search: Void = searchFetcher?.updateIfNeeded(forceReload: true) ?? {}()
            let _ = await (directory, garden, status, following, followers, blocked, search)
        }
    }
    
    func search(
        searchFilters: Set<SearchLanding.SearchFilter>? = nil,
        searchQuery: String? = nil,
        refresh: Bool = false
    ) {
        guard refresh || (searchFilters != searchFetcher.filters || searchQuery != searchFetcher.query) else { return }
        searchFetcher.configure(
            filters: searchFilters ?? searchFetcher.filters,
            query: searchQuery ?? searchFetcher.query
        )
        
        Task { [weak searchFetcher] in
            await searchFetcher?.updateIfNeeded(forceReload: true)
        }
    }
    
    func configure(
        _ book: AddressBook
    ) {
        if book != addressBook {
            let oldBook = addressBook
            addressBook = book
            directoryFetcher = .init(addressBook: addressBook)
            gardenFetcher = .init(addressBook: addressBook)
            statusFetcher = .init(addressBook: addressBook)
            searchFetcher = .init(
                addressBook: addressBook,
                filters: searchFetcher.filters,
                query: searchFetcher.query,
                interface: APIDataInterface()
            )
            
            if oldBook.me != addressBook.me || oldBook.auth != addressBook.auth {
                addressFollowingFetcher = .init(
                    address: addressBook.me,
                    credential: addressBook.auth
                )
                addressFollowersFetcher = .init(
                    address: addressBook.me,
                    credential: addressBook.auth
                )
                addressBlockedFetcher = .init(
                    address: addressBook.me,
                    credential: addressBook.auth
                )
            }
            refresh()
        }
    }
    
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
            CommunityView(communityFetcher: statusFetcher)
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
            GardenView(gardenFetcher: gardenFetcher)
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
            AccountView(
                addressBook: addressBook,
                followingFetcher: addressFollowingFetcher,
                followersFetcher: addressFollowersFetcher
            )
        case .lists:
            AccountView(
                addressBook: addressBook,
                followingFetcher: addressFollowingFetcher,
                followersFetcher: addressFollowersFetcher
            )
        case .search:
            SearchLanding(dataFetcher: searchFetcher)
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

//
//  SearchResultsDataFetcher.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/14/25.
//

import Foundation

@Observable
class SearchResultsFetcher: Request {
    
    let directoryFetcher: AddressDirectoryFetcher
    let statusFetcher: StatusLogFetcher
    let pasteFetcher: AddressPasteBinFetcher
    let purlFetcher: AddressPURLsFetcher
    let picFetcher: PhotoFeedFetcher
    
    var addressBook: AddressBook
    var filters: Set<SearchView.SearchFilter>
    var query: String
    
    var sort: Sort
    
    // Results debouncing
    private var resultsDebounceInterval: Duration = .milliseconds(600)
    private var debounceTask: Task<Void, Never>?
    
    var results: [SearchResult] = []
    
    init(addressBook: AddressBook, filters: Set<SearchView.SearchFilter>, query: String, sort: Sort = .newestFirst, interface: OMGInterface) {
        self.filters = filters
        self.query = query
        self.addressBook = addressBook
        self.sort = sort
        self.directoryFetcher = .init(addressBook: .init(), limit: .max)
        self.statusFetcher = .init(addressBook: .init(), limit: .max)
        self.picFetcher = .init(addressBook: .init(), limit: .max)
        // Initialize with neutral values; filters will be applied in configure below
        self.pasteFetcher = .init(name: "", credential: nil, addressBook: .init())
        self.purlFetcher = .init(name: "", credential: nil, addressBook: .init())
        super.init()
    }
    
    func configure(
        addressBook: AddressBook? = nil,
        filters: Set<SearchView.SearchFilter>? = nil,
        query: String? = nil,
        sort: Sort? = nil,
        _ automation: AutomationPreferences = .init()
    ) {
        if let sort {
            self.sort = sort
        }
        if let filters {
            self.filters = filters
        }
        if let query {
            self.query = query
            directoryFetcher.configure(filters: [.query(query), .notBlocked])
            statusFetcher.configure(filters: [.query(query), .notBlocked])
            pasteFetcher.configure(filters: [.query(query), .notBlocked])
            purlFetcher.configure(filters: [.query(query), .notBlocked])
            picFetcher.configure(filters: [.query(query), .notBlocked])
        } else {
            directoryFetcher.configure(filters: .everyone)
            statusFetcher.configure(filters: .everyone)
            pasteFetcher.configure(filters: .everyone)
            purlFetcher.configure(filters: .everyone)
            picFetcher.configure(filters: .everyone)
        }
        if let addressBook {
            self.addressBook = addressBook
            directoryFetcher.configure(addressBook: addressBook)
            statusFetcher.configure(addressBook: addressBook)
            pasteFetcher.configure(addressBook: addressBook)
            purlFetcher.configure(addressBook: addressBook)
            picFetcher.configure(addressBook: addressBook)
        }
        
        super.configure()
    }
    
    @MainActor
    override func throwingRequest() async throws {
        try? await search()
    }
    
    @MainActor
    func search() async throws {
        Task { [weak directoryFetcher, weak statusFetcher, weak pasteFetcher, weak purlFetcher, weak picFetcher] in
            async let address: Void = directoryFetcher?.updateIfNeeded(forceReload: true) ?? {}()
            async let status: Void = statusFetcher?.updateIfNeeded(forceReload: true) ?? {}()
            async let paste: Void = pasteFetcher?.updateIfNeeded(forceReload: true) ?? {}()
            async let purl: Void = purlFetcher?.updateIfNeeded(forceReload: true) ?? {}()
            async let pic: Void = picFetcher?.updateIfNeeded(forceReload: true) ?? {}()
            let _ = await (address, status, paste, purl, pic)
            var result = [SearchResult]()
            
            let includeAddresses: Bool = filters.isEmpty
            let includeStatuses: Bool = filters.contains(.status)
            let includePastes: Bool = filters.contains(.paste)
            let includePURLs: Bool = filters.contains(.purl)
            let includePics: Bool = filters.contains(.pics)
            
            if includeAddresses, let directoryFetcher {
                result.append(contentsOf: directoryFetcher.results.map({ .address($0) }))
            }
            if includeStatuses, let statusFetcher {
                result.append(contentsOf: statusFetcher.results.map({ .status($0) }))
            }
            if includePastes, let pasteFetcher {
                result.append(contentsOf: pasteFetcher.results.map({ .paste($0) }))
            }
            if includePURLs, let purlFetcher {
                result.append(contentsOf: purlFetcher.results.map({ .purl($0) }))
            }
            if includePics, let picFetcher {
                result.append(contentsOf: picFetcher.results.map({ .pic($0) }))
            }
            
            self.results = result.sorted(with: sort)
        }
    }
}

//
//  SearchLanding.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 6/19/25.
//

import SwiftUI
import Combine

struct SearchLanding: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.isSearching) var searching
    @Environment(\.searchActive) var searchActive
    @Environment(\.addressBook) var addressBook
    @Environment(\.setSearchFilters) var updateFilters
    @Environment(\.addressSummaryFetcher) var summaryFetcher
    
    @State var sort: Sort = .newestFirst
    @State var filterOptions: [FilterOption] = []
    
    @Bindable
    var dataFetcher: SearchResultsDataFetcher
    
    var filter: Binding<Set<SearchFilter>> {
        .init(
            get: { dataFetcher.filters },
            set: { updateFilters($0) }
        )
    }
    
    enum SearchFilter {
        case address
        case status
        case paste
        case purl
    }

    func gridColumns(_ width: CGFloat) -> [GridItem] {
        return Array(repeating: GridItem(.flexible()), count: 3)
//        if TabBar.usingRegularTabBar(sizeClass: horizontalSizeClass, width: width) {
//            return Array(repeating: GridItem(.flexible()), count: 4)
//        } else {
//            return Array(repeating: GridItem(.flexible()), count: 2)
//        }
    }
    
    var usingCompact: Bool {
        TabBar.usingRegularTabBar(sizeClass: horizontalSizeClass)
    }
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 300, maximum: 550), spacing: 0, alignment: .top)
                    ],
                    spacing: 0,
                    pinnedViews: [.sectionHeaders, .sectionFooters]
                ) {
                    Section {
                        ForEach(dataFetcher.results, content: row(_:))
                    } header: {
                        headerToUse(proxy.size.width)
                            .padding(.bottom, 8)
                    }
                }
            }
#if !os(tvOS)
            .scrollContentBackground(.hidden)
#endif
        }
        .task { [weak dataFetcher] in
            dataFetcher?.configure(sort: sort)
            await dataFetcher?.perform()
        }
        .onChange(of: sort, {
            dataFetcher.configure(sort: sort)
            Task { [weak dataFetcher] in
                await dataFetcher?.updateIfNeeded(forceReload: true)
            }
        })
        .toolbar {
            ToolbarItem(placement: .automatic) {
                SortOrderMenu(sort: $sort, sortOptions: [.alphabet, .newestFirst, .oldestFirst])
                    .tint(.secondary)
            }
        }
        .navigationTitle("🔍 search.lol")
        .toolbarTitleDisplayMode(.inlineLarge)
    }
    
    @ViewBuilder
    func headerToUse(_ width: CGFloat) -> some View {
        if TabBar.usingRegularTabBar(sizeClass: horizontalSizeClass, width: width) {
            buttonGrid(width)
                .padding(.horizontal, 8)
        } else {
            VStack {
                buttonGrid(width)
                    .padding(.horizontal, 8)
            }
        }
    }
    
    @ViewBuilder
    func row(_ item: SearchResult) -> some View {
        switch item {
        case .status(let model):
            ListRow(model: model)
        case .paste(let model):
            ListRow(model: model)
        case .purl(let model):
            ListRow(model: model)
        case .address(let model):
            ListRow(model: model)
        }
    }

    @ViewBuilder
    func buttonGrid(_ width: CGFloat) -> some View {
        LazyVGrid(columns: gridColumns(width), spacing: 8) {
            Button(action : {
                toggle(.status)
            }, label: {
                Label {
                    Text("Status")
                } icon: {
                    Image(systemName: "star.bubble")
                }
            })
            .buttonStyle(SearchNavigationButtonStyle(selected: filter.wrappedValue.contains(.status)))
            Button(action : {
                toggle(.paste)
            }, label: {
                Label {
                    Text("Paste")
                } icon: {
                    Image(systemName: "list.clipboard")
                }
            })
            .buttonStyle(SearchNavigationButtonStyle(selected: filter.wrappedValue.contains(.paste)))
            Button(action : {
                toggle(.purl)
            }, label: {
                Label {
                    Text("PURL")
                } icon: {
                    Image(systemName: "link")
                }
            })
            .buttonStyle(SearchNavigationButtonStyle(selected: filter.wrappedValue.contains(.purl)))
        }
        .labelStyle(SearchNavigationLabelStyle())
    }
    
    private func toggle(_ toApply: SearchFilter) {
        withAnimation {
            if filter.wrappedValue.contains(toApply) {
                filter.wrappedValue.remove(toApply)
            } else {
                filter.wrappedValue = [toApply]
                filter.wrappedValue.insert(toApply)
            }
        }
    }
}

struct SearchNavigationLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
                .padding(4)
            configuration.title
        }
        .foregroundStyle(.secondary)
    }
}

struct SearchNavigationButtonStyle: ButtonStyle {
    let selected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .lineLimit(1)
            .bold(selected)
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(selected ? .white : .primary)
            .frame(minHeight: 44)
            .contentShape(Capsule())
        #if !os(visionOS)
            .glassEffect(glass)
        #endif
    }
    
    var glass: Glass {
        if selected {
            return .regular.tint(Color.accentColor)
        }
        return .regular
    }
}

struct SearchResultsView: View {
    let dataFetcher: SearchResultsDataFetcher
    
    var body: some View {
        ForEach(dataFetcher.results) { result in
            Text(result.primarySortValue)
        }
    }
}

enum SearchResult: AllSortable, Identifiable {
    static let sortOptions: [Sort] = [.newestFirst, .oldestFirst, .alphabet]
    
    static let defaultSort: Sort = .newestFirst
    
    case address(AddressModel)
    case status(StatusModel)
    case paste(PasteModel)
    case purl(PURLModel)
    
    var owner: AddressName {
        switch self {
        case .address(let model):
            return model.addressName
        case .status(let model):
            return model.addressName
        case .paste(let model):
            return model.addressName
        case .purl(let model):
            return model.addressName
        }
    }
    
    var id: String {
        switch self {
        case .address(let model):
            return NavigationDestination.address(model.addressName, page: .profile).rawValue
        case .status(let model):
            return NavigationDestination.status(model.addressName, id: model.id).rawValue
        case .paste(let model):
            return NavigationDestination.paste(model.addressName, id: model.name).rawValue
        case .purl(let model):
            return NavigationDestination.purl(model.addressName, id: model.name).rawValue
        }
    }
    
    var dateValue: Date? {
        switch self {
        case .address(let model):
            return model.dateValue
        case .status(let model):
            return model.dateValue
        case .paste(let model):
            return model.dateValue
        case .purl(let model):
            return model.filterDate
        }
    }
    
    var primarySortValue: String {
        switch self {
        case .address(let model):
            return model.addressName
        case .status(let model):
            return model.displayEmoji
        case .paste(let model):
            return model.name
        case .purl(let model):
            return model.name
        }
    }
    
    var typeText: String {
        switch self {
        case .address: return "Address"
        case .paste: return "Paste"
        case .purl: return "Purl"
        case .status: return "Status"
        }
    }
}

@Observable
class SearchResultsDataFetcher: DataFetcher {
    
    var directoryFetcher: AddressDirectoryDataFetcher
    var statusFetcher: StatusLogDataFetcher
    var pasteFetcher: AddressPasteBinDataFetcher
    var purlFetcher: AddressPURLsDataFetcher
    
    var addressBook: AddressBook
    var filters: Set<SearchLanding.SearchFilter>
    var query: String
    
    var sort: Sort
    
    // Results debouncing
    private var resultsDebounceInterval: Duration = .milliseconds(600)
    private var debounceTask: Task<Void, Never>?
    
    var results: [SearchResult] = []
    
    init(addressBook: AddressBook, filters: Set<SearchLanding.SearchFilter>, query: String, sort: Sort = .newestFirst, interface: DataInterface) {
        self.filters = filters
        self.query = query
        self.addressBook = addressBook
        self.sort = sort
        self.directoryFetcher = .init(addressBook: .init(), limit: .max)
        self.statusFetcher = .init(addressBook: .init(), limit: .max)
        // Initialize with neutral values; filters will be applied in configure below
        self.pasteFetcher = .init(name: "", credential: nil, addressBook: .init())
        self.purlFetcher = .init(name: "", credential: nil, addressBook: .init())
        super.init()
    }
    
    func configure(
        addressBook: AddressBook? = nil,
        filters: Set<SearchLanding.SearchFilter>? = nil,
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
        } else {
            directoryFetcher.configure(filters: .everyone)
            statusFetcher.configure(filters: .everyone)
            pasteFetcher.configure(filters: .everyone)
            purlFetcher.configure(filters: .everyone)
        }
        if let addressBook {
            self.addressBook = addressBook
            directoryFetcher.configure(addressBook: addressBook)
            statusFetcher.configure(addressBook: addressBook)
            pasteFetcher.configure(addressBook: addressBook)
            purlFetcher.configure(addressBook: addressBook)
        }
        
        super.configure()
    }
    
    @MainActor
    override func throwingRequest() async throws {
        try? await search()
    }
    
    @MainActor
    func search() async throws {
        Task { [weak directoryFetcher, weak statusFetcher, weak pasteFetcher, weak purlFetcher] in
            async let address: Void = directoryFetcher?.updateIfNeeded(forceReload: true) ?? {}()
            async let status: Void = statusFetcher?.updateIfNeeded(forceReload: true) ?? {}()
            async let paste: Void = pasteFetcher?.updateIfNeeded(forceReload: true) ?? {}()
            async let purl: Void = purlFetcher?.updateIfNeeded(forceReload: true) ?? {}()
            let _ = await (address, status, paste, purl)
            var result = [SearchResult]()
            
            let includeAddresses: Bool = filters.isEmpty || filters.contains(.address)
            let includeStatuses: Bool = filters.contains(.status)
            let includePastes: Bool = filters.contains(.paste)
            let includePURLs: Bool = filters.contains(.purl)
            
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
            
            self.results = result.sorted(with: sort)
        }
    }
}

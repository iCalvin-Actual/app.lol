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
    @Environment(\.searchFetcher) var dataFetcher
    @Environment(\.setSearchFilters) var updateFilters
    
    @State var sort: Sort = .shuffle
    @State var filterOptions: [FilterOption] = []
    
    var filter: Binding<Set<SearchFilter>> {
        .init(
            get: { dataFetcher?.filters ?? [] },
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
                        GridItem(.adaptive(minimum: 250, maximum: 400), spacing: 8, alignment: .top)
                    ],
                    spacing: 8,
                    pinnedViews: [.sectionHeaders, .sectionFooters]
                ) {
                    Section {
                        ForEach(dataFetcher?.results ?? [], content: row(_:))
                    } header: {
                        headerToUse(proxy.size.width)
                    }
                }
                .padding(.horizontal, 8)
            }
#if !os(tvOS)
            .scrollContentBackground(.hidden)
#endif
        }
        .onChange(of: sort, {
            dataFetcher?.configure(sort: sort)
            Task { [dataFetcher] in
                await dataFetcher?.updateIfNeeded(forceReload: true)
            }
        })
        .task { [weak dataFetcher] in
            dataFetcher?.configure(sort: sort)
            await dataFetcher?.perform()
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                SortOrderMenu(sort: $sort, filters: $filterOptions, sortOptions: [.alphabet, .newestFirst, .oldestFirst, .shuffle], filterOptions: [])
                    .tint(.primary)
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
    static let sortOptions: [Sort] = [.newestFirst, .oldestFirst, .shuffle, .alphabet]
    
    static let defaultSort: Sort = .newestFirst
    
    case address(AddressModel)
    case status(StatusModel)
    case paste(PasteModel)
    case purl(PURLModel)
    
    var id: String {
        switch self {
        case .address(let model):
            return model.addressName
        case .status(let model):
            return model.id
        case .paste(let model):
            return model.name
        case .purl(let model):
            return model.name
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

class SearchResultsDataFetcher: DataFetcher {
    
    @Published var directoryFetcher: AddressDirectoryDataFetcher
    @Published var statusFetcher: StatusLogDataFetcher
    @Published var pasteFetcher: AddressPasteBinDataFetcher
    @Published var purlFetcher: AddressPURLsDataFetcher
    
    var addressBook: AddressBook
    var filters: Set<SearchLanding.SearchFilter>
    var query: String
    
    var sort: Sort
    
    // Results debouncing
    private var resultsDebounceInterval: RunLoop.SchedulerTimeType.Stride = .milliseconds(300)
    
    @Published
    var results: [SearchResult] = []
    
    func constructResults() {
        var result = [SearchResult]()
        
        let includeAddresses: Bool = filters.isEmpty
        let includeStatuses: Bool = filters.contains(.status)
        let includePastes: Bool = filters.contains(.paste)
        let includePURLs: Bool = filters.contains(.purl)
        
        if includeAddresses {
            result.append(contentsOf: directoryFetcher.results.map({ .address($0) }))
        }
        if includeStatuses {
            result.append(contentsOf: statusFetcher.results.map({ .status($0) }))
        }
        if includePastes {
            result.append(contentsOf: pasteFetcher.results.map({ .paste($0) }))
        }
        if includePURLs {
            result.append(contentsOf: purlFetcher.results.map({ .purl($0) }))
        }
        
        self.results = result.sorted(with: sort)
    }
    
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
        bindFetchers()
        constructResults()
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
    
    // Observe fetcher results and rebuild our aggregated results, debounced to avoid flicker.
    private func bindFetchers() {
        // Clear any prior subscriptions related to this binding
        requests.removeAll()
        
        directoryFetcher.$results
            .debounce(for: resultsDebounceInterval, scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.constructResults()
            }
            .store(in: &requests)
        
        statusFetcher.$results
            .debounce(for: resultsDebounceInterval, scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.constructResults()
            }
            .store(in: &requests)
        
        pasteFetcher.$results
            .debounce(for: resultsDebounceInterval, scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.constructResults()
            }
            .store(in: &requests)
        
        purlFetcher.$results
            .debounce(for: resultsDebounceInterval, scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.constructResults()
            }
            .store(in: &requests)
    }
    
    @MainActor
    override func throwingRequest() async throws {
        try? await search()
    }
    
    @MainActor
    func search() async throws {
        Task { [directoryFetcher] in
            await directoryFetcher.updateIfNeeded(forceReload: true)
        }
        Task { [statusFetcher] in
            await statusFetcher.updateIfNeeded(forceReload: true)
        }
        Task { [pasteFetcher] in
            await pasteFetcher.updateIfNeeded(forceReload: true)
        }
        Task { [purlFetcher] in
            await purlFetcher.updateIfNeeded(forceReload: true)
        }
        
        objectWillChange.send()
    }
}

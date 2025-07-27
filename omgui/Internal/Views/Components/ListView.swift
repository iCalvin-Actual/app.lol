//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct ListView<T: Listable, H: View>: View {
    
    @Namespace
    var namespace
    
    @Environment(\.horizontalSizeClass) var horizontalSize
    @Environment(\.verticalSizeClass)   var verticalSize
    
    @Environment(\.destinationConstructor) var destinationConstructor
    @Environment(\.addressBook)     var addressBook
    @Environment(\.presentListable) var present
    
    @Environment(\.addressFollowingFetcher) var following
    @Environment(\.addressBlockListFetcher) var blocked
    @Environment(\.localBlocklist) var localBlocked
    @Environment(\.pinnedFetcher) var pinned
    
    @Environment(\.viewContext) var context: ViewContext
    @State var selected: T?
    @State var queryString: String = ""
    
    @State var sort: Sort = T.defaultSort
    @State var filters: [FilterOption]
    
    @State var presentingDetail: Bool = false
    
    @FocusState var focusItem: T?
    
    @ObservedObject
    var dataFetcher: ListFetcher<T>
    
    @ViewBuilder
    let headerBuilder: (() -> H)?
    
    let menuBuilder: ContextMenuBuilder<T> = .init()
    
    func usingRegular(_ width: CGFloat) -> Bool {
        TabBar.usingRegularTabBar(sizeClass: horizontalSize, width: width)
    }
    
    func overridePresenter(_ item: any Listable) {
        guard presentingDetail, let listItem = item as? T else {
            present?(item)
            return
        }
        selected = listItem
    }
    
    init(
        filters: [FilterOption] = T.defaultFilter,
        dataFetcher: ListFetcher<T>,
        headerBuilder: (() -> H)? = nil
    ) {
        self.filters = filters
        self.dataFetcher = dataFetcher
        self.headerBuilder = headerBuilder
    }
    
    var items: [T] {
        if T.self is any BlackbirdListable.Type {
            return dataFetcher.results
        }
        
        var filters = filters
        if !queryString.isEmpty {
            filters.append(.query(queryString))
        }
        return filters
            .applyFilters(to: dataFetcher.results, with: addressBook)
            .sorted(with: sort)
    }
    
    var applicableFilters: [FilterOption] {
        addressBook.signedIn ? T.filterOptions : []
    }
    
    var body: some View {
        sizeAppropriateBody
            .task { [dataFetcher] in
                dataFetcher.fetchNextPageIfNeeded()
            }
            .onAppear {
                guard horizontalSize == .compact, selected != nil else {
                    return
                }
                withAnimation {
                    selected = nil
                }
            }
            .onChange(of: sort, { dataFetcher.sort = $1 })
            .onChange(of: filters, { dataFetcher.filters = $1 })
            .onChange(of: queryString, { oldValue, newValue in
                var newFilters = filters
                newFilters.removeAll(where: { filter in
                    switch filter {
                    case .query:
                        return true
                    default:
                        return false
                    }
                })
                defer {
                    dataFetcher.results = []
                    dataFetcher.nextPage = 0
                    Task { [dataFetcher] in
                        await dataFetcher.updateIfNeeded(forceReload: true)
                    }
                }
                guard !newValue.isEmpty else {
                    filters = newFilters
                    return
                }
                newFilters.append(.query(newValue))
                filters = newFilters
            })
            .toolbar {
                if T.sortOptions.count > 1 || applicableFilters.count > 1 {
                    ToolbarItem(placement: .automatic) {
                        SortOrderMenu(sort: $sort, filters: $filters, sortOptions: T.sortOptions, filterOptions: applicableFilters)
                    }
                }
            }
    }
    
    @ViewBuilder
    var sizeAppropriateBody: some View {
        GeometryReader { proxy in
            if horizontalSize == .compact {
                compactBody()
                    .task {
                        presentingDetail = false
                    }
            } else {
                if usingRegular(proxy.size.width) {
                    regularBody(actingWidth: proxy.size.width)
                        .task {
                            presentingDetail = true
                        }
                } else {
                    compactBody()
                        .task {
                            presentingDetail = false
                        }
                        .environment(\.horizontalSizeClass, .compact)
                }
            }
        }
    }
    
    @ViewBuilder
    func compactBody() -> some View {
        list()
            .animation(.easeInOut(duration: 0.3), value: dataFetcher.loaded)
            .listRowBackground(Color.clear)
    }
    
    @ViewBuilder
    func regularBody(actingWidth: CGFloat) -> some View {
        HStack(spacing: 0) {
            compactBody()
                .frame(maxWidth: 300)
                .environment(\.viewContext, .column)
            regularBodyContent()
                .frame(maxWidth: .infinity)
                .environment(\.viewContext, context == .profile ? .profile : .detail)
                .environment(\.horizontalSizeClass, actingWidth > 300 ? .regular : .compact)
        }
        .onReceive(dataFetcher.$results) { newResults in
            if selected == nil, let item = newResults.first {
                selected = item
                if horizontalSize == .regular {
                    focusItem = item
                }
            }
        }
    }
    
    @ViewBuilder
    func regularBodyContent() -> some View {
        if let selected = selected {
            destinationConstructor?.destination(destination(for: selected))
        } else {
            ThemedTextView(text: "no selection")
                .padding()
        }
    }
    
    @ViewBuilder
    func list() -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                listItems()
                    .listRowBackground(Color.clear)
                    .padding(.vertical, 4)
                
                if queryString.isEmpty && dataFetcher.nextPage != nil {
                    LoadingView()
                        .padding(32)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .listRowBackground(Color.clear)
                        .onAppear { [dataFetcher] in
                            dataFetcher.fetchNextPageIfNeeded()
                        }
                }
            }
            .refreshable(action: { [dataFetcher] in
                await dataFetcher.updateIfNeeded(forceReload: true)
            })
            .listStyle(.plain)
#if canImport(UIKit) && !os(tvOS)
            .listRowSpacing(0)
#endif
        }
        .scrollEdgeEffectStyle(.soft, for: .top)
        #if !os(tvOS)
        .scrollContentBackground(.hidden)
        #endif
        .onReceive(dataFetcher.$loaded, perform: { _ in
            var newSelection: T?
            switch (
                horizontalSize == .regular,
                dataFetcher.loaded != nil,
                selected == nil
            ) {
            case (false, true, false):
                newSelection = nil
            case (true, true, true):
                newSelection = dataFetcher.results.first
            default:
                return
            }
            
            withAnimation { @MainActor in
                self.selected = newSelection
            }
        })
    }
    
    @ViewBuilder
    func listItems() -> some View {
        if let headerBuilder = headerBuilder {
            Section {
                headerBuilder()
                #if !os(tvOS)
                    .listRowSeparator(.hidden)
                #endif
            }
            Section(dataFetcher.title) {
                listContent()
                    .padding(.horizontal, 8)
            }
        } else {
            listContent()
                .padding(.horizontal, 8)
        }
    }
    
    @ViewBuilder
    func listContent() -> some View {
        if dataFetcher.noContent {
            emptyRowView()
        } else if !items.isEmpty {
            ForEach(items, content: { rowView($0).listRowBackground(Color.clear) })
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    func emptyRowView() -> some View {
        HStack {
            Spacer()
            ThemedTextView(text: "empty")
                .font(.title3)
                .bold()
                .padding()
            Spacer()
        }
#if !os(tvOS)
        .listRowSeparator(.hidden, edges: .all)
        #endif
        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
    
    @ViewBuilder
    func rowView(_ item: T) -> some View {
        rowBody(item)
            .tag(item)
            .focused($focusItem, equals: item)
        #if !os(tvOS)
            .listRowSeparator(.hidden, edges: .all)
        #endif
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .contextMenu(menuItems: {
                menuBuilder.contextMenu(
                    for: item,
                    fetcher: dataFetcher,
                    addressBook: addressBook,
                    menuFetchers: (
                        following,
                        blocked,
                        localBlocked,
                        pinned
                    )
                )
            }) {
                AddressCard(item.addressName)
            }
    }
    
    @ViewBuilder
    func rowBody(_ item: T) -> some View {
        buildRow(item)
    }
    
    private func destination(for item: T) -> NavigationDestination? {
        switch item {
        case let nowModel as NowListing:
            return .now(nowModel.owner)
        case let pasteModel as PasteModel:
            return .paste(pasteModel.addressName, id: pasteModel.name)
        case let purlModel as PURLModel:
            return .purl(purlModel.addressName, id: purlModel.name)
        case let statusModel as StatusModel:
            return .status(statusModel.address, id: statusModel.id)
        case let addressModel as AddressModel:
            return .address(addressModel.addressName)
        default:
            if context == .column {
                return .address(item.addressName)
            }
        }
        return nil
    }
    
    @ViewBuilder
    func buildRow(_ item: T) -> some View {
        ListRow<T>(model: item, selected: $selected)
            .environment(\.presentListable, {
                overridePresenter($0)
            })
    }
}


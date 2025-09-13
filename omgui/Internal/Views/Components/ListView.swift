//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct ListView<T: Listable>: View {
    @Environment(\.namespace) var namespace
    @Namespace var localNamespace
    
    @Environment(\.horizontalSizeClass) var horizontalSize
    @Environment(\.verticalSizeClass)   var verticalSize
    
    @Environment(\.destinationConstructor) var destinationConstructor
    @Environment(\.addressBook)     var addressBook
    @Environment(\.presentListable) var present
    
    @Environment(\.pinAddress) var pin
    @Environment(\.unpinAddress) var unpin
    @Environment(\.blockAddress) var block
    @Environment(\.unblockAddress) var unblock
    @Environment(\.followAddress) var follow
    @Environment(\.unfollowAddress) var unfollow
    
    @Environment(\.viewContext) var context: ViewContext
    
    @State var selected: T?
    @State var queryString: String = ""
    
    @State var sort: Sort = T.defaultSort
    @State var filters: [FilterOption]
    
    @State var presentingDetail: Bool = false
    
    let dataFetcher: ListFetcher<T>
    
    func usingRegular(_ width: CGFloat) -> Bool {
        TabBar.usingRegularTabBar(sizeClass: horizontalSize, width: width)
    }
    
    func overridePresenter(_ item: NavigationDestination) {
        guard presentingDetail else {
            present?(.safety)
            return
        }
        switch item {
        case .status(let name, id: let id):
            selected = dataFetcher.results.first(where: {
                guard let statusModel = $0 as? StatusModel else { return false }
                return statusModel.id == id && statusModel.owner == name
            })
        case .paste(let name, id: let id):
            selected = dataFetcher.results.first(where: {
                guard let pasteModel = $0 as? PasteModel else { return false }
                return pasteModel.name == id && pasteModel.owner == name
            })
        case .purl(let name, id: let id):
            selected = dataFetcher.results.first(where: {
                guard let purlModel = $0 as? PURLModel else { return false }
                return purlModel.name == id && purlModel.owner == name
            })
        case .now(let name):
            selected = dataFetcher.results.first(where: { ($0 as? NowListing)?.addressName == name })
        case .address(let name, let page):
            switch page {
            case .profile:
                selected = dataFetcher.results.first(where: { ($0 as? AddressModel)?.addressName == name })
            case .now:
                selected = dataFetcher.results.first(where: { ($0 as? NowListing)?.addressName == name })
            default:
                present?(item)
            }
        default:
            present?(item)
        }
    }
    
    init(
        filters: [FilterOption] = T.defaultFilter,
        dataFetcher: ListFetcher<T>
    ) {
        self.filters = filters
        self.dataFetcher = dataFetcher
    }
    
    var applicableFilters: [FilterOption] {
        addressBook.signedIn ? T.filterOptions : []
    }
    
    var body: some View {
        sizeAppropriateBody
            .refreshable {
                dataFetcher.refresh()
            }
            .task { [dataFetcher] in
                dataFetcher.fetchNextPageIfNeeded()
            }
            .onChange(of: sort, { dataFetcher.sort = $1 })
            .onChange(of: filters, { dataFetcher.filters = $1 })
            .toolbar {
                if T.sortOptions.count > 1 || applicableFilters.count > 1 {
                    ToolbarItemGroup {
                        if applicableFilters.count > 1 {
                            FilterOptionsMenu(filters: $filters, filterOptions: applicableFilters)
                        }
                        if T.sortOptions.count > 1 {
                            SortOrderMenu(sort: $sort, sortOptions: T.sortOptions)
                        }
                    }
                }
            }
            .tint(.primary)
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
        InnerList(
            dataFetcher: dataFetcher,
            selected: $selected,
            filters: filters,
            menuFetchers: (
                navigate: present ?? { _ in },
                follow: follow,
                block: block,
                pin: pin,
                unFollow: unfollow,
                unBlock: unblock,
                unPin: unpin
            )
        )
        .animation(.easeInOut(duration: 0.3), value: dataFetcher.loaded)
        .listRowBackground(Color.clear)
    }
    
    @ViewBuilder
    func regularBody(actingWidth: CGFloat) -> some View {
        HStack(spacing: 0) {
            compactBody()
                .frame(maxWidth: 300)
                .environment(\.horizontalSizeClass, .compact)
                .environment(\.viewContext, .column)
                .environment(\.presentListable, { listable in
                    overridePresenter(listable)
                })
            detailBody(selected: selected)
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(edges: .bottom)
                .environment(\.viewContext, context == .profile ? .profile : .detail)
                .environment(\.horizontalSizeClass, actingWidth > 300 ? .regular : .compact)
        }
        .onChange(of: dataFetcher.results, { _, newResults in
            if selected == nil, let item = newResults.first {
                withAnimation {
                    selected = item
                }
            }
        })
    }

    @ViewBuilder
    func detailBody(selected: T?) -> some View {
        Detail(selected: selected)
            .frame(minWidth: 200)
            .id(selected?.id)
    }
    
    struct InnerList: View {
        @Environment(\.horizontalSizeClass) var horizontalSize
        @Environment(\.addressBook) var addressBook
        @Environment(\.presentListable) var present
        
        @Bindable var dataFetcher: ListFetcher<T>
        
        @Binding var selected: T?
        
        let filters: [FilterOption]
        let sort: Sort = T.defaultSort
        
        let menuFetchers: ContextMenuClosures
        let menuBuilder: ContextMenuBuilder<T> = .init()
        
        var items: [T] {
            if T.self is any BlackbirdListable.Type {
                return dataFetcher.results
            }
            
            return filters
                .applyFilters(to: dataFetcher.results, with: addressBook)
                .sorted(with: sort)
        }
        
        var body: some View {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: -4) {
                    listItems()
                        .listRowBackground(Color.clear)
                    
                    if dataFetcher.nextPage != nil {
                        Color.clear
                            .padding(32)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .listRowBackground(Color.clear)
                            .onAppear { [dataFetcher] in
                                dataFetcher.fetchNextPageIfNeeded()
                            }
                    }
                }
                .padding(.horizontal, 0)
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
            .frame(minWidth: 200)
            .navigationTitle(dataFetcher.title)
            .toolbarTitleDisplayMode(.inlineLarge)
        }
        
        @ViewBuilder
        func listItems() -> some View {
            listContent()
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
                if dataFetcher.loaded != nil && dataFetcher.results.isEmpty {
                    ThemedTextView(text: "empty")
                        .font(.title3)
                        .bold()
                        .padding()
                }
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
            #if !os(tvOS)
                .listRowSeparator(.hidden, edges: .all)
            #endif
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
        
        @ViewBuilder
        func rowBody(_ item: T) -> some View {
            buildRow(item)
        }
        
        @ViewBuilder
        func buildRow(_ item: T) -> some View {
            ListRow<T>(model: item, selected: $selected)
        }
    }
    
    struct Detail: View {
        @Environment(\.destinationConstructor) var destinationConstructor
        
        let selected: T?
        
        var body: some View {
            if let selected {
                destinationConstructor?.destination(ListView.destination(for: selected, showingDetail: true))
            } else {
               ThemedTextView(text: "no selection")
                   .padding()
           }
        }
    }
}

extension ListView {
    static private func destination(for item: T, in context: ViewContext = .column, showingDetail: Bool = false) -> NavigationDestination? {
        switch item {
        case let nowModel as NowListing:
//            if !showingDetail {
//                return .address(nowModel.owner, page: .now)
//            }
            return .now(nowModel.owner)
        case let pasteModel as PasteModel:
            return .paste(pasteModel.addressName, id: pasteModel.name)
        case let purlModel as PURLModel:
            return .purl(purlModel.addressName, id: purlModel.name)
        case let statusModel as StatusModel:
            return .status(statusModel.address, id: statusModel.id)
        case let addressModel as AddressModel:
            return .address(addressModel.addressName, page: .profile)
        default:
            if context == .column {
                return .address(item.addressName, page: .profile)
            }
        }
        return nil
    }
}


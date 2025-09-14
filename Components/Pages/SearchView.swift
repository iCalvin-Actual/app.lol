//
//  SearchLanding.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 6/19/25.
//

import SwiftUI
import Combine

struct SearchView: View {
    enum SearchFilter: CaseIterable {
        case status
        case paste
        case purl
        case pics
        
        var displayName: String {
            switch self {
            case .status: return "Status"
            case .paste:  return "Paste"
            case .purl:   return "PURL"
            case .pics:   return "Pic"
            }
        }
        
        var icon: String {
            switch self {
            case .status: return "star.bubble"
            case .paste:  return "list.clipboard"
            case .purl:   return "link"
            case .pics:   return "camera.macro"
            }
        }
    }
    
    @Environment(\.horizontalSizeClass)
        var horizontalSizeClass
    @Environment(\.setSearchFilters)
        var updateFilters
    
    @State
        var sort: Sort = .newestFirst
    
    @Bindable
        var dataFetcher: SearchResultsFetcher
    
    var filter: Binding<Set<SearchFilter>> {
        .init(
            get: { dataFetcher.filters },
            set: { updateFilters($0) }
        )
    }
    
    var usingCompact: Bool {
        .usingRegularTabBar(sizeClass: horizontalSizeClass)
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
                        buttonGrid (proxy.size.width)
                            .padding(.bottom, 8)
                            .padding(.horizontal, 8)
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
    private func buttonGrid(_ width: CGFloat) -> some View {
        LazyVGrid(columns: gridColumns(width), spacing: 8) {
            ForEach(SearchFilter.allCases, id: \.hashValue) { item in
                Button(action : {
                    toggle(item)
                }, label: {
                    Label {
                        Text(item.displayName)
                    } icon: {
                        Image(systemName: item.icon)
                    }
                })
                .buttonStyle(SearchNavigationButtonStyle(selected: filter.wrappedValue.contains(item)))
            }
        }
        .labelStyle(SearchNavigationLabelStyle())
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
        case .pic(let model):
            ListRow(model: model)
        }
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
    
    private func gridColumns(_ width: CGFloat) -> [GridItem] {
        if .usingRegularTabBar(sizeClass: horizontalSizeClass, width: width) {
            return Array(repeating: GridItem(.flexible()), count: 4)
        } else {
            return Array(repeating: GridItem(.flexible()), count: 2)
        }
    }
}

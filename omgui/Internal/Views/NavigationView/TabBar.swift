//
//  File.swift
//
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct TabBar: View {
    static func usingRegularTabBar(sizeClass: UserInterfaceSizeClass?, width: CGFloat? = nil) -> Bool {
        guard UIDevice.current.userInterfaceIdiom != .phone && (sizeClass ?? .regular) != .compact else {
            return false
        }
        if let width {
            return width >= 300
        }
        return true
    }
    
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass
    
    @SceneStorage("app.tab.selected")
    var selected: NavigationItem?
    
    let tabModel: SidebarModel
    
    init(sceneModel: SceneModel) {
        self.tabModel = .init(sceneModel: sceneModel)
    }
    
    var body: some View {
        if !Self.usingRegularTabBar(sizeClass: horizontalSizeClass) {
            compactTabBar
                .onAppear{
                    if selected == nil {
                        selected = .community
                    }
                }
        } else {
            regularTabBar
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        LogoView()
                    }
                }
        }
    }
    
    @State var searchQuery: String = ""
    
    @ViewBuilder
    var compactTabBar: some View {
        TabView(selection: $selected) {
            ForEach(tabModel.tabs) { item in
                Tab(item.displayString, systemImage: item.iconName, value: item, role: item == .search ? .search : nil) {
                    tabContent(item.destination)
                }
                .hidden(Self.usingRegularTabBar(sizeClass: horizontalSizeClass))
            }
        }
        .searchable(text: $searchQuery)
        .tabBarMinimizeBehavior(.onScrollDown)
    }
    
    @ViewBuilder
    var regularTabBar: some View {
        TabView(selection: $selected) {
            Tab(NavigationItem.search.displayString, systemImage: NavigationItem.search.iconName, value: NavigationItem.search, role: .search) {
                tabContent(NavigationItem.search.destination)
            }

            ForEach(tabModel.sections) { section in
                TabSection(section.displayName) {
                    ForEach(tabModel.items(for: section, sizeClass: .regular, context: .column)) { item in
                        Tab(item.displayString, systemImage: item.iconName, value: item) {
                            tabContent(item.destination)
                        }
                    }
                }
            }
        }
        .searchable(text: $searchQuery)
        .tabViewStyle(.sidebarAdaptable)
    }
    
    @ViewBuilder
    func tabContent(_ destination: NavigationDestination) -> some View {
        NavigationStack {
            sceneModel.destinationConstructor.destination(destination)
                .navigationDestination(for: NavigationDestination.self, destination: sceneModel.destinationConstructor.destination(_:))
        }
    }
}

#Preview {
    TabBar(sceneModel: .sample)
        .environment(SceneModel.sample)
        .environment(AccountAuthDataFetcher(authKey: nil, client: .sample, interface: SampleData()))
}

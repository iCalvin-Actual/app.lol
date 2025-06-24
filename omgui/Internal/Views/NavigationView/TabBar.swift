//
//  File.swift
//
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct TabBar: View {
    static func usingRegularTabBar(sizeClass: UserInterfaceSizeClass?, width: CGFloat? = nil) -> Bool {
        #if canImport(UIKit)
        guard UIDevice.current.userInterfaceIdiom != .phone && (sizeClass ?? .regular) != .compact else {
            return false
        }
        if let width {
            print("Width: \(width)")
            return width >= 500
        }
        #endif
        return true
    }
    
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    
    @FocusState
    var searching: Bool
    
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass
    
    @SceneStorage("app.tab.selected")
    var selected: NavigationItem? {
        didSet {
            searching = false
        }
    }
    
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
                .onAppear{
                    if selected == nil {
                        selected = .community
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
        .searchFocused($searching)
        #if canImport(UIKit)
        .tabBarMinimizeBehavior(.onScrollDown)
        #endif
    }
    
    @ViewBuilder
    var regularTabBar: some View {
        NavigationSplitView {
            List(selection: $selected) {
                // Sections from SidebarModel
                ForEach(tabModel.sections, id: \.self) { section in
                    Section {
                        ForEach(tabModel.items(for: section, sizeClass: .regular, context: .column), id: \.self) { item in
                            NavigationLink(value: item) {
                                Label(item.displayString, systemImage: item.iconName)
                            }
                        }
                    } header: {
                        if section != .directory {
                            Text(section.displayName)
                        }
                    }
                }
            }
        } detail: {
            if searching {
                sceneModel.destinationConstructor.destination(.search)
            } else {
                if let selected {
                    tabContent(selected.destination)
                }
            }
        }
        .searchable(text: $searchQuery)
        .searchFocused($searching)
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


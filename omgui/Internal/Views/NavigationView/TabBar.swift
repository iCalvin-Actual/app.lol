//
//  File.swift
//
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI
import WebKit

struct TabBar: View {
    static private let minimumRegularWidth: CGFloat = 665
    
    static func usingRegularTabBar(sizeClass: UserInterfaceSizeClass?, width: CGFloat? = nil) -> Bool {
        let width = width ?? minimumRegularWidth
        #if canImport(UIKit)
        switch UIDevice.current.userInterfaceIdiom {
        case .vision,
                .mac,
                 .tv:
            return true
        case .pad:
            return (sizeClass ?? .regular) != .compact && width >= minimumRegularWidth
        default:
            return false
        }
        #elseif os(macOS)
        return true
        #endif
    }
    
    @SceneStorage("app.tab.selected")
    var cachedSelection: NavigationItem = .community
    
    @State
    var selected: NavigationItem? {
        didSet {
            if let selected {
                cachedSelection = selected
            }
        }
    }
    
    @Environment(\.addressBook)
    var addressBook
    @Environment(\.destinationConstructor)
    var destinationConstructor
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass
    @Environment(\.setAddress)
    var setAddress
    
    @State
    var visibleAddress: AddressName = ""
    @State
    var visibleAddressPage: AddressContent = .profile
    @State
    var presentAccount: Bool = false
    
    @FocusState
    var searching: Bool {
        didSet {
            if searching {
                selected = .search
            }
        }
    }
    
    var tabModel: SidebarModel {
        .init(addressBook: addressBook)
    }
    
    var body: some View {
        appropriateBody
            .onAppear(perform: {
                if selected == nil {
                    selected = cachedSelection
                }
            })
            .onReceive(selected.publisher, perform: { newValue in
                if searching && selected != .search {
                    searching = false
                }
            })
            .environment(\.presentListable, { item in
                path.append(item.rowDestination)
            })
            .environment(\.setVisibleAddress, { visible in
                visibleAddress = visible ?? ""
            })
            .environment(\.searchActive, searching)
            .environment(\.visibleAddressPage, visibleAddressPage)
            .environment(\.visibleAddress, visibleAddress)
    }
    
    @ViewBuilder
    var appropriateBody: some View {
        if !Self.usingRegularTabBar(sizeClass: horizontalSizeClass) {
            compactTabBar
        } else {
            regularTabBar
        }
    }
    
    @State var searchQuery: String = ""
    
    @ViewBuilder
    var compactTabBar: some View {
        TabView(selection: $selected) {
            ForEach(tabModel.tabs) { item in
                Tab(item.displayString, systemImage: item.iconName, value: item, role: item == .search ? .search : nil) {
                    tabContent(item)
                }
                #if !os(tvOS)
                .hidden(Self.usingRegularTabBar(sizeClass: horizontalSizeClass))
                #endif
            }
        }
        .searchable(text: $searchQuery)
        #if !os(tvOS)
        .searchFocused($searching)
        #endif
        #if os(iOS)
        .tabBarMinimizeBehavior(.onScrollDown)
        .tabViewBottomAccessory {
            if !visibleAddress.isEmpty {
                addressAccessory(visibleAddress)
            } else {
                Group {
                    if !addressBook.me.isEmpty {
                        addressAccessory(addressBook.me, showPicker: false)
                    } else {
                        addressAccessory(addressBook.me, showPicker: false)
                    }
                }
                //                    .foregroundStyle(.primary)
                .contentShape(Rectangle())
                .onTapGesture {
                    presentAccount.toggle()
                }
                .sheet(isPresented: $presentAccount) {
                    NavigationStack {
                        navigationContent(.account)
                            .environment(\.setAddress, setAddress)
                            .environment(\.presentListable, { listItem in
                                print("Do a thing")
                            })
                            .environment(\.addressBook, addressBook)
                    }
                }
            }
        }
        #endif
    }
        
    @ViewBuilder
    func addressAccessory(_ address: AddressName, showPicker: Bool = true) -> some View {
        HStack {
            AddressIconView(address: address, contentShape: Circle())
            AddressNameView(address)
            Spacer()
            if showPicker {
                destinationPicker
            }
        }
        .padding(.top, 2)
        .padding(.horizontal, 2)
    }
    
    @ViewBuilder
    var destinationPicker: some View {
        Picker("Destination", selection: .constant(AddressContent.profile)) {
            ForEach(AddressContent.allCases) { page in
                Text(page.displayString)
                    .tag(page)
            }
        }
        .pickerStyle(.menu)
        .frame(maxHeight: 44)
    }
    
    @State
    var collapsed: Set<SidebarModel.Section> = .init()
    
    func isExpanded(_ section: SidebarModel.Section) -> Binding<Bool> {
        .init {
            !collapsed.contains(section)
        } set: { newValue in
            if newValue {
                collapsed.remove(section)
            } else {
                collapsed.insert(section)
            }
        }

    }
    
    @ViewBuilder
    var regularTabBar: some View {
        NavigationSplitView {
            List(selection: $selected) {
                // Sections from SidebarModel
                ForEach(tabModel.sections, id: \.self) { section in
                    Section(section.displayName, isExpanded: isExpanded(section)) {
                        ForEach(tabModel.items(for: section, sizeClass: .regular, context: .column), id: \.self) { item in
                            NavigationLink(value: item) {
                                Label(item.displayString, systemImage: item.iconName)
                            }
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom, content: {
                if !addressBook.signedIn {
                    AuthenticateButton()
                }
            })
        } detail: {
            if let selected {
                tabContent(selected)
                    .background(selected.destination.gradient)
            }
        }
        .searchable(text: $searchQuery)
        #if !os(tvOS)
        .searchFocused($searching)
        #endif
    }
    
    @State
    var paths: [NavigationItem: NavigationPath] = .init()
    
    @State
    var path: NavigationPath = .init()
    
    @ViewBuilder
    func tabContent(_ item: NavigationItem) -> some View {
        NavigationStack(path: $path) {
            navigationContent(item.destination)
                .background(
                    item.destination.gradient
                )
//                .toolbarBackground(Color.clear, for: .automatic)
                .toolbar {
                    #if canImport(UIKit)
                    if horizontalSizeClass == .compact {
                        ToolbarItem(placement: .topBarLeading) {
                            OptionsButton()
                        }
                    }
                    #endif
                }
                .navigationDestination(for: NavigationDestination.self) { destination in
                    destinationConstructor?.destination(destination)
                }
        }
        .id(item.id)
    }
    
    
    private var activePath: Binding<NavigationPath> {
        path(for: selected ?? .community)
    }
    private func path(for item: NavigationItem) -> Binding<NavigationPath> {
        .init {
            var newValue = NavigationPath()
            newValue.append(item.destination)
            return paths[item] ?? newValue
        } set: { newValue in
            paths.updateValue(newValue, forKey: item)
        }

    }
    
    @ViewBuilder
    func navigationContent(_ destination: NavigationDestination) -> some View {
        destinationConstructor?.destination(destination)
    }
}

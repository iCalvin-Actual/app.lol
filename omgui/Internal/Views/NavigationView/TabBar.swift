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
    var selected: NavigationItem? {
        willSet {
            if newValue != .search {
                searching = false
            }
        }
    }
    
    @Environment(\.addressBook)
    var addressBook
    @Environment(\.destinationConstructor)
    var destinationConstructor
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass
    
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
        .init(pinnedFetcher: addressBook?.pinnedAddressFetcher)
    }
    
    var body: some View {
        appropriateBody
            .environment(\.presentAddress, { address in
                activePath.wrappedValue.append(NavigationDestination.address(address))
            })
            .environment(\.destinationConstructor, addressBook?.destinationConstructor)
            .environment(\.searchActive, searching)
            .environment(\.visibleAddressPage, visibleAddressPage)
            .environment(\.visibleAddress, visibleAddress)
            .onChange(of: searching) { oldValue, newValue in
                if newValue {
                    selected = .search
                }
            }
    }
    
    @ViewBuilder
    var appropriateBody: some View {
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
            } else if let addressBook {
                Group {
                    if !addressBook.actingAddress.isEmpty {
                        addressAccessory(addressBook.actingAddress, showPicker: false)
                    } else {
                        addressAccessory(addressBook.actingAddress, showPicker: false)
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
                            .environment(\.destinationConstructor, addressBook.destinationConstructor)
                            .environment(\.searchActive, searching)
                            .environment(\.visibleAddressPage, visibleAddressPage)
                            .environment(\.visibleAddress, visibleAddress)
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
            .safeAreaInset(edge: .bottom, content: {
                if !(addressBook?.signedIn ?? false) {
                    AuthenticateButton()
                }
            })
        } detail: {
            if let selected {
                tabContent(selected)
            }
        }
        .searchable(text: $searchQuery)
        #if !os(tvOS)
        .searchFocused($searching)
        #endif
    }
    
    @State
    var paths: [NavigationItem: NavigationPath] = .init()
    
    @ViewBuilder
    func tabContent(_ item: NavigationItem) -> some View {
        NavigationStack(path: path(for: item)) {
            navigationContent(item.destination)
                .navigationDestination(for: NavigationDestination.self) { destination in
                    destinationConstructor?.destination(destination)
                }
        }
    }
    
    private var activePath: Binding<NavigationPath> {
        path(for: selected ?? .community)
    }
    private func path(for item: NavigationItem) -> Binding<NavigationPath> {
        .init {
            paths[item] ?? .init()
        } set: { newValue in
            paths.updateValue(newValue, forKey: item)
        }

    }
    
    @ViewBuilder
    func navigationContent(_ destination: NavigationDestination) -> some View {
        destinationConstructor?.destination(destination)
    }
}

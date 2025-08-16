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
    var selected: NavigationItem?
    
    @Environment(\.addressBook)
    var addressBook
    @Environment(\.destinationConstructor)
    var destinationConstructor
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass
    @Environment(\.setAddress)
    var setAddress
    @Environment(\.presentListable)
    var present
    
    @State
    var visibleAddress: AddressName = ""
    @State
    var visibleAddressPage: AddressContent = .profile
    @State
    var presentAccount: Bool = false
    @State var searchQuery: String = ""
    @State var paths: [NavigationItem: NavigationPath] = .init()
    @State var path: NavigationPath = .init()
    @State var presentedPath: NavigationPath = .init()
    
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
                withAnimation(.interpolatingSpring) {
                    if searching && selected != .search {
                        searching = false
                    }
                    paths[cachedSelection] = path
                    cachedSelection = newValue
                    path = paths[newValue] ?? NavigationPath()
                }
            })
            .environment(\.presentListable, { item in
                path.append(item)
            })
            .environment(\.setVisibleAddress, { visible in
                visibleAddress = visible ?? ""
            })
            .environment(\.showAddressPage, { page in
                visibleAddressPage = page
            })
            .environment(\.searchActive, searching)
            .environment(\.visibleAddressPage, visibleAddressPage)
            .environment(\.visibleAddress, visibleAddress)
    }
    
    @ViewBuilder
    var appropriateBody: some View {
        if !Self.usingRegularTabBar(sizeClass: horizontalSizeClass) {
            compactTabBar
            #if os(iOS)
                .tabViewBottomAccessory {
                    PinnedAddressesView(addressBook: addressBook)
                        .id(addressBook.hashValue)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            presentAccount.toggle()
                        }
                        .sheet(isPresented: $presentAccount) {
                            NavigationStack(path: $presentedPath) {
                                navigationContent(.account)
                                    .navigationDestination(for: NavigationDestination.self) { destination in
                                        destinationConstructor?.destination(destination)
                                    }
                            }
                            .environment(\.setAddress, setAddress)
                            .environment(\.presentListable, { listItem in
                                switch listItem {
                                case .safety, .support, .latest:
                                    presentedPath.append(listItem)
                                default:
                                    path.append(listItem)
                                }
                            })
                            .environment(\.addressBook, addressBook)
                        }
                }
            #endif
        } else {
            regularTabBar
        }
    }
    
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
        #endif
    }
        
    @ViewBuilder
    func addressAccessory(_ address: AddressName, showPicker: Bool = true) -> some View {
        HStack {
            AddressIconView(address: address, addressBook: addressBook, contentShape: Circle())
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
    var collapsed: Set<SidebarModel.Section> = [.app]
    
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
                Text("app.lol")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fontDesign(.serif)
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
            .frame(minWidth: 180)
            .safeAreaInset(edge: .bottom, content: {
                if !addressBook.signedIn {
                #if os(macOS)
                    AuthenticateButton()
                        .padding(8)
                #else
                    if selected != .account {
                        AuthenticateButton()
                            .padding(8)
                    }
                #endif
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
    
    @ViewBuilder
    func tabContent(_ item: NavigationItem) -> some View {
        NavigationStack(path: $path) {
            navigationContent(item.destination)
                .background(
                    item.destination.gradient
                )
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
            .environment(\.addressBook, addressBook)
    }
}

struct PinnedAddressesView: View {
    @Environment(\.presentListable) var presentListable
    @Environment(\.setAddress) var set
    @Environment(\.pinAddress) var pin
    @Environment(\.authenticate) var authenticate
    
    let addressBook: AddressBook
    
    @State var addAddress: Bool = false
    @State var address: String = ""
    @State var confirmLogout: Bool = false
    
    init(addressBook: AddressBook) {
        self.addressBook = addressBook
    }
    
    var body: some View {
        HStack(spacing: 2) {
            if addressBook.signedIn {
                Menu {
                    Button(action: {
                        withAnimation { confirmLogout = true }
                    }) {
                        Label {
                            Text("Log out")
                        } icon: {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                        }
                        .bold()
                        .font(.callout)
                        .fontDesign(.serif)
                    }
                    ForEach(addressBook.mine.reversed()) { address in
                        Section(address.addressDisplayString) {
                            Button {
                                withAnimation {
                                    presentListable?(.address(address))
                                }
                            } label: {
                                Label {
                                    Text("Profile")
                                } icon: {
                                    Image(systemName: "person")
                                }
                            }
                            if addressBook.me != address {
                                Button {
                                    withAnimation {
                                        set(address)
                                    }
                                } label: {
                                    Label {
                                        Text("Switch address")
                                    } icon: {
                                        Image(systemName: "shuffle")
                                    }
                                }
                            }
                        }
                    }
                } label: {
                    AddressIconView(address: addressBook.me, addressBook: addressBook, showMenu: false, contentShape: Circle())
                }
                .padding(.top, -1)
                .padding(.leading, 1)
                .alert("Log out?", isPresented: $confirmLogout, actions: {
                    Button("Cancel", role: .cancel) { }
                    Button(
                        "Yes",
                        role: .destructive,
                        action: {
                            authenticate("")
                        })
                }, message: {
                    Text("Are you sure you want to sign out of omg.lol?")
                })
                .contentShape(Rectangle())
            } else {
                OptionsButton()
            }
            VStack(alignment: .leading) {
                if !addressBook.signedIn {
                    Text("Sign in with omg.lol")
                        .font(.caption)
                } else if addressBook.mine.count > 1 {
                    HStack(spacing: 2) {
                        Image(systemName: "person.circle")
                            .font(.caption2)
                        Text("\(addressBook.mine.count)")
                            .font(.caption)
                    }
                }
                if !addressBook.me.isEmpty {
                    AddressNameView(addressBook.me)
                } else {
                    Spacer()
                }
            }
            .padding(4)
            .frame(maxWidth: .infinity, alignment: .leading)
            Menu {
                Section("Pinned") {
                    Button {
                        withAnimation { addAddress.toggle() }
                    } label: {
                        Label {
                            Text("add pin")
                        } icon: {
                            Image(systemName: "plus.circle")
                        }
                    }
                    ForEach(addressBook.pinned) { address in
                        Button {
                            withAnimation {
                                presentListable?(.address(address))
                            }
                        } label: {
                            Label {
                                Text(address.addressDisplayString)
                            } icon: {
                                if address == addressBook.pinned.last {
                                    Image(systemName: "pin")
                                }
                            }
                        }
                    }
                }
                if !addressBook.following.isEmpty {
                    Section("Following") {
                        ForEach(addressBook.following) { address in
                            Button {
                                withAnimation {
                                    presentListable?(.address(address))
                                }
                            } label: {
                                Label {
                                    Text(address.addressDisplayString)
                                } icon: {
                                    if address == addressBook.following.last {
                                        Image(systemName: "binoculars")
                                    }
                                }
                            }
                        }
                    }
                }
                Divider()
            } label: {
                HStack(spacing: 2) {
                    HStack(alignment: .bottom, spacing: -12) {
                        if addressBook.pinned.count > 2 {
                            AddressIconView(address: addressBook.pinned[2], addressBook: addressBook, size: 24, showMenu: false, contentShape: Circle())
                        } else {
                            Image(systemName: "plus.circle.fill")
                                .frame(width: 24, height: 24)
                        }
                        if addressBook.pinned.count > 1 {
                            AddressIconView(address: addressBook.pinned[1], addressBook: addressBook, size: 32, showMenu: false, contentShape: Circle())
                                .padding(.trailing, -4)
                        } else {
                            Image(systemName: "pin.circle.fill")
                                .frame(width: 32, height: 32)
                                .padding(.trailing, -4)
                        }
                        if let firstPin = addressBook.pinned.first {
                            AddressIconView(address: firstPin, addressBook: addressBook, showMenu: false, contentShape: Circle())
                        }
                    }
                    VStack {
                        Image(systemName: "pin.circle")
                        if !addressBook.following.isEmpty {
                            Image(systemName: "person.2.circle")
                        }
                    }
                    .font(.caption2)
                    if !addressBook.pinned.isEmpty || !addressBook.following.isEmpty {
                        VStack(alignment: .leading) {
                            Text("\(addressBook.pinned.count)")
                            if !addressBook.following.isEmpty {
                                Text("\(addressBook.following.count)")
                            }
                        }
                        .font(.caption)
                    }
                }
                .foregroundStyle(Color.primary)
                .animation(.default, value: addressBook.pinned)
                .animation(.default, value: addressBook.following)
                .padding(.trailing, 4)
            }
            .padding(.top, 4)
            .padding(.trailing, 2)
            .alert("Add pinned address", isPresented: $addAddress) {
                TextField("Address", text: $address)
                Button("Cancel") { }
                Button("Add") {
                    addAddress = false
                    pin(address)
                }.disabled(address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(.top, 2)
        .padding(.horizontal, 2)
    }
}

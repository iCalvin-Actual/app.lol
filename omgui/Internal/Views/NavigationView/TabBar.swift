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
    @Environment(\.pinAddress)
    var pin
    
    @State var address: String = ""
    @State var addAddress: Bool = false
    @State var presentAccount: Bool = false
    @State var searchQuery: String = ""
    @State var searchFilter: Set<SearchLanding.SearchFilter> = [.address]
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
    
    var tabModel: NavigationModel {
        .init(addressBook: addressBook)
    }
    
    var body: some View {
        appropriateBody
            .onAppear(perform: {
                if selected == nil {
                    selected = cachedSelection
                }
            })
            .onChange(of: searchQuery) {
                destinationConstructor?.search(searchQuery: searchQuery)
            }
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
                present(item)
            })
            .environment(\.searchActive, searching)
            .environment(\.setSearchFilters, {
                searchFilter = $0
                destinationConstructor?.search(searchFilters: $0)
            })
            .onOpenURL(perform: openURL(_:))
            .alert("Add pinned address", isPresented: $addAddress) {
                TextField("Address", text: $address)
                Button("Cancel") { }
                Button("Add") {
                    addAddress = false
                    pin(address)
                }.disabled(address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
    }
    
    func present(_ destination: NavigationDestination) {
        switch destination {
        case .account:
            presentAccount = true
        default:
            path.append(destination)
        }
    }
    
    func openURL(_ givenURL: URL) {
        switch givenURL.scheme {
        case "app-omg-lol",
            "lol",
            "https://":
            var addressName: AddressName?
            
            // Check unique cases
            let givenHost = givenURL.host
            if givenHost == "omg.lol" || givenHost == "profile.omg.lol" {
                var urlPath = givenURL.pathComponents.first ?? ""
                if urlPath.hasPrefix("@") {
                    urlPath = urlPath.replacingOccurrences(of: "@", with: "")
                } else if urlPath.hasPrefix("~") {
                    urlPath = urlPath.replacingOccurrences(of: "~", with: "")
                }

                guard !urlPath.isEmpty else {
                    present(.community)
                    return
                }
                present(.address(urlPath, page: .profile))
                return
            }
            
            // Determine Address
            if let givenHost {
                let splitComponents = givenHost.components(separatedBy: ".")
                if splitComponents.count == 3 {
                    if givenHost.hasSuffix("status.lol"), let addressName = splitComponents.first {
                        let components = givenURL.pathComponents
                        if components.count > 1, let statusId = components.last {
                            present(.status(addressName, id: statusId))
                        } else {
                            present(.statusLog(addressName))
                        }
                        return
                    } else if givenHost.hasSuffix("url.lol"), let addressName = splitComponents.first {
                        let components = givenURL.pathComponents
                        if components.count > 1, let statusId = components.last {
                            present(.purl(addressName, id: statusId))
                        } else {
                            present(.purls(addressName))
                        }
                        return
                    } else if givenHost.hasSuffix("paste.lol"), let addressName = splitComponents.first {
                        let components = givenURL.pathComponents
                        if components.count > 1, let statusId = components.last {
                            present(.paste(addressName, id: statusId))
                        } else {
                            present(.pastebin(addressName))
                        }
                        return
                    } else if givenHost.hasSuffix("omg.lol") || givenHost.hasSuffix("profile.lol") {
                        addressName = splitComponents.first
                    }
                    guard let addressName else {
                        present(.community)
                        return
                    }
                    if givenURL.path() == "now" {
                        present(.now(addressName))
                        return
                    }
                    present(.address(addressName, page: .profile))
                    return
                }
            }
            
            // Fallback to assuming path is a navigation raw value
            let desiredDestination = NavigationDestination(rawValue: givenURL.lastPathComponent) ?? .support
            
            present(desiredDestination)
        default:
            return
        }
    }
    
    @Environment(\.colorSchemeContrast) var contrast
    @ViewBuilder
    var appropriateBody: some View {
        if !Self.usingRegularTabBar(sizeClass: horizontalSizeClass) {
            compactTabBar
            #if os(iOS)
                .tabViewBottomAccessory {
                    PinnedAddressesView(addAddress: $addAddress)
                        .environment(\.addressBook, addressBook)
                        .id(addressBook.hashValue)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            presentAccount.toggle()
                        }
                        .sheet(isPresented: $presentAccount) {
                            NavigationStack(path: $presentedPath) {
                                navigationContent(.account)
                                    .navigationDestination(for: NavigationDestination.self) { destination in
                                        destinationConstructor?.destination(destination, contrast: contrast)
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
    var collapsed: Set<NavigationModel.Section> = []
    
    func isExpanded(_ section: NavigationModel.Section) -> Binding<Bool> {
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
                ThemedTextView(text: "app", font: .largeTitle, design: .serif, suffix: ".lol")
                    .foregroundStyle(Color.lolAccent)
                
                // Sections from NavigationModel
                Section {
                    ForEach(tabModel.items(for: NavigationModel.Section.more, sizeClass: .regular, context: .column), id: \.self) { item in
                        NavigationLink(value: item) {
                            Label(item.displayString, systemImage: item.iconName)
                        }
                    }
                }
                Section {
                    ForEach(tabModel.items(for: NavigationModel.Section.app, sizeClass: .regular, context: .column), id: \.self) { item in
                        NavigationLink(value: item) {
                            Label(item.displayString, systemImage: item.iconName)
                        }
                    }
                }
                Section(isExpanded: isExpanded(.directory)) {
                    Button {
                        withAnimation { addAddress.toggle() }
                    } label: {
                        Label {
                            Text("Add pin")
                        } icon: {
                            Image(systemName: "plus.circle")
                        }
                    }
                    ForEach(tabModel.items(for: NavigationModel.Section.directory, sizeClass: .regular, context: .column), id: \.self) { item in
                        NavigationLink(value: item) {
                            if item == tabModel.items(for: .directory, sizeClass: .regular, context: .column).first {
                                Label(item.displayString, systemImage: item.iconName)
                            } else {
                                Label {
                                    Text(item.displayString)
                                } icon: {
                                    Image(systemName: "pin")
                                        .opacity(0)
                                }
                            }
                        }
                    }
                } header: {
                    Label("pinned", systemImage: "pin")
                        .foregroundStyle(.secondary)
                }
            }
            .frame(minWidth: 180)
            .safeAreaInset(edge: .bottom) {
                PinnedAddressesView(addAddress: $addAddress)
                    .environment(\.addressBook, addressBook)
                    .frame(maxHeight: 44)
                    .glassEffect(.regular, in: .capsule)
                    .id(addressBook.hashValue)
                    .onTapGesture {
                        selected = .account
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
            }
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
    
    @ViewBuilder
    func tabContent(_ item: NavigationItem) -> some View {
        NavigationStack(path: $path) {
            navigationContent(item.destination)
                .navigationDestination(for: NavigationDestination.self) { destination in
                    destinationConstructor?.destination(destination, contrast: contrast)
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
        destinationConstructor?.destination(destination, contrast: contrast)
            .environment(\.addressBook, addressBook)
    }
}

struct PinnedAddressesView: View {
    @Environment(\.presentListable) var presentListable
    @Environment(\.setAddress) var set
    @Environment(\.pinAddress) var pin
    @Environment(\.authenticate) var authenticate
    
    @Binding var addAddress: Bool
    
    @State var confirmLogout: Bool = false
    
    @SceneStorage("lol.highlightFollows") var highlightFollows: Bool = true
    
    var shouldHighlightFollows: Bool {
        highlightFollows && addressBook.signedIn && !addressBook.following.isEmpty
    }
    
    var highlights: [AddressName] {
        shouldHighlightFollows ? addressBook.following : addressBook.pinned
    }
    
    @State
    var hasShownLoginPrompt: Bool = false
    
    @Environment(\.addressBook)
    var addressBook
    
    init(addAddress: Binding<Bool>) {
        self._addAddress = addAddress
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
                    ForEach(addressBook.mine.sorted().reversed()) { address in
                        Section(address.addressDisplayString) {
                            Button {
                                withAnimation {
                                    presentListable?(.address(address, page: .profile))
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
                                        Text("Use address")
                                    } icon: {
                                        Image(systemName: "shuffle")
                                    }
                                }
                            }
                        }
                    }
                } label: {
                    AddressIconView(address: addressBook.me, showMenu: false, contentShape: Circle())
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
                    .foregroundStyle(.secondary)
            }
            VStack(alignment: .leading) {
                if !addressBook.signedIn && !hasShownLoginPrompt {
                    HStack {
                        Image(systemName: "key")
                            .font(.caption2)
                        Text("Sign in with omg.lol")
                            .font(.caption)
                    }
                    .foregroundStyle(.tint)
                    .animation(.default, value: hasShownLoginPrompt)
                    .task {
                        try? await Task.sleep(nanoseconds: 2000)
                        withAnimation {
                            hasShownLoginPrompt = true
                        }
                    }
                } else if addressBook.mine.count > 1 {
                    HStack(spacing: 2) {
                        Image(systemName: "person.circle")
                            .bold()
                            .font(.caption2)
                        Text("\(addressBook.mine.count)")
                            .bold()
                            .font(.caption)
                    }
                    .foregroundStyle(.tint)
                }
                if !addressBook.me.isEmpty {
                    AddressNameView(addressBook.me)
                        .foregroundStyle(.primary)
                } else {
                    Spacer()
                }
            }
            .padding(4)
            .frame(maxWidth: .infinity, alignment: .leading)
            Menu {
                Button {
                    withAnimation { addAddress.toggle() }
                } label: {
                    Label {
                        Text("Add pin")
                    } icon: {
                        Image(systemName: "plus.circle")
                    }
                }
                if addressBook.following.isEmpty {
                    Menu {
                        ForEach(addressBook.following) { address in
                            Button {
                                withAnimation {
                                    presentListable?(.address(address, page: .profile))
                                }
                            } label: {
                                Text(address.addressDisplayString)
                            }
                        }
                    } label: {
                        Label("Following", systemImage: "binoculars")
                    }
                }
                Section("Pins") {
                    ForEach(addressBook.pinned) { address in
                        Button {
                            withAnimation {
                                presentListable?(.address(address, page: .profile))
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
                Divider()
                if !addressBook.following.isEmpty {
                    Menu {
                        Button {
                            highlightFollows = true
                        } label: {
                            Label("Follows", systemImage: shouldHighlightFollows ? "checkmark" : "binoculars")
                                .bold(shouldHighlightFollows)
                        }
                        .bold(shouldHighlightFollows)
                        .disabled(!addressBook.signedIn)
                        Button {
                            highlightFollows = false
                        } label: {
                            Label("Pinned", systemImage: shouldHighlightFollows ? "pin" : "checkmark")
                        }
                        .bold(shouldHighlightFollows)
                    } label: {
                        Label("Highlight", systemImage: "star")
                    }
                }
            } label: {
                HStack(spacing: 2) {
                    HStack(alignment: .bottom, spacing: -12) {
                        if highlights.count > 2 {
                            AddressIconView(address: highlights[2], size: 24, showMenu: false, contentShape: Circle())
                        }
                        if highlights.count > 1 {
                            AddressIconView(address: highlights[1], size: 32, showMenu: false, contentShape: Circle())
                                .padding(.trailing, -4)
                        }
                        if let firstPin = highlights.first {
                            AddressIconView(address: firstPin, size: 36, showMenu: false, contentShape: Circle())
                        }
                    }
                    VStack {
                        if addressBook.following.isEmpty {
                            if addressBook.pinned.count == 0 {
                                Image(systemName: "pin.circle")
                                    .font(.body)
                                    .bold()
                                    .foregroundStyle(Color.lolAccent)
                            } else if addressBook.pinned.count > 2 {
                                Image(systemName: "pin.circle")
                                    .bold()
                                    .foregroundStyle(Color.lolAccent)
                            }
                        } else {
                            Image(systemName: "pin.circle")
                                .bold(!shouldHighlightFollows)
                                .foregroundStyle(shouldHighlightFollows ? Color.primary : Color.lolAccent)
                            Image(systemName: "person.2.circle")
                                .bold(shouldHighlightFollows)
                                .foregroundStyle(shouldHighlightFollows ? Color.lolAccent : Color.primary)
                        }
                    }
                    .font(.caption2)
                    if addressBook.pinned.count > 2 || !addressBook.following.isEmpty {
                        VStack(alignment: .leading) {
                            Text("\(addressBook.pinned.count)")
                                .bold(!shouldHighlightFollows)
                                .foregroundStyle(shouldHighlightFollows ? Color.primary : Color.lolAccent)
                            if !addressBook.following.isEmpty {
                                Text("\(addressBook.following.count)")
                                    .bold(shouldHighlightFollows)
                                    .foregroundStyle(shouldHighlightFollows ? Color.lolAccent : Color.primary)
                            }
                        }
                        .font(.caption)
                    }
                }
                .foregroundStyle(Color.secondary)
                .animation(.default, value: addressBook.pinned)
                .animation(.default, value: addressBook.following)
                .padding(.trailing, 4)
            }
            .padding(.trailing, 2)
        }
        .padding(.top, 2)
        .padding(.horizontal, 2)
    }
}

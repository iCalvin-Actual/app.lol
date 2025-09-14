//
//  SceneNavigation.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/14/25.
//

import SwiftUI

struct SceneNavigationView: View {
    
    @SceneStorage("app.tab.selected")
    var cachedSelection: NavigationItem = NavigationModel.initial
    
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
    @State var searchFilter: Set<SearchView.SearchFilter> = []
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
        case .address(let address, _):
            selected = .pinnedAddress(address)
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
                    present(NavigationModel.initial.destination)
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
                        present(NavigationModel.initial.destination)
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
        if .usingRegularTabBar(sizeClass: horizontalSizeClass) {
            regularNavigation
        } else {
            compactNavigaion
        }
    }
    
    @ViewBuilder
    var compactNavigaion: some View {
        TabbedNavigationView(
            selected: $selected,
            tabModel: tabModel,
            tabContent: tabContent(_:)
        )
        .searchable(text: $searchQuery)
#if !os(tvOS)
        .searchFocused($searching)
#endif
#if os(iOS)
        .tabBarMinimizeBehavior(.onScrollDown)
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
    }
    
    @ViewBuilder
    var regularNavigation: some View {
        SplitNavigationView(
            selected: $selected,
            addAddress: $addAddress,
            tabModel: tabModel,
            tabContent: tabContent(_:)
        )
        .searchable(text: $searchQuery)
        #if !os(tvOS)
        .searchFocused($searching)
        #endif
    }
    
    @ViewBuilder
    private func tabContent(_ item: NavigationItem) -> some View {
        NavigationStack(path: $path) {
            navigationContent(item.destination)
                .navigationDestination(for: NavigationDestination.self) { destination in
                    destinationConstructor?.destination(destination, contrast: contrast)
                }
        }
        .id(item.id)
    }
    
    
    private var activePath: Binding<NavigationPath> {
        path(for: selected ?? NavigationModel.initial)
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
    private func navigationContent(_ destination: NavigationDestination) -> some View {
        destinationConstructor?.destination(destination, contrast: contrast)
            .environment(\.addressBook, addressBook)
    }
}

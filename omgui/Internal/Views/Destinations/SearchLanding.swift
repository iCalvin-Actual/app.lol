//
//  SearchLanding.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 6/19/25.
//

import SwiftUI

struct SearchLanding: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.isSearching) var searching
    @Environment(\.searchActive) var searchActive
    
    enum SearchFilter {
        case address
        case status
        case now
        case photo
    }

    func gridColumns(_ width: CGFloat) -> [GridItem] {
        if TabBar.usingRegularTabBar(sizeClass: horizontalSizeClass, width: width) {
            return Array(repeating: GridItem(.flexible()), count: 4)
        } else {
            return Array(repeating: GridItem(.flexible()), count: 2)
        }
    }
    
    let viewModel: AccountViewModel
    
    @State
    var filter: SearchFilter? = nil
    
    var usingCompact: Bool {
        TabBar.usingRegularTabBar(sizeClass: horizontalSizeClass)
    }
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                LazyVStack(pinnedViews: [.sectionHeaders, .sectionFooters]) {
                    Section {
                        ForEach(0..<128) { _ in
                            HStack {
                                Text("Some result")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    } header: {
                        headerToUse(proxy.size.width)
                    } footer: {
                        footerToUse(proxy.size.width)
                    }
                }
                .padding(.horizontal, 8)
            }
#if !os(tvOS)
            .scrollContentBackground(.hidden)
#endif
            .animation(.default, value: viewModel.pinned)
        }
    }
    
    @ViewBuilder
    func headerToUse(_ width: CGFloat) -> some View {
        if TabBar.usingRegularTabBar(sizeClass: horizontalSizeClass, width: width) {
            buttonGrid(width)
                .padding(.horizontal, 8)
        } else {
            VStack {
                if !searching {
                    pinnedItems
                }
                buttonGrid(width)
                    .padding(.horizontal, 8)
            }
        }
    }
    
    @ViewBuilder
    func footerToUse(_ width: CGFloat) -> some View {
        if TabBar.usingRegularTabBar(sizeClass: horizontalSizeClass, width: width) {
            if !searching {
                pinnedItems
            }
        }
    }
    
    @ViewBuilder
    var pinnedItems: some View {
        if viewModel.showPinned && filter == nil {
            VStack(spacing: 0) {
                Label {
                    Text("Pinned")
                } icon: {
                    Image(systemName: "pin")
                }
                .foregroundStyle(.secondary)
                .font(.callout)
                .padding(.leading, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 0) {
                        ForEach(viewModel.pinned) { address in
                            AddressCard(address, embedInMenu: true)
                                .frame(maxWidth: 88)
                        }
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.top, 16)
            .background(Material.thin, in: .rect(cornerRadius: .init(16), style: .continuous))
            .padding(.horizontal, 12)
        }
    }

    @ViewBuilder
    func buttonGrid(_ width: CGFloat) -> some View {
        LazyVGrid(columns: gridColumns(width), spacing: 8) {
            Button(action : {
                toggle(.address)
            }, label: {
                Label {
                    Text("Directory")
                } icon: {
                    Image(systemName: "at")
                }
            })
            .buttonStyle(SearchNavigationButtonStyle(selected: filter == .address))
            Button(action : {
                toggle(.status)
            }, label: {
                Label {
                    Text("StatusLog")
                } icon: {
                    Image(systemName: "star.bubble")
                }
            })
            .buttonStyle(SearchNavigationButtonStyle(selected: filter == .status))
            Button(action : {
                toggle(.now)
            }, label: {
                Label {
                    Text("NowGarden")
                } icon: {
                    Image(systemName: "sun.horizon")
                }
            })
            .buttonStyle(SearchNavigationButtonStyle(selected: filter == .now))
            Button(action : {
                toggle(.photo)
            }, label: {
                Label {
                    Text("Photos")
                } icon: {
                    Image(systemName: "person.crop.square")
                }
            })
            .buttonStyle(SearchNavigationButtonStyle(selected: filter == .photo))
        }
        .labelStyle(SearchNavigationLabelStyle())
    }
    
    private func toggle(_ toApply: SearchFilter) {
        withAnimation {
            if filter != toApply {
                filter = toApply
            } else {
                filter = nil
            }
        }
    }
}

struct SearchNavigationLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
                .padding(4)
            configuration.title
        }
        .foregroundStyle(.secondary)
    }
}

struct SearchNavigationButtonStyle: ButtonStyle {
    let selected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .lineLimit(1)
            .bold(selected)
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(selected ? .white : .primary)
            .frame(minHeight: 44)
            .contentShape(Capsule())
        #if !os(visionOS)
            .glassEffect(glass)
        #endif
    }
    
    var glass: Glass {
        if selected {
            return .regular.tint(Color.accentColor)
        }
        return .regular
    }
}

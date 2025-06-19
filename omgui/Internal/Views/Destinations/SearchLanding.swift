//
//  SearchLanding.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 6/19/25.
//

import SwiftUI

struct SearchLanding: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var gridColumns: [GridItem] {
        if horizontalSizeClass == .regular {
            return Array(repeating: GridItem(.flexible()), count: 4)
        } else {
            return Array(repeating: GridItem(.flexible()), count: 2)
        }
    }
    
    @ObservedObject
    var viewModel: ListsViewModel
    
    init(sceneModel: SceneModel) {
        viewModel = .init(sceneModel: sceneModel)
    }

    var body: some View {
        List {
            if viewModel.showPinned {
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: 0) {
                            ForEach(viewModel.pinned) { address in
                                AddressCard(address, embedInMenu: true)
                                    .frame(maxWidth: 88)
                            }
                            Spacer()
                        }
                    }
                    .background(Material.regular)
                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: 12, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 12, style: .continuous))
                } header: {
                    Label {
                        Text("pinned")
                    } icon: {
                        Image(systemName: "pin")
                    }
                    .foregroundStyle(.secondary)
                    .font(.callout)
                    .padding(.horizontal, 10)
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .listRowSeparator(.hidden)
                }
                .frame(maxWidth: .infinity)
                .background(Material.ultraThin)
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(Color.clear)
            } else {
                Label(title: {
                    Text("pin addresses here for later")
                }) {
                    Image(systemName: "pin")
                }
                .foregroundStyle(.primary)
                .listRowBackground(Color(UIColor.systemBackground).opacity(0.82))
            }
            LazyVGrid(columns: gridColumns, spacing: 16) {
                Button(action : { }, label: {
                    Label {
                        Text("Directory")
                    } icon: {
                        Image(systemName: "at")
                    }
                })
                Button(action : { }, label: {
                    Label {
                        Text("StatusLog")
                    } icon: {
                        Image(systemName: "star.bubble")
                    }
                })
                Button(action : { }, label: {
                    Label {
                        Text("NowGarden")
                    } icon: {
                        Image(systemName: "sun.horizon")
                    }
                })
                Button(action : { }, label: {
                    Label {
                        Text("Photos")
                    } icon: {
                        Image(systemName: "person.crop.square")
                    }
                })
            }
            .buttonStyle(SearchNavigationButtonStyle())
            .labelStyle(SearchNavigationLabelStyle())
        }
        .animation(.default, value: viewModel.pinned)
    }
}

struct SearchNavigationLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.icon
                .padding(4)
            configuration.title
        }
    }
}

struct SearchNavigationButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .foregroundColor(.primary)
            .glassEffect()
    }
}

#Preview {
    SearchLanding(sceneModel: .sample)
        .background(NavigationDestination.about.gradient)
}

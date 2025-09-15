//
//  Sidebar.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/14/25.
//

import SwiftUI


struct Sidebar: View {
    @State
        var collapsed: Set<NavigationModel.Section> = []
    
    @Binding
        var selected: NavigationItem?
    @Binding
        var addAddress: Bool
    
    let navigationModel: NavigationModel
    
    var body: some View {
        List(selection: $selected) {
            ThemedTextView(text: "app", font: .largeTitle, design: .serif, suffix: ".lol")
                .foregroundStyle(Color.lolAccent)
            
            // Sections from NavigationModel
            Section {
                ForEach(navigationModel.items(for: .more, sizeClass: .regular, context: .column), id: \.self) { item in
                    NavigationLink(value: item) {
                        Label(item.displayString, systemImage: item.iconName)
                    }
                }
            }
            Section {
                ForEach(navigationModel.items(for: .app, sizeClass: .regular, context: .column), id: \.self) { item in
                    NavigationLink(value: item) {
                        Label(item.displayString, systemImage: item.iconName)
                    }
                }
            }
            Section(isExpanded: isExpanded(.directory)) {
                ForEach(navigationModel.items(for: NavigationModel.Section.directory, sizeClass: .regular, context: .column), id: \.self) { item in
                    NavigationLink(value: item) {
                        if item == navigationModel.items(for: .directory, sizeClass: .regular, context: .column).first {
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
                addPinButton
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            } header: {
                Label("pinned", systemImage: "pin")
                    .foregroundStyle(.secondary)
            }
        }
#if os(iOS)
        .frame(minWidth: 180)
#elseif os(visionOS)
        .clipShape(ConcentricRectangle())
        .background(Material.regular)
#else
        .frame(minWidth: 250)
#endif
        .safeAreaInset(edge: .bottom) {
            glassAccessoryIfAvailable()
                .environment(\.addressBook, addressBook)
                .frame(maxHeight: 44)
#if os(visionOS)
                .transform3DEffect(
                    .init(
                        translation: .init(
                            x: 0,
                            y: 0,
                            z: 6
                        )
                    )
                )
                .padding(2)
                .background(Material.regular)
                .clipShape(Capsule())
#endif
                .id(addressBook.hashValue)
                .onTapGesture {
                    selected = .account
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
        }
    }
    
    @ViewBuilder
    var addPinButton: some View {
        Button {
            withAnimation { addAddress.toggle() }
        } label: {
            Label {
                Text("Add pin")
            } icon: {
                Image(systemName: "plus.circle")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    @ViewBuilder
    func glassAccessoryIfAvailable() -> some View {
        if #available(iOS 26.0, *) {
            AccountAccessoryView(addAddress: $addAddress)
#if !os(visionOS)
                .glassEffect(.regular, in: .capsule)
#endif
        } else {
            AccountAccessoryView(addAddress: $addAddress)
        }
    }
    
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
    
    
    
    @Environment(\.addressBook)
        var addressBook
}

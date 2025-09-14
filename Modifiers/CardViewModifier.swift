//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 5/7/23.
//

import SwiftUI

private struct CardViewModifier: ViewModifier {
    @Environment(\.colorScheme) 
    var colorScheme
    @Environment(\.colorSchemeContrast)
    var contrast
    @Environment(\.isFocused) var focused: Bool
    
    let material: Material
    let padding: CGFloat
    let radius: CGFloat
    let selected: Bool
    let pullIn: Bool
    
    var emphasis: Bool {
        focused || selected
    }
    
    let background: Gradient?
    
    init(destination: NavigationDestination?, material: Material = .ultraThin, padding: CGFloat, radius: CGFloat, selected: Bool, pullIn: Bool = false) {
        self.background = destination?.gradient
        self.material = material
        self.padding = padding
        self.radius = radius
        self.selected = selected
        self.pullIn = pullIn
    }
    
    var shadowPadding: CGFloat { padding / 2 }
    
    @ViewBuilder
    func backgroundIfNeeded<V: View>(_ content: V) -> some View {
#if os(visionOS)
        content
            .background(contrast == .increased ? Material.thick.opacity(100) : Material.regular.opacity(100))
#else
        if let background {
            content
                .background(colorScheme == .dark ? Material.ultraThin.opacity(100) : Material.ultraThin.opacity(0))
                .background(background.inverted())
        } else {
            content
                .background(contrast == .increased ? Material.thick.opacity(100) : Material.regular.opacity(100))
        }
#endif
    }
    
    func body(content: Content) -> some View {
        backgroundIfNeeded(
            content
                .frame(maxWidth: .infinity)
#if os(visionOS)
                .transform3DEffect(
                    .init(
                        translation: .init(
                            x: 0,
                            y: 0,
                            z: emphasis ? 12 : 6
                        )
                    )
                )
#endif
        )
        .cornerRadius(radius)
        .padding(.horizontal, padding / 2)
        .padding(.vertical, pullIn ? shadowPadding / 2 : shadowPadding)
        .shadow(color: selected ? .black.opacity(0.8) : .secondary.opacity(colorScheme == .dark ? 0 : 0.5), radius: shadowPadding / 2)
    }
}

@MainActor
extension HStack {
    func asCard(destination: NavigationDestination? = nil, material: Material = .thin, padding: CGFloat = 4, radius: CGFloat = 2, selected: Bool = false, pullIn: Bool = false) -> some View {
        self.modifier(CardViewModifier(destination: destination, material: material, padding: padding, radius: radius, selected: selected, pullIn: pullIn))
    }
}
@MainActor
extension VStack {
    func asCard(destination: NavigationDestination? = nil, material: Material = .thin, padding: CGFloat = 4, radius: CGFloat = 2, selected: Bool = false, pullIn: Bool = false) -> some View {
        self.modifier(CardViewModifier(destination: destination, material: material, padding: padding, radius: radius, selected: selected, pullIn: pullIn))
    }
}
@MainActor
extension View {
    func asCard(destination: NavigationDestination? = nil, material: Material = .thin, padding: CGFloat = 4, radius: CGFloat = 2, selected: Bool = false, pullIn: Bool = false) -> some View {
        HStack {
            self
            Spacer(minLength: 0)
        }
        .asCard(destination: destination, material: material, padding: padding, radius: radius, selected: selected, pullIn: pullIn)
    }
}

struct CardViewModifier_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            Text("Some")
                .font(.title)
            
            Spacer()
            
            Image(systemName: "tree.fill")
        }
        .asCard()
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.lolBackground)
    }
}

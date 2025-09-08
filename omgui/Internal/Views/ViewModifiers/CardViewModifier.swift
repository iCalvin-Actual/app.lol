//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 5/7/23.
//

import SwiftUI

struct CardViewModifier: ViewModifier {
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
    
    init(material: Material = .ultraThin, padding: CGFloat, radius: CGFloat, selected: Bool, pullIn: Bool = false) {
        self.material = material
        self.padding = padding
        self.radius = radius
        self.selected = selected
        self.pullIn = pullIn
    }
    
    var shadowPadding: CGFloat { selected ? padding : padding / 2 }
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .background(contrast == .increased ? Material.thick : material)
            .cornerRadius(radius)
            .padding(.horizontal, shadowPadding)
            .padding(.vertical, pullIn ? shadowPadding / 2 : shadowPadding)
            .shadow(color: .secondary.opacity(0.5), radius: shadowPadding / 2)
    }
}

@MainActor
extension HStack {
    func asCard(material: Material = .thin, padding: CGFloat = 4, radius: CGFloat = 2, selected: Bool = false, pullIn: Bool = false) -> some View {
        self.modifier(CardViewModifier(material: material, padding: padding, radius: radius, selected: selected, pullIn: pullIn))
    }
}
@MainActor
extension VStack {
    func asCard(material: Material = .thin, padding: CGFloat = 4, radius: CGFloat = 2, selected: Bool = false, pullIn: Bool = false) -> some View {
        self.modifier(CardViewModifier(material: material, padding: padding, radius: radius, selected: selected, pullIn: pullIn))
    }
}
@MainActor
extension View {
    func asCard(material: Material = .thin, padding: CGFloat = 4, radius: CGFloat = 2, selected: Bool = false, pullIn: Bool = false) -> some View {
        HStack {
            self
            Spacer(minLength: 0)
        }
        .asCard(material: material, padding: padding, radius: radius, selected: selected, pullIn: pullIn)
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

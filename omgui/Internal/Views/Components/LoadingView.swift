//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 6/9/24.
//

import SwiftUI

struct LoadingView: View {
    enum Style {
        case standard
        case horizontal
    }
    
    let style: Style
    
    init(_ style: Style = .horizontal) {
        self.style = style
    }
    
    var body: some View {
        content
#if !os(tvOS)
            .listRowSeparator(.hidden)
        #endif
    }
    
    @ViewBuilder
    var content: some View {
        switch style {
        case .standard:
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(2.0, anchor: .center)
                    .tint(.lolAccent)
                ThemedTextView(text: "loading...")
            }
            .padding(4)
        case .horizontal:
            HStack(alignment: .lastTextBaseline, spacing: 16) {
                Spacer()
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(2.0, anchor: .center)
                    .tint(.lolAccent)
                ThemedTextView(text: "loading...")
                Spacer()
            }
            .frame(maxHeight: 61.33)
        }
    }
}

#Preview {
    LoadingView()
}

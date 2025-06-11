//
//  File.swift
//
//
//  Created by Calvin Chestnut on 3/8/23.
//

import MarkdownUI
import SwiftUI

struct StatusRowView: View {
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    @State
    var showURLs: Bool = false
    @State
    var presentUrl: URL?
    
    @State
    var destination: NavigationDestination?
    @GestureState 
    private var zoom = 1.0
    
    let model: StatusModel
    @Environment(\.viewContext)
    var context: ViewContext
    
    
    let cardColor: Color
    let cardPadding: CGFloat
    let cardradius: CGFloat
    let showSelection: Bool
    
    init(model: StatusModel, cardColor: Color? = nil, cardPadding: CGFloat = 8, cardradius: CGFloat = 16, showSelection: Bool = false) {
        self.model = model
        self.cardColor = cardColor ?? .lolRandom(model.displayEmoji)
        self.cardPadding = cardPadding
        self.cardradius = cardradius
        self.showSelection = showSelection
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            buttonIfNeeded
                .padding(4)
                .padding(.horizontal, 4)
                .padding(.top, 6)
            
            rowBody
                .foregroundStyle(Color.black)
                .asCard(color: cardColor, material: .regular, padding: cardPadding, radius: cardradius)
        }
        .asCard(color: cardColor, padding: 0, radius: cardradius, selected: showSelection || context == .detail)
        .sheet(item: $destination, content: { destination in
            NavigationStack {
                sceneModel.destinationConstructor.destination(destination)
            }
        })
        .confirmationDialog("Open Image", isPresented: $showURLs, actions: {
            ForEach(model.imageLinks) { link in
                Button {
                    presentUrl = link.content
                } label: {
                    Text(link.name)
                }
            }
        })
        .sheet(item: $presentUrl) { url in
            AsyncImage(url: url) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(zoom)
                    .gesture(
                        MagnifyGesture()
                            .updating($zoom) { value, gestureState, transaction in
                                gestureState = value.magnification
                            }
                    )
            } placeholder: {
                ThemedTextView(text: "Loading image...")
            }
        }
    }
    
    @ViewBuilder
    var rowBody: some View {
        VStack(alignment: .leading, spacing: 2) {
            /*
             This was tricky to set up
             so I'm leaving it here
             
//                    Text(model.displayEmoji)
//                        .font(.system(size: 44))
//                    + Text(" ").font(.largeTitle) +
             */
            appropriateMarkdown
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .environment(\.colorScheme, .light)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .lineLimit(context == .column ? 5 : nil)
        .multilineTextAlignment(.leading)
    }
    
    @ViewBuilder
    var appropriateMarkdown: some View {
        Markdown(model.displayStatus)
    }
    
    @ViewBuilder
    var buttonIfNeeded: some View {
        if context == .detail  {
            NavigationLink(value: NavigationDestination.address(model.address), label: { headerContent })
        } else {
            headerContent
        }
    }
    
    @ViewBuilder
    var headerContent: some View {
        ZStack(alignment: .topTrailing) {
            HStack(alignment: .bottom, spacing: 0) {
                if context != .profile {
                    AddressIconView(address: model.address)
                        .padding(.horizontal, 4)
                }
                Text(model.displayEmoji.count > 1 ? "✨" : model.displayEmoji.prefix(1))
                    .font(.system(size: 35))
                if context != .profile {
                    AddressNameView(model.address, font: .headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Spacer()
                }
            }
            if let caption = context != .detail ? DateFormatter.relative.string(for: model.date) ?? model.listCaption : model.listCaption {
                Text(caption)
                    .multilineTextAlignment(.trailing)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .truncationMode(.head)
            }
        }
    }
}

#Preview {
    VStack {
        Spacer()
        StatusRowView(model: .sample(with: "app"))
            .environment(\.viewContext, ViewContext.column)
        StatusRowView(model: .sample(with: "alexcox"))
            .environment(\.viewContext, ViewContext.profile)
        StatusRowView(model: .sample(with: "app"))
            .environment(\.viewContext, ViewContext.detail)
        Spacer()
    }
    .environment(SceneModel.sample)
    .padding(.horizontal)
}

//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 4/26/23.
//

import SwiftUI

struct PURLView: View {
    @Environment(\.dismiss)
    var dismiss
    @Environment(\.horizontalSizeClass)
    var sizeClass
    @Environment(\.viewContext)
    var viewContext
    
    @Environment(\.viewContext)
    var context: ViewContext
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    
    @ObservedObject
    var fetcher: AddressPURLDataFetcher
    
    @State
    var showDraft: Bool = false
    @State
    var detent: PresentationDetent = .draftDrawer
    
    @State
    var presented: URL? = nil
    
    var body: some View {
        content
            .onChange(of: fetcher.address, {
                Task { [fetcher] in
                    await fetcher.updateIfNeeded(forceReload: true)
                }
            })
            .onChange(of: fetcher.title, {
                Task { [fetcher] in
                    await fetcher.updateIfNeeded(forceReload: true)
                }
            })
            .onAppear {
                Task { [fetcher] in
                    await fetcher.updateIfNeeded()
                }
            }
            .toolbar {
                if viewContext != .profile {
                    ToolbarItem(placement: .principal) {
                        AddressNameView(fetcher.address, suffix: "/purls")
                    }
                }
////                ToolbarItem(placement: .topBarTrailing) {
////                    if fetcher.draftPoster != nil {
////                        Menu {
////                            Button {
////                                withAnimation {
////                                    if detent == .large {
////                                        detent = .draftDrawer
////                                    } else if showDraft {
////                                        detent = .large
////                                    } else if !showDraft {
////                                        detent = .medium
////                                        showDraft = true
////                                    } else {
////                                        showDraft = false
////                                        detent = .draftDrawer
////                                    }
////                                }
////                            } label: {
////                                Text("edit")
////                            }
////                            Menu {
////                                Button(role: .destructive) {
////                                    Task {
////                                        try await fetcher.deleteIfPossible()
////                                    }
////                                } label: {
////                                    Text("confirm")
////                                }
////                            } label: {
////                                Label {
////                                    Text("delete")
////                                } icon: {
////                                    Image(systemName: "trash")
////                                }
////                            }
////                        } label: {
////                            Image(systemName: "ellipsis.circle")
////                        }
////                    }
////                }
                ToolbarItem(placement: .topBarTrailing) {
                    if let purlURL = fetcher.result?.purlURL {
                        Menu {
                            ShareLink("share purl", item: purlURL)
                            Divider()
                            Button(action: {
                                UIPasteboard.general.string = purlURL.absoluteString
                            }, label: {
                                Label(
                                    title: { Text("copy purl") },
                                    icon: { Image(systemName: "doc.on.clipboard") }
                                )
                            })
                            if let shareItem = fetcher.result?.content {
                                Button(action: {
                                    UIPasteboard.general.string = shareItem
                                }, label: {
                                    Label(
                                        title: { Text("copy destination") },
                                        icon: { Image(systemName: "link") }
                                    )
                                })
                            }
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
//            .onReceive(fetcher.$result, perform: { model in
//                withAnimation {
//                    let address = model?.addressName ?? ""
//                    guard !address.isEmpty, sceneModel.addressBook.myAddresses.contains(address) else {
//                        showDraft = false
//                        return
//                    }
//                    if model == nil && fetcher.title.isEmpty {
//                        detent = .large
//                        showDraft = true
//                    } else if model != nil {
//                        detent = .draftDrawer
//                        showDraft = true
//                    } else {
//                        print("Stop")
//                    }
//                }
//            })
    }
    
    @ViewBuilder
    var draftView: some View {
//        if let poster = fetcher.draftPoster {
//            PURLDraftView(draftFetcher: poster)
//        }
        EmptyView()
    }
    
//    @ViewBuilder
//    func mainContent(_ poster: PURLDraftPoster?) -> some View {
//        if let poster {
//            content
//                .onReceive(poster.$result.dropFirst(), perform: { savedResult in
//                print("Stop here")
//            })
//        } else {
//            content
//        }
//    }
    
    @ViewBuilder
    var content: some View {
        preview
            .safeAreaInset(edge: .top) {
                if let model = fetcher.result {
                    PURLRowView(model: model, cardColor: .lolRandom(model.listTitle), cardPadding: 8, cardradius: 16, showSelection: true)
                        .padding()
                }
            }
    }
    
    @ViewBuilder
    var preview: some View {
        if let content = fetcher.result?.content, let url = URL(string: content) {
            RemoteHTMLContentView(activeAddress: fetcher.address, startingURL: url, activeURL: $presented, scrollEnabled: .constant(true))
        } else {
            Spacer()
        }
    }
    
    @ViewBuilder
    var pathInfo: some View {
        if context != .profile {
            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    AddressIconView(address: fetcher.address)
                    Text("/\(fetcher.result?.name ?? fetcher.title)")
                        .font(.title2)
                        .fontDesign(.serif)
                        .foregroundStyle(Color.primary)
                        .multilineTextAlignment(.leading)
                }
                
                if let destination = fetcher.result?.content, !destination.isEmpty {
                    Text(destination)
                        .textSelection(.enabled)
                        .font(.caption)
                        .fontDesign(.rounded)
                        .multilineTextAlignment(.leading)
                }
            }
            .lineLimit(3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Material.thin)
            .cornerRadius(10)
            .padding()
            .background(Color.clear)
        }
    }
}

#Preview {
    let sceneModel = SceneModel.sample
    let purlFetcher = AddressPURLDataFetcher(name: "app", title: "privacy", interface: SampleData(), db: sceneModel.database)
    NavigationStack {
        PURLView(fetcher: purlFetcher)
    }
    .environment(sceneModel)
}

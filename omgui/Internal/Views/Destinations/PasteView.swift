//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 4/26/23.
//

import SwiftUI

struct PasteView: View {
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
    var fetcher: AddressPasteDataFetcher
    
    @State
    var showDraft: Bool = false
    @State
    var detent: PresentationDetent = .draftDrawer
    
    var body: some View {
        mainContent
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
            .toolbar {
//                ToolbarItem(placement: .topBarTrailing) {
//                    if fetcher.draftPoster != nil {
//                        Menu {
//                            Button {
//                                withAnimation {
//                                    if detent == .large {
//                                        detent = .draftDrawer
//                                    } else if showDraft {
//                                        detent = .large
//                                    } else if !showDraft {
//                                        detent = .medium
//                                        showDraft = true
//                                    } else {
//                                        showDraft = false
//                                        detent = .draftDrawer
//                                    }
//                                }
//                            } label: {
//                                Text("edit")
//                            }
//                            Menu {
//                                Button(role: .destructive) {
//                                    Task {
//                                        try await fetcher.deleteIfPossible()
//                                    }
//                                } label: {
//                                    Text("confirm")
//                                }
//                            } label: {
//                                Label {
//                                    Text("delete")
//                                } icon: {
//                                    Image(systemName: "trash")
//                                }
//                            }
//                        } label: {
//                            Image(systemName: "ellipsis.circle")
//                        }
//                    }
//                }
                ToolbarItem(placement: .topBarTrailing) {
                    if let pasteURL = fetcher.result?.pasteURL {
                        Menu {
                            ShareLink("share paste", item: pasteURL)
                            Divider()
                            Button(action: {
                                UIPasteboard.general.string = pasteURL.absoluteString
                            }, label: {
                                Label(
                                    title: { Text("copy paste") },
                                    icon: { Image(systemName: "doc.on.clipboard") }
                                )
                            })
                            if let shareItem = fetcher.result?.content {
                                Button(action: {
                                    UIPasteboard.general.string = shareItem
                                }, label: {
                                    Label(
                                        title: { Text("copy paste content") },
                                        icon: { Image(systemName: "text.alignleft") }
                                    )
                                })
                            }
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
            .onChange(of: fetcher.result, initial: false) { _, model in
                withAnimation {
                    let address = model?.addressName ?? ""
                    guard !address.isEmpty, sceneModel.addressBook.myAddresses.contains(address) else {
                        showDraft = false
                        return
                    }
                    if model == nil && fetcher.title.isEmpty {
                        detent = .large
                        showDraft = true
                    } else if model != nil {
                        detent = .draftDrawer
                        showDraft = true
                    }
                }
            }
    }
    
    @ViewBuilder
    var mainContent: some View {
        if fetcher.loaded != nil {
            ScrollView {
                if let model = fetcher.result {
                    PasteRowView(model: model, cardColor: .lolRandom(model.listTitle), cardPadding: 8, cardradius: 16, showSelection: true)
                        .environment(\.viewContext, .detail)
                        .padding()
                } else {
                    Text(fetcher.result?.content ?? "")
                        .textSelection(.enabled)
                        .font(.body)
                        .fontDesign(.rounded)
                        .padding(.vertical, 4)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(4)
            .frame(maxWidth: .infinity)
        } else {
            LoadingView()
                .padding()
                .onAppear {
                    Task { @MainActor [fetcher] in
                        await fetcher.updateIfNeeded(forceReload: true)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    @ViewBuilder
    var draftContent: some View {
//        if let poster = fetcher.draftPoster {
//            PasteDraftView(draftFetcher: poster)
//        } else {
            EmptyView()
//        }
    }
}

//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 4/26/23.
//

#if canImport(AppKit)
import AppKit
#endif
import SwiftUI
import WebKit

struct PURLView: View {
    @Environment(\.dismiss)
    var dismiss
    @Environment(\.horizontalSizeClass)
    var sizeClass
    @Environment(\.viewContext)
    var context
    @Environment(\.addressBook)
    var addressBook
    
    @Environment(\.credentialFetcher)
    var credential
    
    @State
    var showDraft: Bool = false
    @State
    var detent: PresentationDetent = .draftDrawer
    
    @State
    var presented: URL? = nil
    
    @StateObject
    var fetcher: AddressPURLDataFetcher
    
    init(id: String, from address: AddressName) {
        _fetcher = .init(wrappedValue: .init(name: address, title: id))
    }
    
    var body: some View {
        preview
            .task { [weak fetcher] in
                guard let fetcher else { return }
                fetcher.configure(credential: credential(fetcher.address))
                await fetcher.updateIfNeeded()
            }
            .toolbar {
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
                #if !os(tvOS)
                ToolbarItem(placement: .primaryAction) {
                    if let purlURL = fetcher.result?.purlURL {
                        Menu {
                            ShareLink("share purl", item: purlURL)
                            Divider()
                            Button(action: {
#if canImport(UIKit)
                                UIPasteboard.general.string = purlURL.absoluteString
#elseif canImport(AppKit)
                                let pasteboard = NSPasteboard.general
                                pasteboard.clearContents()
                                pasteboard.setString(purlURL.absoluteString, forType: .string)
#endif
                            }, label: {
                                Label(
                                    title: { Text("copy purl") },
                                    icon: { Image(systemName: "doc.on.clipboard") }
                                )
                            })
                            if let shareItem = fetcher.result?.content {
                                Button(action: {
#if canImport(UIKit)
                                    UIPasteboard.general.string = shareItem
#elseif canImport(AppKit)
                                    let pasteboard = NSPasteboard.general
                                    pasteboard.clearContents()
                                    pasteboard.setString(shareItem, forType: .string)
#endif
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
                #endif
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
    var preview: some View {
        WebView(fetcher.page)
            .safeAreaInset(edge: .bottom) {
                if let model = fetcher.result {
                    PURLRowView(model: model, cardColor: .lolRandom(model.listTitle), cardPadding: 8, cardradius: 16, showSelection: true)
                        .padding()
                }
            }
    }
    
    @ViewBuilder
    var pathInfo: some View {
        if context != .profile {
            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    AddressIconView(address: fetcher.address, addressBook: addressBook)
                    Text("/\(fetcher.result?.name ?? fetcher.title)")
                        .font(.title2)
                        .fontDesign(.serif)
                        .foregroundStyle(Color.primary)
                        .multilineTextAlignment(.leading)
                }
                
                if let destination = fetcher.result?.content, !destination.isEmpty {
                    Text(destination)
                    #if !os(tvOS)
                        .textSelection(.enabled)
                    #endif
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
    NavigationStack {
        PURLView(id: "privacy", from: "app")
    }
}

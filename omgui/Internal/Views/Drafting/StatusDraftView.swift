//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 4/27/23.
//

import SwiftUI

//struct StatusDraftView: View {
//    @Environment(SceneModel.self)
//    var sceneModel: SceneModel
//    @SceneStorage("app.lol.address")
//    var actingAddress: AddressName = ""
//    
//    private enum FocusField: Hashable {
//        case title
//        case content
//    }
//    @FocusState
//    private var focusedField: FocusField?
//    
//    let draftPoster: StatusDraftPoster
//    
//    @State
//    var showPlaceholder: Bool = true
//    @State
//    var expandAddresses: Bool = false
//    @State
//    var clearResult: Bool = true
//    @State
//    var confirmDelete: Bool = false
//    @State
//    var velocity: CGSize = .zero
//    @State
//    var presentResult: Bool = false
//    
//    var draftId: String {
//        draftPoster.draft.id ?? ""
//    }
//    
//    init(draftPoster: StatusDraftPoster) {
//        self.draftPoster = draftPoster
//        self.showPlaceholder = draftPoster.originalDraft == nil
//    }
//    
//    var body: some View {
//        VStack(alignment: .trailing, spacing: 8) {
//            StatusRowView.Preview(draftPoster: draftPoster)
//                .padding(.horizontal)
//            
//            Divider()
//            
////            EmojiPicker(text: $draftPoster.draft.emoji, placeholder: "💗")
////                .focused($focusedField, equals: .title)
////                .frame(width: 66, height: 66)
////                .padding(2)
////                .background(Color(UIColor.systemBackground))
////                .clipShape(RoundedRectangle(cornerRadius: 12))
////                .padding(.horizontal)
//            
//            editorView
//                .sheet(isPresented: $presentResult, onDismiss: {
//                    withAnimation {
//                        if clearResult {
//                            draftPoster.draft.clear()
//                            focusedField = .title
//                        } else {
//                            focusedField = .content
//                            draftPoster.result = nil
//                            clearResult = true
//                        }
//                    }
//                }) {
//                    if let result = draftPoster.result {
//                        NavigationStack {
//                            @State var innerConfirmDelete: Bool = false
//                            sceneModel.destinationConstructor.destination(.status(result.address, id: result.id))
//                                .toolbar {
//                                    ToolbarItem(placement: .topBarTrailing) {
//                                        Button {
//                                            withAnimation {
//                                                clearResult = false
//                                                if let presented = draftPoster.result {
//                                                    draftPoster.result = presented
//                                                    draftPoster.draft = .init(model: presented, id: presented.id)
//                                                }
//                                                draftPoster.result = nil
//                                                presentResult = false
//                                            }
//                                        } label: {
//                                            Text("edit")
//                                        }
//                                    }
//                                    ToolbarItem(placement: .topBarLeading) {
//                                        Button {
//                                            innerConfirmDelete = true
//                                        } label: {
//                                            Image(systemName: "trash")
//                                        }
//                                    }
//                                }
//                                .alert("Are you sure?", isPresented: $innerConfirmDelete, actions: {
//                                    Button("Cancel", role: .cancel) { }
//                                    Button(
//                                        "Yes",
//                                        role: .destructive,
//                                        action: draftPoster.deletePresented
//                                    )
//                                }, message: {
//                                    Text("Are you sure you want to delete this status?")
//                                })
//                        }
//                    }
//                }
//        }
//        .background(Color.lolBackground)
//        .toolbar {
//            ToolbarItem(placement: .topBarLeading) {
//                ThemedTextView(text: draftPoster.navigationTitle, font: .title)
//            }
//            ToolbarItem(placement: .topBarTrailing) {
//                if !(draftPoster.draft.id ?? "").isEmpty {
//                    Button(role: .destructive) {
//                        confirmDelete = true
//                    } label: {
//                        Image(systemName: "trash")
//                    }
//                }
//            }
//        }
//        .alert("Are you sure?", isPresented: $confirmDelete, actions: {
//            Button("Cancel", role: .cancel) { }
//            Button(
//                "Yes",
//                role: .destructive,
//                action: deleteLive
//            )
//        }, message: {
//            Text("Are you sure you want to delete this status?")
//        })
//        .onAppear {
//            if draftPoster.draft.address == .autoUpdatingAddress {
//                draftPoster.address = actingAddress
//            }
//        }
//    }
//    
//    func deleteLive() {
//        guard let credential = sceneModel.addressBook.credential(for: draftPoster.address) else {
//            return
//        }
//        let toDelete = draftPoster.draft
//        Task {
//            let draftedAddress = draftPoster.address
//            let _ = try await sceneModel.interface.deleteAddressStatus(toDelete, from: draftedAddress, credential: credential)
//            
//            withAnimation {
//                draftPoster.draft.clear()
//            }
//        }
//    }
//    
//    @ViewBuilder
//    var placeholder: some View {
//        switch (focusedField, draftPoster.draft.content.isEmpty) {
//        case (.content, _):
//            EmptyView()
//        case (_, true):
//            Text(StatusModel.Draft.contentPlaceholder)
//        default:
//            EmptyView()
//        }
//    }
//    
//    @ViewBuilder
//    var addressSelector: some View {
//        if draftId.isEmpty {
//            AddressNameView(actingAddress)
//                .padding(.horizontal)
//            if expandAddresses {
//                ForEach(sceneModel.addressBook.myAddresses) { address in
//                    if address != actingAddress {
//                        Button {
//                            withAnimation {
//                                actingAddress = address
//                                expandAddresses = false
//                            }
//                        } label: {
//                            AddressNameView(address)
//                        }
//                        .padding(.horizontal)
//                    }
//                }
//            }
//        } else {
//            // Show Address
//            AddressNameView(draftPoster.address)
//        }
//    }
//    
//    @ViewBuilder
//    private var editorView: some View {
////        TextEditor(text: $draftPoster.draft.content)
//        EmptyView()
//            .padding(.horizontal, 4)
//            .background(Color(UIColor.systemBackground))
////            .toolbar {
////                ToolbarItem(placement: .keyboard) {
////                    Button {
////                        withAnimation {
////                            focusedField = nil
////                        }
////                    } label: {
////                        Text("preview")
////                    }
////                    .frame(maxWidth: .infinity, alignment: .trailing)
////                }
////            }
//            .onAppear {
//                withAnimation {
//                    focusedField = .title
//                }
//            }
//            .focused($focusedField, equals: .content)
//            .overlay(alignment: .topLeading) {
//                placeholder
//                    .padding(8)
//                    foregroundStyle(Color.gray)
//            }
//            .background(Material.regular)
//            .clipShape(RoundedRectangle(cornerRadius: 16))
//            .padding(.horizontal)
//            .padding(.bottom)
//            .frame(maxHeight: focusedField == .content ? .infinity : nil)
//            .overlay(alignment: .bottom) {
//                if let result = draftPoster.result {
//                    StatusRowView(model: result)
//                        .task {
//                            await delayText()
//                        }
//                        .padding(.horizontal)
//                        .background(Material.regular)
//                        .mask {
//                            RoundedRectangle(cornerRadius: 12)
//                        }
//                        .padding([.bottom, .horizontal], 8)
//                        .onTapGesture {
//                            withAnimation {
//                                focusedField = .title
//                                draftPoster.draft = .init(model: result, id: result.id)
//                                draftPoster.result = nil
//                            }
//                        }
//                        .onLongPressGesture(perform: {
//                            withAnimation {
//                                presentResult = true
//                            }
//                        })
//                        .gesture(
//                            simpleDrag
//                        )
//                        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .offset(x: velocity.width, y: velocity.height).combined(with: .opacity)))
//                }
//            }
//    }
//    
//    private func delayText() async {
//        try? await Task.sleep(nanoseconds: 10_000_000_000)
//        withAnimation {
//            draftPoster.result = nil
//        }
//    }
//    
//    private var simpleDrag: some Gesture {
//        DragGesture()
//            .onChanged { value in
//                let horizontal = abs(value.velocity.width)
//                let vertical = abs(value.velocity.height)
//                
//                if horizontal > 500 || vertical > 700 {
//                    velocity = value.velocity
//                    withAnimation {
//                        draftPoster.result = nil
//                    }
//                }
//            }
//    }
//}

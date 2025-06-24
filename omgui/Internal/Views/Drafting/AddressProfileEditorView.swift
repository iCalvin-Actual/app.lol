//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/28/23.
//

import SwiftUI
import MarkdownEditor

@available(iOS 18.0, *)
public struct AddressProfileEditorView: View {
    @Environment(\.dismiss)
    var dismiss
    
    @StateObject
    var draftPoster: ProfileMarkdownDraftPoster
    
    var selectedDraft: ProfileMarkdown.Draft?
    
    @State
    var content: String = ""
    
    @available(iOS 18.0, *)
    @State
    var selection: TextSelection? = nil
    
    @State
    var confirmReset: Bool = false
    @State
    var showFormatting: Bool = false
    
    var hasChanges: Bool {
        draftPoster.originalDraft?.content != content
    }
    
    init(_ draftPoster: ProfileMarkdownDraftPoster, basedOn: ProfileMarkdown.Draft? = nil) {
        self._draftPoster = .init(wrappedValue: draftPoster)
        self.selectedDraft = basedOn
        self._content = .init(initialValue: draftPoster.originalDraft?.content ?? "")
    }
    
    public var body: some View {
        appropriateEditor
            .tint(Color.primary)
            .padding(4)
        #if canImport(UIKit)
            .background(Color(uiColor: .systemBackground))
        #endif
            .cornerRadius(24)
            .padding()
            .background(NavigationDestination.editWebpage(draftPoster.address).gradient)
            .interactiveDismissDisabled()
            .toolbar {
                ToolbarItem(placement: .secondaryAction) {
                    Button {
                        if hasChanges {
                            confirmReset = true
                        } else {
                            dismiss()
                        }
                    } label: {
                        Label(title: {
                            Text("close")
                        }) {
                            Image(systemName: "xmark")
                        }
                    }
                }
                ToolbarItem(placement: .secondaryAction) {
                    Button {
                        applyContent()
                        Task { @MainActor in
                            try? await draftPoster.saveDraft()
                        }
                    } label: {
                        Label(title: {
                            Text("stash")
                        }) {
                            Image(systemName: hasChanges ? "arrow.up.bin.fill" : "arrow.up.bin" )
                        }
                    }
                    .disabled(!hasChanges)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        applyContent()
                        Task { @MainActor in
                            await draftPoster.perform()
                        }
                    } label: {
                        Label(title: {
                            Text("submit")
                        }) {
                            Image(systemName: "arrow.up.forward.app.fill")
                        }
                    }
                }
            }
            .confirmationDialog("do you want to save your changes as a draft?", isPresented: $confirmReset) {
                
                Button(role: .destructive) {
                    dismiss()
                } label: {
                    Text("discard changes")
                }
                
                Button {
                    applyContent()
                    Task { @MainActor in
                        try? await draftPoster.saveDraft()
                    }
                } label: {
                    Text("save draft")
                }
                
                Button(role: .cancel) {
                    confirmReset = false
                } label: {
                    Text("nevermind")
                }
            }
    }
    
    @ViewBuilder
    var appropriateEditor: some View {
        if #available (iOS 18, *) {
            MarkdownEditor<StandardToolbar>(text: $content, selection: $selection)
        } else {
            TextEditor(text: $content)
        }
    }

    func applyContent() {
        self.draftPoster.draft.content = content
    }
    
    func resetContent() {
        content = draftPoster.originalDraft?.content ?? ""
    }
}

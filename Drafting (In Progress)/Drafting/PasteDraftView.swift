
import SwiftUI


struct PasteDraftView: View {
    
    @Environment(\.viewContext)
    var context: ViewContext
    
    enum FocusField: Hashable {
        case title
        case content
    }
    @FocusState
    private var focusedField: FocusField?
    
//    let draftFetcher: PasteDraftPoster
    
    init(focusedField: FocusField? = nil/*, draftFetcher: PasteDraftPoster*/) {
        self.focusedField = focusedField
    }
    
    var body: some View {
        EmptyView()
//        VStack {
//            HStack(alignment: .lastTextBaseline) {
//                if context != .profile {
//                    AddressNameView(draftFetcher.address, font: .title3, path: ".paste.lol")
//                }
//                Spacer()
//                postButton
//            }
//            .padding(2)
//            
//            VStack {
//                PathField(text: $draftFetcher.namedDraft.name, placeholder: "path")
//                    .padding(.horizontal, 12)
//                ZStack(alignment: .topLeading) {
//                    if draftFetcher.namedDraft.content.isEmpty {
//                    Text("Placeholder")
//                        .padding(.top, 6)
//                        .padding(.leading, 4)
//                        .foregroundStyle(Color(uiColor: .lightGray))
//                    }
//                    TextEditor(text: $draftFetcher.namedDraft.content)
//                        .scrollContentBackground(.hidden)
//                }
//                .padding(.horizontal, 4)
//                .fontDesign(.monospaced)
//            }
//            .padding(.vertical, 12)
//            foregroundStyle(Color.black)
//            .background(Color.lolRandom(draftFetcher.draft.name))
//            .cornerRadius(12, antialiased: true)
//            .padding(.vertical, 4)
//            
//            Spacer()
//        }
//        .padding()
//        .frame(alignment: .top)
//        .background(Color.lolBackground)
//    }
//    
//    @ViewBuilder
//    var draftBody: some View {
//        PathField(text: $draftFetcher.namedDraft.name, placeholder: "title")
//            .font(.title2)
//            .bold()
//            .fontDesign(.serif)
//            .lineLimit(2)
//            
//        TextEditor(text: $draftFetcher.namedDraft.content)
//            .frame(minHeight: 33)
//    }
//    
//    @ViewBuilder
//    var postButton: some View {
//        Button(action: {
//            guard draftFetcher.draft.publishable else {
//                return
//            }
//            Task {
//                await draftFetcher.perform()
//            }
//        }) {
//            Label {
//                if draftFetcher.originalDraft == nil {
//                    Text("publish")
//                } else {
//                    Text("update")
//                }
//            } icon: {
//                Image(systemName: "arrow.up.circle.fill")
//            }
//            .font(.headline)
//        }
//        .disabled(!draftFetcher.draft.publishable)
    }
}

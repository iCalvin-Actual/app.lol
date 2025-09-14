
import SwiftUI


//struct PURLDraftView: View {
//    
//    @Environment(\.viewContext)
//    var context: ViewContext
//    
//    enum FocusField: Hashable {
//        case title
//        case content
//    }
//    @FocusState
//    private var focusedField: FocusField?
//    
//    let draftFetcher: PURLDraftPoster
//    
//    init(focusedField: FocusField? = nil, draftFetcher: PURLDraftPoster) {
//        self.draftFetcher = draftFetcher
//        self.focusedField = focusedField
//    }
//    
//    var body: some View {
//        VStack {
//            HStack(alignment: .lastTextBaseline) {
//                if context != .profile {
//                    AddressNameView(draftFetcher.address, suffix: ".url.lol")
//                }
//                Spacer()
//                postButton
//            }
//            .padding(2)
//            
//            VStack {
////                PathField(text: $draftFetcher.namedDraft.name, placeholder: "path")
////                URLField(text: $draftFetcher.namedDraft.content)
//            }
//            .padding(12)
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
//        EmptyView()
////        PathField(text: $draftFetcher.namedDraft.name, placeholder: "title")
////            .font(.title2)
////            .bold()
////            .fontDesign(.serif)
////            .lineLimit(2)
////            
////        TextEditor(text: $draftFetcher.namedDraft.content)
////            .frame(minHeight: 33)
//    }
//    
//    @ViewBuilder
//    var postButton: some View {
//        Button(action: {
//            guard draftFetcher.draft.publishable else {
//                return
//            }
//            Task { [draftFetcher] in
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
//    }
//}

//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 4/2/23.
//

import Blackbird
import MarkdownUI
import SwiftUI

// Draft Protocols

protocol SomeDraftable: Sendable {
    associatedtype Draft: DraftItem
}
//protocol NamedDraftable: SomeDraftable, Equatable {
//    associatedtype NamedDraftItem: NamedDraft
//    
//    var asDraft: Draft { get }
//}
protocol MDDraftable: SomeDraftable {
    associatedtype MDDraftItem: MDDraft
    
    var asDraft: Draft { get }
}

protocol DraftItem: Sendable, Identifiable, BlackbirdListable {
    
    static var contentPlaceholder: String { get }
    
    var id: String { get set }
    var addressName: AddressName { get set }
    var content: String { get set }
    var filterDate: Date? { get set }
    
    var publishable: Bool { get }
    
    mutating
    func clear()
}
extension DraftItem {
    var publishable: Bool {
        !content.isEmpty
    }
    
    mutating
    func clear() {
        content = ""
    }
}

protocol MDDraft: DraftItem { }

extension ProfileMarkdown: MDDraftable {
    typealias MDDraftItem = Draft
    
    struct Draft: MDDraft {
        
        public static var sortingKey: BlackbirdColumnKeyPath { dateKey }
        public static var ownerKey: BlackbirdColumnKeyPath { \.$addressName }
        public static var primaryKey: [BlackbirdColumnKeyPath] { [\.$id] }
        public static var dateKey: BlackbirdColumnKeyPath { \.$filterDate }
        public var rowDestination: NavigationDestination { .editWebpage(addressName) }
        
        var listTitle: String { id }
        
        var listSubtitle: String { content }
        
        static var filterOptions: [FilterOption] { [] }
        
        static var defaultFilter: [FilterOption] { [.none] }
        
        
        static var sortOptions: [Sort] { [] }
        
        static var defaultSort: Sort { .newestFirst }
        
        static var contentPlaceholder: String {
            "from the top"
        }
        
        @BlackbirdColumn
        var id: String
        @BlackbirdColumn
        var addressName: AddressName
        @BlackbirdColumn
        var content: String
        @BlackbirdColumn
        var publish: Bool
        @BlackbirdColumn
        var filterDate: Date?
        
        var publishable: Bool { true }
        
        init(_ row: Blackbird.ModelRow<ProfileMarkdown.Draft>) {
            self.init(id: row[\.$id], address: row[\.$addressName], content: row[\.$content], publish: row[\.$publish], edited: row[\.$filterDate])
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            addressName = try container.decode(AddressName.self, forKey: .addressName).punified
            filterDate = try container.decode(Date.self, forKey: .filterDate)
            content = try container.decode(String.self, forKey: .content)
            publish = try container.decode(Bool.self, forKey: .publish)
        }
        
        init(id: String? = nil, address: AddressName, content: String, publish: Bool, edited: Date?) {
            self.id = {
                if let id = id {
                    return id
                }
                if let edited {
                    return DateFormatter.short.string(from: edited)
                }
                return UUID().uuidString
            }()
            self.addressName = address
            self.content = content
            self.publish = publish
            self.filterDate = edited
        }
    }
    
    var asDraft: Draft {
        .init(address: owner, content: content, publish: true, edited: Date())
    }
}

//extension NowModel {
//    typealias MDDraftItem = Draft
//    
//    struct Draft: MDDraft {
//        static var contentPlaceholder: String {
//            "what's the latest?"
//        }
//        
//        var id: String { address }
//        
//        var address: AddressName
//        
//        var content: String
//        var listed: Bool
//        
//        var publishable: Bool { true }
//    }
//    
//    var asDraft: Draft {
//        .init(address: owner, content: content ?? "", listed: true)
//    }
//}
//
//extension StatusModel {
//    var asDraft: Draft {
//        .init(model: self)
//    }
//    
//    typealias MDDraftItem = Draft
//    
//    public struct Draft {
//        static var contentPlaceholder: String {
//            "what's new?"
//        }
//        
//        var address: AddressName
//        
//        public var id: String?
//        public var content: String
//        public var emoji: String
//        public var externalUrl: String?
//        
//        var publishable: Bool {
//            guard id == nil else {
//                return true
//            }
//            return !content.isEmpty
//        }
//        
//        var displayEmoji: String {
//            emoji.isEmpty ? "💗" : emoji
//        }
//        
//        mutating
//        func clear() {
//            id = nil
//            content = ""
//            emoji = ""
//            externalUrl = ""
//        }
//        
//        init(model: StatusModel, id: String? = nil) {
//            self.address = model.owner
//            self.id = id
//            self.content = model.status
//            self.emoji = model.emoji ?? ""
//        }
//        
//        init(address: AddressName, id: String? = nil, content: String, emoji: String, externalUrl: String? = nil) {
//            self.address = address
//            self.id = id
//            self.content = content
//            self.emoji = emoji
//            self.externalUrl = externalUrl
//        }
//    }
//}
//
protocol NamedDraft: DraftItem {
    var name: String { get set }
    var listed: Bool { get set }
    
    init(address: AddressName, name: String, content: String, listed: Bool)
}
extension NamedDraft {
    mutating
    func clear() {
        content = ""
        name = ""
        listed = false
    }
}

extension PasteModel {
    typealias NamedDraftItem = Draft
    
    public struct Draft {
        static var contentPlaceholder: String {
            "what do you have?"
        }
        
        var address: AddressName
        
        public var name: String
        public var content: String
        public var listed: Bool
        
        var publishable: Bool {
            !name.isEmpty && !content.isEmpty
        }
        
        init(address: AddressName, name: String, content: String, listed: Bool = true) {
            self.address = address
            self.name = name
            self.content = content
            self.listed = listed
        }
    }
    
    var asDraft: Draft {
        .init(address: addressName, name: name, content: content, listed: listed)
    }
}
//
//extension PURLModel {
//    typealias NamedDraftItem = Draft
//    public struct Draft {
//        static var contentPlaceholder: String {
//            "where are we going?"
//        }
//        
//        var address: AddressName
//        
//        public var name: String
//        public var content: String
//        public var listed: Bool
//        
//        var publishable: Bool {
//            !name.isEmpty && !content.isEmpty
//        }
//        
//        init(_ model: PURLModel, name: String? = nil) {
//            self.init(
//                address: model.addressName,
//                name: name ?? "",
//                content: model.content,
//                listed: model.listed
//            )
//        }
//        
//        init(address: AddressName, name: String, content: String = "", listed: Bool = true) {
//            self.address = address
//            self.name = name
//            self.content = content
//            self.listed = listed
//        }
//    }
//    
//    var asDraft: Draft {
//        .init(address: addressName, name: self.name, content: content, listed: listed)
//    }
//}
//
//// MARK: Previews
//
//extension PURLRowView {
//    struct Preview: View {
//        @SceneStorage("app.lol.address")
//        var actingAddress: AddressName = ""
//        
//        @Environment(\.viewContext)
//        var context: ViewContext
//        
//        let draftPoster: PURLDraftPoster
//        
//        var body: some View {
//            VStack(alignment: .leading, spacing: 0) {
//                HStack(alignment: .bottom) {
//                    if context != .profile {
//                        AddressNameView(draftPoster.address, font: .title3)
//                    }
//                    Spacer()
//                    postButton
//                }
//                .padding(2)
//                
//                VStack(alignment: .leading, spacing: 12) {
//                    HStack {
//                        Text("/\(draftPoster.namedDraft.name)")
//                            .font(.title2)
//                            .bold()
//                            .fontDesign(.serif)
//                            .lineLimit(2)
//                        Spacer()
//                    }
//                    
//                    if !draftPoster.namedDraft.content.isEmpty {
//                        Text(draftPoster.namedDraft.content)
//                            .font(.subheadline)
//                            .fontDesign(.monospaced)
//                            .lineLimit(5)
//                    }
//                }
//                .multilineTextAlignment(.leading)
//                .frame(maxWidth: .infinity)
//                .padding(12)
//                foregroundStyle(Color.black)
//                .background(Color.lolRandom(draftPoster.draft.name))
//                .cornerRadius(12, antialiased: true)
//                .padding(.vertical, 4)
//            }
//            .frame(maxWidth: .infinity)
//        }
//        
//        @ViewBuilder
//        var postButton: some View {
//            Button(action: {
//                guard draftPoster.draft.publishable else {
//                    return
//                }
//                Task { [draftPoster] in
//                    await draftPoster.perform()
//                    draftPoster.draft.clear()
//                }
//            }) {
//                Label {
//                    if draftPoster.result?.id == nil {
//                        Text("publish")
//                    } else {
//                        Text("update")
//                    }
//                } icon: {
//                    Image(systemName: "arrow.up.circle.fill")
//                }
//                .font(.headline)
//            }
//            .disabled(!draftPoster.draft.publishable)
//        }
//    }
//}
//
//extension StatusRowView {
//    public struct Preview: View {
//        @SceneStorage("app.lol.address")
//        var actingAddress: AddressName = ""
//        
//        @Environment(\.viewContext)
//        var context: ViewContext
//        
//        let draftPoster: StatusDraftPoster
//        
//        var address: AddressName {
//            if draftPoster.draft.address == .autoUpdatingAddress {
//                return actingAddress
//            }
//            return draftPoster.draft.address
//        }
//        
//        var body: some View {
//            VStack(alignment: .trailing, spacing: 0) {
//                HStack {
//                    AddressIconView(address: address)
//                    
//                    Text(draftPoster.draft.displayEmoji)
//                        .font(.system(size: 42))
//                    
//                    Spacer()
//                    postButton
//                }
//                /*
//                 This was tricky to set up
//                 so I'm leaving it here
//                 
//    //                    Text(model.displayEmoji)
//    //                        .font(.system(size: 44))
//    //                    + Text(" ").font(.largeTitle) +
//                 */
//                rowBody
//                    .padding(.bottom, 2)
//                    .asCard(backgroundColor: .lolRandom(draftPoster.draft.displayEmoji), radius: 6)
//            }
//            .lineLimit(3)
//            .multilineTextAlignment(.leading)
//        }
//        
//        @ViewBuilder
//        var rowBody: some View {
//            appropriateMarkdown
//                .font(.system(.body))
//                .fontWeight(.medium)
//                .fontDesign(.rounded)
//                .environment(\.colorScheme, .light)
//                .frame(maxWidth: .infinity, alignment: .leading)
//        }
//        
//        @ViewBuilder
//        var appropriateMarkdown: some View {
//            if draftPoster.draft.content.isEmpty {
//                Text("")
//                    .padding(.vertical, 4)
//            } else {
//                Markdown(draftPoster.draft.content)
//                    foregroundStyle(Color.black)
//            }
//        }
//        
//        @ViewBuilder
//        var postButton: some View {
//            Button(action: {
//                /*
//                guard draftPoster.draft.publishable else {
//                    return
//                }
//                if draftPoster.draft.id?.isEmpty ?? true {
//                    draftPoster.address = actingAddress
//                }
//                Task {
//                    await draftPoster.perform()
//                    draftPoster.draft.clear()
//                }
//                 */
//            }) {
//                Label {
//                    if draftPoster.draft.id == nil {
//                        Text("publish")
//                    } else {
//                        Text("update")
//                    }
//                } icon: {
//                    Image(systemName: "arrow.up.circle.fill")
//                }
//                .font(.headline)
//            }
//            .disabled(!draftPoster.draft.publishable)
//        }
//    }
//}

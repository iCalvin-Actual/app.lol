//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Blackbird
import Foundation
import os

private let logger = Logger(subsystem: "ViewModels", category: "model-errors")

protocol BlackbirdListable: BlackbirdModel, Listable {
    static var sortingKey: BlackbirdColumnKeyPath { get }
    static var ownerKey: BlackbirdColumnKeyPath { get }
    static var dateKey: BlackbirdColumnKeyPath { get }
}
extension BlackbirdListable {
    static public var fullTextSearchableColumns: [PartialKeyPath<Self> : BlackbirdModelFullTextSearchableColumn] { [
        ownerKey: .text,
        dateKey: .filterOnly
    ]}
    static public var primaryKey: [PartialKeyPath<Self>] { [ownerKey] }
}

public struct ServiceInfoModel: Sendable {
    let members: Int?
    let addresses: Int?
    let profiles: Int?
    
    public init(members: Int? = nil, addresses: Int? = nil, profiles: Int? = nil) {
        self.members = members
        self.addresses = addresses
        self.profiles = profiles
    }
}

public struct AddressAvailabilityModel: Sendable {
    let address: AddressName
    let available: Bool
    let punyCode: String?
    
    public init(address: AddressName, available: Bool, punyCode: String? = nil) {
        self.address = address
        self.available = available
        self.punyCode = punyCode
    }
}

public struct AccountInfoModel: Sendable {
    let name: String
    let created: Date
    
    public init(name: String, created: Date) {
        self.name = name
        self.created = created
    }
}

public struct ThemeModel: Codable, Sendable {
    let id: String
    let name: String
    let created: String
    let updated: String
    let author: String
    let license: String
    let details: String
    let preview: String
    
    public enum CodingKeys: String, CodingKey {
        case id
        case name
        case created
        case updated
        case author
        case license
        case details = "description"
        case preview
    }
    
    
    public init(id: String, name: String, created: String, updated: String, author: String, license: String, description: String, preview: String) {
        self.id = id
        self.name = name
        self.created = created
        self.updated = updated
        self.author = author
        self.license = license
        self.details = description
        self.preview = preview
    }
}

struct AddressIconModel: BlackbirdModel {
    static var sortingKey: BlackbirdColumnKeyPath { \.$id }
    static var ownerKey: BlackbirdColumnKeyPath { \.$id }
    static var dateKey: BlackbirdColumnKeyPath { \.$date }
    
    @BlackbirdColumn
    public var id: AddressName
    @BlackbirdColumn
    var data: Data?
    @BlackbirdColumn
    var date: Date
    
    enum CodingKeys: String, BlackbirdCodingKey {
        case id
        case data
        case date
    }
    
    init(_ row: Blackbird.ModelRow<AddressIconModel>) {
        self.init(owner: row[\.$id], data: row[\.$data], date: row[\.$date])
    }
    
    init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(AddressName.self, forKey: .id).punified
        date = try container.decode(Date.self, forKey: .data)
        if let data = try container.decodeIfPresent(Data.self, forKey: .data) {
            self.data = data
        }
    }
    
    init(owner: AddressName, data: Data? = nil, date: Date = .now) {
        self.id = owner.punified
        self.data = data
        self.date = date
    }
}

public struct AddressProfilePage: RemoteBackedBlackbirdModel, Sendable {
    var owner: AddressName { id }
    @BlackbirdColumn
    public var id: AddressName
    @BlackbirdColumn
    var content: String
    
    var htmlContent: String? { content }
    
    enum CodingKeys: String, BlackbirdCodingKey {
        case id
        case content
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(AddressName.self, forKey: .id).punified
        self._content = try container.decode(BlackbirdColumn<String>.self, forKey: .content)
    }
    
    public init(_ row: Blackbird.ModelRow<AddressProfilePage>) {
        self.init(owner: row[\.$id], content: row[\.$content])
    }
    
    public init(owner: AddressName, content: String) {
        self.id = owner.punified
        self.content = content
    }
}

public struct ProfileMarkdown: BlackbirdModel, Sendable {
    var owner: AddressName { id }
    @BlackbirdColumn
    public var id: AddressName
    @BlackbirdColumn
    var content: String
    
    enum CodingKeys: String, BlackbirdCodingKey {
        case id
        case content
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(AddressName.self, forKey: .id).punified
        self._content = try container.decode(BlackbirdColumn<String>.self, forKey: .content)
    }
    
    public init(_ row: Blackbird.ModelRow<ProfileMarkdown>) {
        self.init(owner: row[\.$id], content: row[\.$content])
    }
    
    public init(owner: AddressName, content: String) {
        self.id = owner.punified
        self.content = content
    }
}

protocol RemoteBackedBlackbirdModel: BlackbirdModel {
    var id: AddressName { get }
    var htmlContent: String? { get }
}

public struct NowModel: RemoteBackedBlackbirdModel, Sendable {
    public static var sortingKey: BlackbirdColumnKeyPath { ownerKey }
    public static var ownerKey: BlackbirdColumnKeyPath { \.$id }
    public static var dateKey: BlackbirdColumnKeyPath { \.$date }
    
    @BlackbirdColumn
    public var id: AddressName
    @BlackbirdColumn
    var content: String?
    @BlackbirdColumn
    var html: String?
    @BlackbirdColumn
    var date: Date
    @BlackbirdColumn
    var listed: Bool?
    
    var htmlContent: String? { html }
    
    var owner: AddressName { id }
    
    enum CodingKeys: String, BlackbirdCodingKey {
        case id
        case content
        case html
        case date
        case listed
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(AddressName.self, forKey: .id).punified
        self.content = try container.decodeIfPresent(String.self, forKey: .content)
        self.html = try container.decodeIfPresent(String.self, forKey: .html)
        self.date = try container.decode(Date.self, forKey: .date)
        self.listed = try container.decodeIfPresent(Bool.self, forKey: .listed)
    }
    
    public init(_ row: Blackbird.ModelRow<NowModel>) {
        self.init(
            owner: row[\.$id],
            content: row[\.$content],
            html: row[\.$html],
            date: row[\.$date],
            listed: row[\.$listed]
        )
    }
    
    public init(
        owner: AddressName,
        content: String? = nil,
        html: String? = nil,
        date: Date = .now,
        listed: Bool? = nil
    ) {
        self.id = owner.punified
        self.content = content
        self.html = html
        self.date = date
        self.listed = listed
    }
}

public struct PasteModel: BlackbirdListable, Identifiable, RawRepresentable, Codable, Sendable {
    public static var sortingKey: BlackbirdColumnKeyPath { \.$name }
    public static var ownerKey: BlackbirdColumnKeyPath { \.$owner }
    public static var primaryKey: [BlackbirdColumnKeyPath] { [\.$owner, \.$name] }
    public static var dateKey: BlackbirdColumnKeyPath { \.$date }
    
    static var separator: String { "{PASTE}" }
    
    public var rawValue: String {
        [owner, name].joined(separator: Self.separator)
    }
    
    @BlackbirdColumn
    public var owner: AddressName
    @BlackbirdColumn
    public var name: String
    @BlackbirdColumn
    public var content: String
    @BlackbirdColumn
    public var date: Date
    @BlackbirdColumn
    public var listed: Bool
    
    var pasteURL: URL {
        URL(string: "https://\(owner).paste.lol/\(name)")!
    }
    
    enum CodingKeys: String, BlackbirdCodingKey {
        case owner
        case name
        case content
        case date
        case listed
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        owner = try container.decode(AddressName.self, forKey: .owner).punified
        name = try container.decode(String.self, forKey: .name)
        content = try container.decode(String.self, forKey: .content)
        date = try container.decode(Date.self, forKey: .date)
        listed = try container.decode(Bool.self, forKey: .listed)
    }
    
    public init(_ row: Blackbird.ModelRow<PasteModel>) {
        self.init(
            owner: row[\.$owner],
            name: row[\.$name],
            content: row[\.$content],
            date: row[\.$date],
            listed: row[\.$listed]
        )
    }
    
    public init?(rawValue: String) {
        let split = rawValue.split(separator: Self.separator)
        guard split.count > 1 else {
            return nil
        }
        self.owner = String(split[0]).punified
        self.name = String(split[1])
        self.content = ""
        self.date = .init(timeIntervalSince1970: 0)
        self.listed = true
    }
    
    public init(id: String? = nil, owner: AddressName, name: String, content: String? = nil, date: Date = .now, listed: Bool = true) {
        self.owner = owner.punified
        self.name = name
        self.content = content ?? ""
        self.date = date
        self.listed = listed
    }
}

public struct PURLModel: BlackbirdListable, Identifiable, RawRepresentable, Codable, Sendable {
    var rowDestination: NavigationDestination { .purl(owner, id: name) }
    
    public static var sortingKey: BlackbirdColumnKeyPath { \.$name }
    public static var ownerKey: BlackbirdColumnKeyPath { \.$owner }
    public static var primaryKey: [BlackbirdColumnKeyPath] { [\.$owner, \.$name] }
    public static var dateKey: BlackbirdColumnKeyPath { \.$date }
    
    static var separator: String { "{PURL}" }
    
    public var rawValue: String {
        [owner, name].joined(separator: Self.separator)
    }
    
    @BlackbirdColumn
    public var owner: AddressName
    @BlackbirdColumn
    public var name: String
    @BlackbirdColumn
    public var content: String
    @BlackbirdColumn
    public var date: Date
    @BlackbirdColumn
    public var listed: Bool
    
    var url: URL? {
        URL(string: content)
    }
    
    var purlURL: URL {
        URL(string: "https://\(owner).url.lol/\(name)")!
    }
    
    enum CodingKeys: String, BlackbirdCodingKey {
        case owner
        case name
        case content
        case date
        case listed
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        owner = try container.decode(AddressName.self, forKey: .owner).punified
        name = try container.decode(String.self, forKey: .name)
        content = try container.decode(String.self, forKey: .content)
        date = try container.decode(Date.self, forKey: .date)
        listed = try container.decode(Bool.self, forKey: .listed)
    }
    
    public init(_ row: Blackbird.ModelRow<PURLModel>) {
        self.init(
            owner: row[\.$owner],
            name: row[\.$name],
            content: row[\.$content],
            date: row[\.$date],
            listed: row[\.$listed]
        )
    }
    
    public init?(rawValue: String) {
        let split = rawValue.split(separator: Self.separator)
        guard split.count > 1 else {
            return nil
        }
        self.owner = String(split[0]).punified
        self.name = String(split[1])
        self.content = ""
        self.date = .init(timeIntervalSince1970: 0)
        self.listed = true
    }
    
    public init(id: String? = nil, owner: AddressName, name: String, content: String? = nil, date: Date = .now, listed: Bool = true) {
        self.owner = owner.punified
        self.name = name
        self.content = content ?? ""
        self.date = date
        self.listed = listed
    }
}

public struct NowListing: BlackbirdListable, Identifiable, Sendable {
    public static var sortingKey: BlackbirdColumnKeyPath { ownerKey }
    public static var ownerKey: BlackbirdColumnKeyPath { \.$id }
    public static var dateKey: BlackbirdColumnKeyPath { \.$date }
    
    @BlackbirdColumn
    public var id: AddressName
    @BlackbirdColumn
    var url: String
    @BlackbirdColumn
    var date: Date
    
    var owner: AddressName { id }
    
    enum CodingKeys: String, BlackbirdCodingKey {
        case id
        case url
        case date
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(AddressName.self, forKey: .id).punified
        self._url = try container.decode(BlackbirdColumn<String>.self, forKey: .url)
        self._date = try container.decode(BlackbirdColumn<Date>.self, forKey: .date)
    }
    
    public init(_ row: Blackbird.ModelRow<NowListing>) {
        self.init(owner: row[\.$id], url: row[\.$url], date: row[\.$date])
    }
    
    public init(owner: AddressName, url: String, date: Date) {
        self.id = owner.punified
        self.url = url
        self.date = date
    }
}

public struct AddressModel: BlackbirdListable, Identifiable, RawRepresentable, Codable, Sendable {
    public static var sortingKey: BlackbirdColumnKeyPath { ownerKey }
    static public var ownerKey: BlackbirdColumnKeyPath { \.$owner }
    static public var dateKey: BlackbirdColumnKeyPath { \.$date }
    
    public init?(rawValue: String) {
        self = AddressModel(name: rawValue)
        self.date = .init(timeIntervalSince1970: 0)
    }
    
    public var rawValue: String { owner }
    
    @BlackbirdColumn
    var owner: AddressName
    @BlackbirdColumn
    var url: URL?
    @BlackbirdColumn
    var date: Date
    
    enum CodingKeys: String, BlackbirdCodingKey {
        case owner
        case url
        case date
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        owner = try container.decode(AddressName.self, forKey: .owner).punified
        url = try container.decodeIfPresent(URL.self, forKey: .url)
        date = try container.decode(Date.self, forKey: .date)
    }
    
    public init(_ row: Blackbird.ModelRow<AddressModel>) {
        self = .init(
            name: row[\.$owner],
            url: row[\.$url],
            date: row[\.$date]
        )
    }
    
    public init(name: AddressName, url: URL? = nil, date: Date = .now) {
        self.owner = name.punified
        self.url = url
        self.date = date
    }
}

public struct StatusModel: BlackbirdListable, Identifiable, Sendable {
    public static var sortingKey: BlackbirdColumnKeyPath { \.$emoji }
    static public var primaryKey: [BlackbirdColumnKeyPath] { [\.$id] }
    static public var ownerKey: BlackbirdColumnKeyPath { \.$owner }
    static public var dateKey: BlackbirdColumnKeyPath { \.$date }
    static public var fullTextSearchableColumns: FullTextIndex {[
        ownerKey: .text,
        dateKey: .filterOnly,
        \.$status: .text,
        \.$emoji: .text
    ]}
    
    @BlackbirdColumn
    public var id: String
    @BlackbirdColumn
    var owner: AddressName
    @BlackbirdColumn
    var date: Date
    
    @BlackbirdColumn
    var status: String
    
    var displayStatus: String {
        status.replacingOccurrences(of: "(?<!\n)\n(?!\n)", with: "  \n", options: .regularExpression)
    }
    
    @BlackbirdColumn
    var emoji: String?
    @BlackbirdColumn
    var linkText: String?
    @BlackbirdColumn
    var link: URL?
    
    enum CodingKeys: String, BlackbirdCodingKey {
        case id
        case owner
        case date
        case status
        case emoji
        case linkText
        case link
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._id = try container.decode(BlackbirdColumn<String>.self, forKey: .id)
        self.owner = try container.decode(AddressName.self, forKey: .owner).punified
        self._date = try container.decode(BlackbirdColumn<Date>.self, forKey: .date)
        self._status = try container.decode(BlackbirdColumn<String>.self, forKey: .status)
        self._emoji = try container.decode(BlackbirdColumn<String?>.self, forKey: .emoji)
        self._linkText = try container.decode(BlackbirdColumn<String?>.self, forKey: .linkText)
        self._link = try container.decode(BlackbirdColumn<URL?>.self, forKey: .link)
    }
    
    public init(_ row: Blackbird.ModelRow<StatusModel>) {
        self.init(
            id: row[\.$id],
            owner: row[\.$owner],
            date: row[\.$date],
            status: row[\.$status],
            emoji: row[\.$emoji],
            linkText: row[\.$linkText],
            link: row[\.$link]
        )
    }
    
    public init(id: String, owner: AddressName, date: Date, status: String, emoji: String? = nil, linkText: String? = nil, link: URL? = nil) {
        self.id = id
        self.owner = owner.punified
        self.date = date
        self.status = status
        self.emoji = emoji
        self.linkText = linkText
        self.link = link
    }
    
    var displayEmoji: String {
        emoji ?? "✨"
    }
    
    var urlString: String {
        "https://\(owner).status.lol/\(id)"
    }
    
    var primaryDestination: NavigationDestination {
        .statusLog(owner)
    }
    
    var webLinks: [SharePacket] {
        func extractImageNamesAndURLs(from markdown: String) -> [(name: String, url: URL)] {
            var results = [(name: String, url: URL)]()
            
            do {
                let markdownRegex = try NSRegularExpression(pattern: "\\[(.*?)\\]\\(([^)]+)\\)", options: [])
                let nsString = NSString(string: markdown)
                var matches = markdownRegex.matches(in: markdown, options: [], range: NSRange(location: 0, length: nsString.length))
                
                for set in matches.enumerated() {
                    let match = set.element
                    guard match.numberOfRanges == 3 else { continue }
                    let nameRange = match.range(at: 1)
                    let urlRange = match.range(at: 2)
                    let matchingName = nsString.substring(with: nameRange)
                    let name: String = matchingName
                    let urlString = nsString.substring(with: urlRange)
                    guard let url = URL(string: urlString) else {
                        continue
                    }
                    results.append((name, url))
                }
                
                let dataDetector: NSDataDetector = try .init(types: NSTextCheckingResult.CheckingType.link.rawValue)
                matches = dataDetector.matches(in: markdown, range: NSMakeRange(0, nsString.length))
                matches.forEach({ match in
                    let matchString = nsString.substring(with: match.range)
                    guard let urlMatch = URL(string: matchString), !results.contains(where: { $0.url == urlMatch }) else {
                        return
                    }
                    results.append(("", urlMatch))
                })
            } catch {
                logger.error("Error while processing regex: \(String(describing: error))")
            }
            
            return results
        }
        return extractImageNamesAndURLs(from: status).map({ SharePacket(name: $0.name, content: $0.url) })
    }
    
    var imageLinks: [SharePacket] {
        func extractImageNamesAndURLs(from markdown: String) -> [(name: String, url: URL)] {
            var results = [(name: String, url: URL)]()
            
            do {
                let regex = try NSRegularExpression(pattern: "!\\[(.*?)\\]\\(([^)]+)\\)", options: [])
                let nsString = NSString(string: markdown)
                let matches = regex.matches(in: markdown, options: [], range: NSRange(location: 0, length: nsString.length))
                
                for set in matches.enumerated() {
                    let match = set.element
                    guard match.numberOfRanges == 3 else { continue }
                    let nameRange = match.range(at: 1)
                    let urlRange = match.range(at: 2)
                    let matchingName = nsString.substring(with: nameRange)
                    let name: String
                    if matchingName.isEmpty {
                        name = "Image \(set.offset + 1)"
                    } else {
                        name = matchingName
                    }
                    let urlString = nsString.substring(with: urlRange)
                    guard let url = URL(string: urlString) else {
                        continue
                    }
                    results.append((name, url))
                }
            } catch {
                logger.error("Error while processing regex: \(String(describing: error))")
            }
            
            return results
        }
        return extractImageNamesAndURLs(from: status).map({ SharePacket(name: $0.name, content: $0.url) })
    }
    
    var linkedItems: [SharePacket] {
        webLinks.filter({ !imageLinks.contains($0) })
    }
}

public struct GroupStatusLogModel: Sendable {
    let displayTitle: String?
    let statuses: [StatusModel]
}

public struct AddressSummaryModel: BlackbirdModel, Sendable {
    
    @BlackbirdColumn
    public var id: AddressName
    @BlackbirdColumn
    public var date: Date?
    @BlackbirdColumn
    public var bio: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case date
        case bio
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._id = try container.decode(BlackbirdColumn<String>.self, forKey: .id)
        self._date = try container.decode(BlackbirdColumn<Date?>.self, forKey: .date)
        self._bio = try container.decode(BlackbirdColumn<String?>.self, forKey: .bio)
    }
    
    public init(_ row: Blackbird.ModelRow<AddressSummaryModel>) {
        self.init(
            address: row[\.$id],
            bio: row[\.$bio],
            date: row[\.$date]
        )
    }
    
    public init(address: AddressName, bio: String?, date: Date?) {
        self.id = address.punified
        self.date = date
        self.bio = bio
    }
}


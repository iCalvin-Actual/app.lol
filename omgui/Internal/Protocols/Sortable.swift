//
//  File.swift
//
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Blackbird
import SwiftUI

enum Sort: String, Identifiable {
    case alphabet
    case newestFirst
    case oldestFirst
    case shuffle
    
    var id: String { rawValue }
    
    var displayString: String {
        switch self {
        case .alphabet:
            return "alphabetical"
        case .newestFirst:
            return "recent"
        case .oldestFirst:
            return "oldest"
        case .shuffle:
            return "shuffle"
        }
    }
    
    func asClause<S: ModelBackedListable>() -> BlackbirdModelOrderClause<S> {
        switch self {
        case .newestFirst:
            return .descending(S.dateKey)
        case .oldestFirst:
            return .ascending(S.dateKey)
        case .shuffle:
            return .random(S.ownerKey)
        default:
            return .ascending(S.sortingKey)
        }
    }
}

protocol Sortable {
    static var sortOptions: [Sort] { get }
    static var defaultSort: Sort { get }
}

protocol StringSortable: Sortable {
    var primarySortValue: String { get }
}

protocol DateSortable: Sortable {
    var dateValue: Date? { get }
}

typealias AllSortable = StringSortable & DateSortable

extension Sort {
    func sorted<S: Sortable>(_ lhs: S, _ rhs: S) -> Bool {
        switch self {
        case .alphabet:
            guard let lhS = (lhs as? StringSortable)?.primarySortValue, let rhS = (rhs as? StringSortable)?.primarySortValue else {
                return false
            }
            return lhS < rhS
        case .newestFirst, .oldestFirst:
            guard let lhD = (lhs as? DateSortable)?.dateValue, let rhD = (rhs as? DateSortable)?.dateValue else {
                return false
            }
            return self == .newestFirst ? lhD > rhD : lhD < rhD
        case .shuffle:
            switch arc4random_uniform(2) {
            case 0:
                return true
            default:
                return false
            }
        }
    }
}

extension Array where Element: Sortable {
    func sorted(with sort: Sort) -> [Element] {
        self.sorted(by: sort.sorted(_:_:))
    }
}

extension AddressModel: AllSortable {
    var primarySortValue: String { addressName }
    var dateValue: Date? { date }
    
    static let defaultSort: Sort = .shuffle
    static var sortOptions: [Sort] {
        [
            .alphabet,
            .shuffle
        ]
    }
}

extension StatusModel: AllSortable {
    var primarySortValue: String { displayEmoji }
    var dateValue: Date? { date }
    
    static let defaultSort: Sort = .newestFirst
    static var sortOptions: [Sort] {
        [
            .newestFirst
        ]
    }
}

extension NowListing: AllSortable {
    var primarySortValue: String { owner }
    var dateValue: Date? { date }
    
    static let defaultSort: Sort = .newestFirst
    static var sortOptions: [Sort] {
        [
            .newestFirst,
            .shuffle,
            .oldestFirst
        ]
    }
}

extension PasteModel: StringSortable {
    var primarySortValue: String { name }
    var dateValue: Date? { date }
    
    static let defaultSort: Sort = .alphabet
    static var sortOptions: [Sort] {
        [
            .newestFirst,
            .alphabet
        ]
    }
}

extension PURLModel: StringSortable {
    var primarySortValue: String { name }
    
    static let defaultSort: Sort = .alphabet
    static var sortOptions: [Sort] {
        [
            .newestFirst,
            .alphabet
        ]
    }
}

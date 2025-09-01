//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Blackbird
import Foundation

enum FilterOption: Equatable, RawRepresentable, Identifiable {
    var id: String { rawValue }
    
    var rawValue: String {
        switch self {
        case .recent(let interval):
            return "interval.\(interval)"
        case .query(let query):
            return "query.\(query)"
        case .from(let address):
            return "from.\(address)"
        case .fromOneOf(let addresses):
            return "fromOne.\(addresses.joined(separator: "."))"
        case .none:
            return ""
        case .blocked:
            return "blocked"
        case .notBlocked:
            return "notBlocked"
        case .mine:
            return "mine"
        case .following:
            return "following"
        case .followers:
            return "followers"
        }
    }
    
    init?(rawValue: String) {
        let splitString = rawValue.components(separatedBy: ".")
        switch splitString.first {
        case "interval":
            guard splitString.count > 1 else {
                return nil
            }
            let joined = splitString.dropFirst().joined(separator: ".")
            guard let double = TimeInterval(joined) else {
                return nil
            }
            self = .recent(double)
        case "query":
            guard splitString.count > 1 else {
                return nil
            }
            let joined = splitString.dropFirst().joined(separator: ".")
            self = .query(joined)
        case "from":
            guard splitString.count > 1 else {
                return nil
            }
            let joined = splitString.dropFirst().joined(separator: ".")
            self = .from(joined)
        case "fromOne":
            guard splitString.count > 1 else {
                return nil
            }
            let joined = Array(splitString.dropFirst())
            self = .fromOneOf(joined)
        case "blocked":
            self = .blocked
        case "notBlocked":
            self = .notBlocked
        case "mine":
            self = .mine
        case "following":
            self = .following
        case "followers":
            self = .followers
        case "":
            self = .none
        default:
            return nil
        }
    }
    
    case none
    case mine
    case following
    case followers
    case blocked
    case notBlocked
    case from(AddressName)
    case fromOneOf([AddressName])
    case recent(TimeInterval)
    case query(String)
    
    var displayString: String {
        switch self {
        case .recent:
            return "Recent"
        case .notBlocked:
            return "Everyone"
        case .query:
            return "Search"
        default:
            return self.rawValue
        }
    }
    
    static var filterOptions: [FilterOption] {
        [
            .mine,
            .following,
            .followers
        ]
    }
}

extension Array<FilterOption> {
    static let none: Self               = []
    static let everyone: Self           = [.notBlocked]
    static let blocked: Self            = [.blocked]
    static let today: Self              = [.recent(86400), .notBlocked]
    static let thisWeek: Self           = [.recent(604800), .notBlocked]
    static let followed: Self           = [.following, .notBlocked]
    static let followedToday: Self      = .followed + .today
    static let followedThisWeek: Self   = .followed + .thisWeek
}

protocol Filterable {
    static var filterOptions: [FilterOption] { get }
    static var defaultFilter: [FilterOption] { get }
    
    var addressName: AddressName { get }
    var filterDate: Date? { get }
    
    @MainActor
    func include(with filter: FilterOption, with book: AddressBook) -> Bool
}

@MainActor
extension Filterable {
    func include(with filters: [FilterOption], with book: AddressBook) -> Bool {
        for filter in filters {
            if !include(with: filter, with: book) {
                return false
            }
        }
        return true
    }
}

extension Filterable where Self: DateSortable {
    var filterDate: Date? {
        dateValue
    }
}

protocol QueryFilterable: Filterable {
    
    @MainActor
    var queryCheckStrings: [String] { get }
    
    @MainActor
    func matches(_ query: String) -> Bool
}

extension QueryFilterable {
    
    @MainActor
    func matches(_ query: String) -> Bool {
        queryCheckStrings.contains(where: { $0.lowercased().contains(query.lowercased()) })
    }
}

extension Filterable {
    @MainActor
    func include(with filter: FilterOption, with book: AddressBook) -> Bool {
        switch filter {
        case .none:
            return true
        case .notBlocked:
            return !book.appliedBlocked.contains(addressName)
        case .blocked:
            return book.appliedBlocked.contains(addressName)
        case .from(let address):
            return addressName == address
        case .fromOneOf(let addresses):
            return addresses.contains(addressName)
        case .query(let query):
            guard let queryable = self as? QueryFilterable else {
                return false
            }
            if !queryable.matches(query) {
                return false
            }
        case .recent(let interval):
            guard let date = filterDate else {
                return false
            }
            if Date().timeIntervalSince(date) > interval {
                return false
            }
        case .mine:
            return book.mine.contains(addressName)
        case .following:
            return book.following.contains(addressName)
        case .followers:
            return book.followers.contains(addressName)
        }
        return true
    }
}

extension Array<FilterOption> {
    @MainActor
    func applyFilters<T: Filterable>(to inputModels: [T], with book: AddressBook) -> [T] {
        inputModels
            .filter({ $0.include(with: self, with: book) })
    }
}

extension Array<FilterOption> {
    @MainActor
    func asQuery<M: ModelBackedListable>(matchingAgainst addressBook: AddressBook) -> BlackbirdModelColumnExpression<M>? {
        var addressSet: Set<AddressName> = []
        var filters: [BlackbirdModelColumnExpression<M>] = reduce([]) { result, next in
            switch next {
            case .fromOneOf(let addresses):
                addressSet.formUnion(Set(addresses))
                return result
            case .mine:
                addressSet.formUnion(Set(addressBook.mine))
                return result
            case .following:
                addressSet.formUnion(Set(addressBook.following))
                return result
            default:
                return result + [next.asQuery(addressBook)].compactMap({ $0 })
            }
        }
        if !addressSet.isEmpty, let joined: BlackbirdModelColumnExpression<M> = FilterOption.fromOneOf(Array<AddressName>(addressSet)).asQuery(addressBook) {
            filters.append(joined)
        }
        if filters.count > 1 {
            return .combining(filters)
        } else {
            return filters.first
        }
    }
}

extension FilterOption {
    @MainActor
    func asQuery<M: ModelBackedListable>(_ adderessBook: AddressBook) -> BlackbirdModelColumnExpression<M>? {
        switch self {
        case .mine:
            return BlackbirdModelColumnExpression<M>
                .valueIn(M.ownerKey, adderessBook.mine)
        case .following:
            return .valueIn(M.ownerKey, adderessBook.following)
        case .followers:
            return .valueIn(M.ownerKey, adderessBook.followers)
        case .blocked:
            return .valueIn(M.ownerKey, adderessBook.blocked)
        case .notBlocked:
            return .valueNotIn(M.ownerKey, adderessBook.appliedBlocked)
        case .from(let address):
            return .equals(M.ownerKey, address)
        case .fromOneOf(let addresses):
            return .valueIn(M.ownerKey, addresses)
        case .recent(let interval):
            return .greaterThanOrEqual(M.dateKey, Date(timeIntervalSinceNow: -interval))
        case .query(let queryString):
            return .oneOf(M.fullTextSearchableColumns.compactMap({
                if case .text = $0.value {
                    return .like($0.key, "%\(queryString)%")
                }
                return nil
            }))
        default:
            return nil
        }
    }
}

//
//  FilterOption.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/11/25.
//

import Blackbird
import Foundation

enum FilterOption: Equatable, RawRepresentable, Identifiable {
    var id: String { rawValue }
    
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
    
    var rawValue: String {
        switch self {
        case .none:         return ""
        case .blocked:      return "blocked"
        case .notBlocked:   return "notBlocked"
        case .mine:         return "mine"
        case .following:    return "following"
        case .followers:    return "followers"
        case .recent(let interval):
            return "interval.\(interval)"
        case .query(let query):
            return "query.\(query)"
        case .from(let address):
            return "from.\(address)"
        case .fromOneOf(let addresses):
            return "fromOne.\(addresses.joined(separator: "."))"
        }
    }
    
    init?(rawValue: String) {
        let splitString = rawValue.components(separatedBy: ".")
        switch splitString.first {
        case "blocked":     self = .blocked
        case "notBlocked":  self = .notBlocked
        case "mine":        self = .mine
        case "following":   self = .following
        case "followers":   self = .followers
        case "interval":
            guard splitString.count > 1 else { return nil }
            let joined = splitString.dropFirst().joined(separator: ".")
            guard let double = TimeInterval(joined) else { return nil }
            
            self = .recent(double)
        case "query":
            guard splitString.count > 1 else { return nil }
            let joined = splitString.dropFirst().joined(separator: ".")
            
            self = .query(joined)
        case "from":
            guard splitString.count > 1 else { return nil }
            let joined = splitString.dropFirst().joined(separator: ".")
            
            self = .from(joined)
        case "fromOne":
            guard splitString.count > 1 else { return nil }
            let joined = Array(splitString.dropFirst())
            
            self = .fromOneOf(joined)
            
        case "":            self = .none
        default:            return nil
        }
    }
    
    var displayString: String {
        switch self {
        case .recent:       return "Recent"
        case .notBlocked:   return "Everyone"
        case .query:        return "Search"
        default:            return self.rawValue
        }
    }
}

extension FilterOption {
    @MainActor
    func asQuery<M: BlackbirdListable>(_ adderessBook: AddressBook) -> BlackbirdModelColumnExpression<M>? {
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

extension Array<FilterOption> {
    static let none: Self               = []
    static let everyone: Self           = [.notBlocked]
    static let blocked: Self            = [.blocked]
    static let today: Self              = [.recent(86400), .notBlocked]
    static let thisWeek: Self           = [.recent(604800), .notBlocked]
    static let followed: Self           = [.following, .notBlocked]
    static let followedToday: Self      = .followed + .today
    static let followedThisWeek: Self   = .followed + .thisWeek
    
    @MainActor
    func asQuery<M: BlackbirdListable>(matchingAgainst addressBook: AddressBook) -> BlackbirdModelColumnExpression<M>? {
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

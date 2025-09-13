//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Blackbird
import Foundation

protocol Filterable {
    static var filterOptions: [FilterOption] { get }
    static var defaultFilter: [FilterOption] { get }
    
    @MainActor
    var queryCheckStrings: [String] { get }
    
    var addressName: AddressName { get }
    var filterDate: Date? { get }
    
    @MainActor
    func include(with filter: FilterOption, with book: AddressBook) -> Bool
}

@MainActor
extension Filterable {
    @MainActor
    var queryCheckStrings: [String] { [] }
    
    func include(with filters: [FilterOption], with book: AddressBook) -> Bool {
        for filter in filters {
            if !include(with: filter, with: book) {
                return false
            }
        }
        return true
    }
    
    @MainActor
    func matches(_ query: String) -> Bool {
        queryCheckStrings.contains(where: { $0.lowercased().contains(query.lowercased()) })
    }
}

extension Filterable where Self: DateSortable {
    var filterDate: Date? { dateValue }
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
            if self.matches(query) {
                return true
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

extension AddressModel: Filterable {
    static var defaultFilter: [FilterOption] { .everyone }
    static var filterOptions: [FilterOption] {[ .mine, .following ]}
    
    var addressName: AddressName    { owner }
    var filterDate: Date?           { date }
    var queryCheckStrings: [String] {
        [addressName]
    }
}

extension NowListing: Filterable {
    static var defaultFilter: [FilterOption] { .everyone }
    static var filterOptions: [FilterOption] {[ .mine, .following ]}
    
    var addressName: AddressName { owner }
    var filterDate: Date? { date }
    var queryCheckStrings: [String] {
        [addressName]
    }
}

extension PasteModel: Filterable {
    static var defaultFilter: [FilterOption] { .everyone }
    static var filterOptions: [FilterOption] {[ .mine, .following ]}
    
    var addressName: AddressName { owner }
    var filterDate: Date? { date }
    var queryCheckStrings: [String] {
        [addressName, name, content]
            .compactMap({ $0 })
    }
}

extension PURLModel: Filterable {
    static var defaultFilter: [FilterOption] { .everyone }
    static var filterOptions: [FilterOption] {[ .mine, .following ]}
    
    var addressName: AddressName { owner }
    var filterDate: Date? { nil }
    var queryCheckStrings: [String] {
        [addressName, name, content]
            .compactMap({ $0 })
    }
}

extension StatusModel: Filterable {
    static var defaultFilter: [FilterOption] { .everyone }
    static var filterOptions: [FilterOption] {[ .mine, .following ]}
    
    var addressName: AddressName { owner }
    var filterDate: Date? { date }
    var queryCheckStrings: [String] {
        [addressName, emoji, status]
            .compactMap({ $0 })
    }
}

extension PicModel: Filterable {
    static var defaultFilter: [FilterOption] { .everyone }
    static var filterOptions: [FilterOption] {[ .mine, .following ]}
    
    var addressName: AddressName { owner }
    var filterDate: Date? { nil }
    var queryCheckStrings: [String] {
        [addressName, description]
            .compactMap({ $0 })
    }
}

extension Array<FilterOption> {
    @MainActor
    func applyFilters<T: Filterable>(to inputModels: [T], with book: AddressBook) -> [T] {
        inputModels
            .filter({ $0.include(with: self, with: book) })
    }
}

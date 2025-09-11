//
//  File.swift
//
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Blackbird
import SwiftUI

typealias AllSortable = StringSortable & DateSortable

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

extension Array where Element: Sortable {
    func sorted(with sort: Sort) -> [Element] {
        self.sorted(by: sort.sorted(_:_:))
    }
}

extension AddressModel: AllSortable {
    var primarySortValue: String { addressName }
    var dateValue: Date? { date }
    
    static let defaultSort: Sort = .alphabet
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

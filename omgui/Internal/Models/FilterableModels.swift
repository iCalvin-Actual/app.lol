//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 8/3/24.
//

import Foundation


extension AddressModel: QueryFilterable {
    static var defaultFilter: [FilterOption] {
        .everyone
    }
    static var filterOptions: [FilterOption] {
        [
            .mine,
            .following
        ]
    }
    
    var queryCheckStrings: [String] {
        [addressName]
    }
    
    var addressName: AddressName {
        owner
    }
    
    var filterDate: Date? {
        date
    }
}

extension NowListing: QueryFilterable {
    static var defaultFilter: [FilterOption] {
        .everyone
    }
    static var filterOptions: [FilterOption] {
        [
            .mine,
            .following
        ]
    }
    var queryCheckStrings: [String] {
        [addressName]
    }
    
    var addressName: AddressName {
        owner
    }
    
    var filterDate: Date? {
        date
    }
}

extension PasteModel: QueryFilterable {
    static var defaultFilter: [FilterOption] {
        .everyone
    }
    static var filterOptions: [FilterOption] {
        [
            .mine,
            .following
        ]
    }
    var queryCheckStrings: [String] {
        [addressName, name, content]
            .compactMap({ $0 })
    }
    
    var addressName: AddressName {
        owner
    }
    
    var filterDate: Date? {
        nil
    }
}

extension PURLModel: QueryFilterable {
    static var defaultFilter: [FilterOption] {
        .everyone
    }
    static var filterOptions: [FilterOption] {
        [
            .mine,
            .following
        ]
    }
    var queryCheckStrings: [String] {
        [addressName, name, content]
            .compactMap({ $0 })
    }
    
    var addressName: AddressName {
        owner
    }
    
    var filterDate: Date? {
        nil
    }
}

extension StatusModel: QueryFilterable {
    static var defaultFilter: [FilterOption] {
        .everyone
    }
    static var filterOptions: [FilterOption] {
        [
            .mine,
            .following
        ]
    }
    var queryCheckStrings: [String] {
        [addressName, emoji, status]
            .compactMap({ $0 })
    }
    
    var addressName: AddressName {
        owner
    }
    
    var filterDate: Date? {
        date
    }
}

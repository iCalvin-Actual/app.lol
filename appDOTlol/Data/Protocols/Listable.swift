//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Blackbird
import Foundation

protocol Listable: Filterable, Sortable, Menuable, Hashable, Identifiable {
    var listTitle: String    { get }
    var listSubtitle: String { get }
    var listCaption: String? { get }
    var displayDate: Date?   { get }
    func rowDestination(detailPage: Bool) -> NavigationDestination
}
extension Listable {
    func rowDestination(detail: Bool = false) -> NavigationDestination {
        rowDestination(detailPage: detail)
    }
}

extension Listable {
    var displayDate: Date? { nil }
    
    var listCaption: String? {
        guard let date = displayDate else {
            return nil
        }
        if Date().timeIntervalSince(date) < (60 * 60 * 24 * 7) {
            return DateFormatter.relative.string(for: date) ?? DateFormatter.shortDate.string(from: date)
        } else {
            return DateFormatter.shortDate.string(from: date)
        }
    }
}

extension AddressModel {
    var listTitle: String { addressName.addressDisplayString }
    var listSubtitle: String { url?.absoluteString ?? "" }
    var displayDate: Date?    { date }
    
    func rowDestination(detailPage: Bool = false) -> NavigationDestination { .address(addressName, page: .profile) }
}
extension StatusModel     {
    var listTitle: String     { status }
    var listSubtitle: String  { owner.addressDisplayString }
    var displayDate: Date?    { date }
    var listCaption: String?  { DateFormatter.short.string(for: date) }
    func rowDestination(detailPage: Bool = false) -> NavigationDestination { .status(owner, id: id) }
}
extension PasteModel     {
    var listTitle: String     { name }
    var listSubtitle: String  { String(content.prefix(42)) }
    var displayDate: Date?    { date }
    var listCaption: String?  { DateFormatter.relative.string(for: date) ?? DateFormatter.short.string(for: date) }
    func rowDestination(detailPage: Bool = false) -> NavigationDestination { .paste(owner, id: name) }
}
extension PURLModel     {
    var listTitle: String     { name }
    var listSubtitle: String  { content }
    func rowDestination(detailPage: Bool = false) -> NavigationDestination { .purl(owner, id: name) }
}
extension NowListing     {
    var listTitle: String     { owner.addressDisplayString }
    var listSubtitle: String  { url.replacingOccurrences(of: "https://", with: "") }
    var displayDate: Date?    { date }
    func rowDestination(detailPage: Bool = false) -> NavigationDestination {
        if detailPage {
            .now(owner)
        } else {
            .address(owner, page: .now)
        }
    }
}

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
    var iconURL: URL?        { get }
    var rowDestination: NavigationDestination { get }
}

extension Listable {
    var hideIcon: Bool {
        iconURL == nil && !addressName.isEmpty
    }
}

extension Listable {
    var displayDate: Date? { nil }
    var iconURL: URL? { nil }
    
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
    var iconURL: URL? { addressName.addressIconURL }
    var rowDestination: NavigationDestination { .address(addressName) }
}
extension StatusModel     {
    var listTitle: String     { status }
    var listSubtitle: String  { owner.addressDisplayString }
    var displayDate: Date?    { date }
    var listCaption: String?  { DateFormatter.short.string(for: date) }
    var rowDestination: NavigationDestination { .status(owner, id: status.id) }
}
extension PasteModel     {
    var listTitle: String     { name }
    var listSubtitle: String  { String(content.prefix(42)) }
    var listCaption: String?  { DateFormatter.relative.string(for: date) ?? DateFormatter.short.string(for: date) }
    var rowDestination: NavigationDestination { .paste(owner, id: name) }
}
extension PURLModel     {
    var listTitle: String     { name }
    var listSubtitle: String  { content }
    var listCaption: String?  { DateFormatter.relative.string(for: date) ?? DateFormatter.short.string(for: date) }
    var rowDesetination: NavigationDestination { .purl(owner, id: name) }
}
extension NowListing     {
    var listTitle: String     { owner.addressDisplayString }
    var listSubtitle: String  { url.replacingOccurrences(of: "https://", with: "") }
    var displayDate: Date?    { date }
    var hideIcon: Bool { false }
    var rowDestination: NavigationDestination { .now(owner) }
}

extension AddressIconModel {
    var listTitle: String { "" }
    var listSubtitle: String {
        ""
    }
    var displayDate: Date? {
        nil
    }
    var hideIcon: Bool { false }
    var rowDestination: NavigationDestination { .address(self.id) }
}

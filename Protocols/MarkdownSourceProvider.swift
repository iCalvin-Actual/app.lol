//
//  MarkdownSourceProvider.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/14/25.
//

import Foundation

@MainActor
protocol MarkdownSourceProvider {
    var address: String { get }
    var updated: Date? { get }
}

extension AddressNowFetcher: MarkdownSourceProvider {
    var updated: Date? { result?.date }
    var address: String { addressName }
}

extension StatusModel: MarkdownSourceProvider {
    var address: String { owner }
    var updated: Date? { dateValue }
}

extension PasteModel: MarkdownSourceProvider {
    var address: String { owner }
    var updated: Date? { nil }
}

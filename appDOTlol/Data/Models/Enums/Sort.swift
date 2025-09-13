//
//  Sort.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/11/25.
//

import Blackbird
import Foundation

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
    
    func asClause<S: BlackbirdListable>() -> BlackbirdModelOrderClause<S> {
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
    
extension Sort {
    func sorted<S: Sortable>(_ lhs: S, _ rhs: S) -> Bool {
        switch self {
        case .alphabet:
            guard let lhS = (lhs as? StringSortable)?.primarySortValue, let rhS = (rhs as? StringSortable)?.primarySortValue else {
                return false
            }
            switch (lhS.isEmpty, rhS.isEmpty) {
            case (false, true):
                return true
            case (true, false):
                return false
            default:
                return lhS < rhS
            }
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

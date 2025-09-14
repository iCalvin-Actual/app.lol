//
//  SearchResult.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/14/25.
//

import Foundation


enum SearchResult: AllSortable, Identifiable {
    static let sortOptions: [Sort] = [.newestFirst, .oldestFirst, .alphabet]
    
    static let defaultSort: Sort = .newestFirst
    
    case address(AddressModel)
    case status(StatusModel)
    case paste(PasteModel)
    case purl(PURLModel)
    case pic(PicModel)
    
    var owner: AddressName {
        switch self {
        case .address(let model):
            return model.addressName
        case .status(let model):
            return model.addressName
        case .paste(let model):
            return model.addressName
        case .purl(let model):
            return model.addressName
        case .pic(let model):
            return model.addressName
        }
    }
    
    var id: String {
        switch self {
        case .address(let model):
            return NavigationDestination.address(model.addressName, page: .profile).rawValue
        case .status(let model):
            return NavigationDestination.status(model.addressName, id: model.id).rawValue
        case .paste(let model):
            return NavigationDestination.paste(model.addressName, id: model.name).rawValue
        case .purl(let model):
            return NavigationDestination.purl(model.addressName, id: model.name).rawValue
        case .pic(let model):
            return NavigationDestination.pic(model.addressName, id: model.id).rawValue
        }
    }
    
    var dateValue: Date? {
        switch self {
        case .address(let model):
            return model.dateValue
        case .status(let model):
            return model.dateValue
        case .paste(let model):
            return model.dateValue
        case .purl(let model):
            return model.filterDate
        case .pic(let model):
            return model.filterDate
        }
    }
    
    var primarySortValue: String {
        switch self {
        case .address(let model):
            return model.addressName
        case .status(let model):
            return model.displayEmoji
        case .paste(let model):
            return model.name
        case .purl(let model):
            return model.name
        case .pic(let model):
            return model.owner
        }
    }
    
    var typeText: String {
        switch self {
        case .address: return "Address"
        case .paste: return "Paste"
        case .purl: return "Purl"
        case .status: return "Status"
        case .pic: return "Pic"
        }
    }
}

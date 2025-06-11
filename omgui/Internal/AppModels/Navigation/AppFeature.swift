//
//  AppFeature.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import Foundation

enum AppFeature: String {
    case now
    case paste
    case photo
    case purl
    case service
    case status
    case weblog
    
    var displayName: String {
        switch self {
        case .now:
            return "/now"
        case .paste:
            return "/pastebin"
        case .photo:
            return "/pics"
        case .purl:
            return "/purls"
        case .service:
            return "omg.lol"
        case .status:
            return "statuslog"
        case .weblog:
            return "/blog"
        }
    }
}

//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import Blackbird
import SwiftUI


enum ViewContext {
    case column
    case detail
    case profile
}
extension EnvironmentValues {
    var viewContext: ViewContext {
        get { self[ViewContextKey.self] }
        set { self[ViewContextKey.self] = newValue }
    }
}
struct ViewContextKey: EnvironmentKey {
    static var defaultValue: ViewContext {
        .column
    }
}

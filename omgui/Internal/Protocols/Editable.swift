//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 4/30/23.
//

import Foundation
import SwiftUI

protocol Editable: AddressManagable {
    var editingDestination: NavigationDestination { get }
}

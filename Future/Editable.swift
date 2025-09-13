//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 4/30/23.
//

import Foundation
import SwiftUI

protocol Editable: Manageable {
    var editingDestination: NavigationDestination { get }
}

@MainActor
extension Menuable {
    @ViewBuilder
    func editingSection(with addressBook: AddressBook) -> some View { }
}

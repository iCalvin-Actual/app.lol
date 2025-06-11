//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 8/3/24.
//

import Foundation

extension AddressModel: AddressManagable { }
extension NowListing: AddressManagable { }

extension PURLModel: Editable {
    var editingDestination: NavigationDestination {
        .purl(addressName, id: name)
    }
}

extension PasteModel: Editable {
    var editingDestination: NavigationDestination {
        .paste(owner, id: name)
    }
}

extension StatusModel: Editable {
    var editingDestination: NavigationDestination {
        .status(owner, id: id)
    }
}

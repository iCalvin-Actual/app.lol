//
//  AppActions.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/11/25.
//

import Foundation

typealias ContextMenuClosures = (
    navigate: (NavigationDestination) -> Void,
    follow: (AddressName) -> Void,
    block: (AddressName) -> Void,
    pin: (AddressName) -> Void,
    unFollow: (AddressName) -> Void,
    unBlock: (AddressName) -> Void,
    unPin: (AddressName) -> Void
)

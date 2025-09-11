//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 9/18/24.
//

import Blackbird
import SwiftUI
import Foundation

nonisolated
struct AddressBook: Equatable, Hashable {
    let auth: APICredential
    let me: AddressName
    let mine: [AddressName]
    let following: [AddressName]
    let followers: [AddressName]
    let pinned: [AddressName]
    let blocked: [AddressName]
    let appliedBlocked: [AddressName]
    
    static func ==(lhs: AddressBook, rhs: AddressBook) -> Bool {
        func namedEqual(lhs: [AddressName], rhs: [AddressName]) -> Bool {
            lhs.sorted() == rhs.sorted()
        }
        
        return lhs.auth == rhs.auth &&
        lhs.me == rhs.me &&
        namedEqual(lhs: lhs.mine, rhs: rhs.mine) &&
        namedEqual(lhs: lhs.following, rhs: rhs.following) &&
        namedEqual(lhs: lhs.followers, rhs: rhs.followers) &&
        namedEqual(lhs: lhs.pinned, rhs: rhs.pinned) &&
        namedEqual(lhs: lhs.blocked, rhs: rhs.blocked) &&
        namedEqual(lhs: lhs.appliedBlocked, rhs: rhs.appliedBlocked)
    }
    
    init(
        auth: APICredential = "",
        me: AddressName = "",
        mine: [AddressName] = [],
        following: [AddressName] = [],
        followers: [AddressName] = [],
        pinned: [AddressName] = [],
        blocked: [AddressName] = [],
        appliedBlocked: [AddressName] = []
    ) {
        self.auth = auth
        self.me = me
        self.mine = mine
        self.following = following
        self.followers = followers
        self.pinned = pinned
        self.blocked = blocked
        self.appliedBlocked = appliedBlocked
    }
    
    var signedIn: Bool {
        !auth.isEmpty
    }
}

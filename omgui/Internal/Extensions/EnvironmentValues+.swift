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
typealias ProfileCache = NSCache<NSString, AddressSummaryDataFetcher>
typealias PrivateCache = NSCache<NSString, AddressPrivateSummaryDataFetcher>
struct ViewContextKey: EnvironmentKey {
    static var defaultValue: ViewContext {
        .column
    }
}
struct CacheKey: EnvironmentKey {
    static var defaultValue: ProfileCache {
        .init()
    }
}
struct PrivateCacheKey: EnvironmentKey {
    static var defaultValue: PrivateCache {
        .init()
    }
}
struct SearchActiveKey: EnvironmentKey {
    static var defaultValue: Bool {
        false
    }
}

struct InterfaceKey: EnvironmentKey {
    static var defaultValue: DataInterface {
        SampleData()
    }
}

struct ClientKey: EnvironmentKey {
    static var defaultValue: ClientInfo {
        .init(id: "", secret: "", scheme: "", callback: "")
    }
}
struct DatabaseKey: EnvironmentKey {
    static var defaultValue: Blackbird.Database {
        try! .inMemoryDatabase()
    }
}
struct ShowAddressPageKey: EnvironmentKey {
    static var defaultValue: ((AddressContent) -> Void) {
        { _ in }
    }
}
struct ShowAddressKey: EnvironmentKey {
    static var defaultValue: ((AddressName) -> Void)? {
        nil
    }
}
struct AddressFetcherKey: EnvironmentKey {
    static var defaultValue: AccountAddressDataFetcher {
        .init(credential: "", interface: AppClient.interface)
    }
}
struct GlobalBlockedFetcherKey: EnvironmentKey {
    static var defaultValue: AddressBlockListDataFetcher {
        .init(address: "app", credential: "", interface: AppClient.interface)
    }
}
struct LocalBlockedFetcherKey: EnvironmentKey {
    static var defaultValue: LocalBlockListDataFetcher {
        .init(interface: AppClient.interface)
    }
}
struct PinnedFetcherKey: EnvironmentKey {
    static var defaultValue: PinnedListDataFetcher {
        .init(interface: AppClient.interface)
    }
}
struct AddressBookKey: EnvironmentKey {
    static var defaultValue: AddressBook? {
        nil
    }
}
struct GlobalDirectoryView: EnvironmentKey {
    static var defaultValue: GlobalAddressDirectoryFetcher? {
        nil
    }
}
struct GlobalGardenKey: EnvironmentKey {
    static var defaultValue: GlobalNowGardenFetcher? {
        nil
    }
}
struct GlobalStatusLogKey: EnvironmentKey {
    static var defaultValue: GlobalStatusLogFetcher? {
        nil
    }
}
struct GlobalSupportKey: EnvironmentKey {
    static var defaultValue: AppSupportFetcher? {
        nil
    }
}
struct GlobalAppStatusKey: EnvironmentKey {
    static var defaultValue: AppLatestFetcher? {
        nil
    }
}
struct VisibleAddressKey: EnvironmentKey {
    static var defaultValue: AddressName {
        ""
    }
}
struct VisibleAddressPageKey: EnvironmentKey {
    static var defaultValue: AddressContent {
        .profile
    }
}
struct LoginKey: EnvironmentKey {
    static var defaultValue: () -> Void { { } }
}
struct LogoutKey: EnvironmentKey {
    static var defaultValue: () -> Void { { } }
}
struct DestinationConstructorKey: EnvironmentKey {
    static var defaultValue: DestinationConstructor? {
        nil
    }
}
struct UpdateAddressKey: EnvironmentKey {
    static var defaultValue: (AddressName) -> Void { { _ in } }
}

extension EnvironmentValues {
    var viewContext: ViewContext {
        get { self[ViewContextKey.self] }
        set { self[ViewContextKey.self] = newValue }
    }
    var profileCache: ProfileCache {
        get { self[CacheKey.self] }
        set { self[CacheKey.self] = newValue }
    }
    var privateCache: PrivateCache {
        get { self[PrivateCacheKey.self] }
        set { self[PrivateCacheKey.self] = newValue }
    }
    var searchActive: Bool {
        get { self[SearchActiveKey.self] }
        set { self[SearchActiveKey.self] = newValue }
    }
    var apiInterface: DataInterface {
        get { self[InterfaceKey.self] }
        set { self[InterfaceKey.self] = newValue }
    }
    var omgClient: ClientInfo {
        get { self[ClientKey.self] }
        set { self[ClientKey.self] = newValue }
    }
    var blackbird: Blackbird.Database {
        get { self[DatabaseKey.self] }
        set { self[DatabaseKey.self] = newValue }
    }
    var presentAddress: ((AddressName) -> Void)? {
        get { self[ShowAddressKey.self] }
        set { self[ShowAddressKey.self] = newValue }
    }
    var addressFetcher: AccountAddressDataFetcher {
        get { self[AddressFetcherKey.self] }
        set { self[AddressFetcherKey.self] = newValue }
    }
    var globalBlocklist: AddressBlockListDataFetcher {
        get { self[GlobalBlockedFetcherKey.self] }
        set { self[GlobalBlockedFetcherKey.self] = newValue }
    }
    var localBlocklist: LocalBlockListDataFetcher {
        get { self[LocalBlockedFetcherKey.self] }
        set { self[LocalBlockedFetcherKey.self] = newValue }
    }
    var pinnedFetcher: PinnedListDataFetcher {
        get { self[PinnedFetcherKey.self] }
        set { self[PinnedFetcherKey.self] = newValue }
    }
    var addressBook: AddressBook? {
        get { self[AddressBookKey.self] }
        set { self[AddressBookKey.self] = newValue }
    }
    var globalDirectoryFetcher: GlobalAddressDirectoryFetcher? {
        get { self[GlobalDirectoryView.self] }
        set { self[GlobalDirectoryView.self] = newValue }
    }
    var globalGardenFetcher: GlobalNowGardenFetcher? {
        get { self[GlobalGardenKey.self] }
        set { self[GlobalGardenKey.self] = newValue }
    }
    var globalStatusLogFetcher: GlobalStatusLogFetcher? {
        get { self[GlobalStatusLogKey.self] }
        set { self[GlobalStatusLogKey.self] = newValue }
    }
    var appSupportFetcher: AppSupportFetcher? {
        get { self[GlobalSupportKey.self] }
        set { self[GlobalSupportKey.self] = newValue }
    }
    var appLatestFetcher: AppLatestFetcher? {
        get { self[GlobalAppStatusKey.self] }
        set { self[GlobalAppStatusKey.self] = newValue }
    }
    var visibleAddress: AddressName {
        get { self[VisibleAddressKey.self] }
        set { self[VisibleAddressKey.self] = newValue }
    }
    var visibleAddressPage: AddressContent {
        get { self[VisibleAddressPageKey.self] }
        set { self[VisibleAddressPageKey.self] = newValue }
    }
    var login: () -> Void {
        get { self[LoginKey.self] }
        set { self[LoginKey.self] = newValue }
    }
    var logout: () -> Void {
        get { self[LogoutKey.self] }
        set { self[LogoutKey.self] = newValue }
    }
    var destinationConstructor: DestinationConstructor? {
        get { self[DestinationConstructorKey.self] }
        set { self[DestinationConstructorKey.self] = newValue }
    }
    var setAddress: (AddressName) -> Void {
        get { self[UpdateAddressKey.self] }
        set { self[UpdateAddressKey.self] = newValue }
    }
    var showAddressPage: (AddressContent) -> Void {
        get { self[ShowAddressPageKey.self] }
        set { self[ShowAddressPageKey.self] = newValue }
    }
}

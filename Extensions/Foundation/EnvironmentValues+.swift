//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import Blackbird
import SwiftUI



extension EnvironmentValues {
    var addressBook: AddressBook {
        get { self[AddressBookKey.self] }
        set { self[AddressBookKey.self] = newValue }
    }
    var destinationConstructor: SceneModel? {
        get { self[SceneModelKey.self] }
        set { self[SceneModelKey.self] = newValue }
    }
    var addressSummaryFetcher: (AddressName) -> AddressSummaryFetcher? {
        get { self[AddressSummaryFetcherKey.self] }
        set { self[AddressSummaryFetcherKey.self] = newValue }
    }
    var authenticate: (APICredential) -> Void {
        get { self[AuthenticateKey.self] }
        set { self[AuthenticateKey.self] = newValue }
    }
    var blockAddress: (AddressName) -> Void {
        get { self[BlockAddressKey.self] }
        set { self[BlockAddressKey.self] = newValue }
    }
    var unblockAddress: (AddressName) -> Void {
        get { self[UnblockAddressKey.self] }
        set { self[UnblockAddressKey.self] = newValue }
    }
    var credentialFetcher: (AddressName) -> APICredential? {
        get { self[CredentialFetcherKey.self] }
        set { self[CredentialFetcherKey.self] = newValue }
    }
    var blackbird: Blackbird.Database {
        get { self[DatabaseKey.self] }
        set { self[DatabaseKey.self] = newValue }
    }
    var followAddress: (AddressName) -> Void {
        get { self[FollowAddressKey.self] }
        set { self[FollowAddressKey.self] = newValue }
    }
    var unfollowAddress: (AddressName) -> Void {
        get { self[UnfollowAddressKey.self] }
        set { self[UnfollowAddressKey.self] = newValue }
    }
    var appLatestFetcher: AppLatestFetcher? {
        get { self[GlobalAppStatusKey.self] }
        set { self[GlobalAppStatusKey.self] = newValue }
    }
    var globalBlocklist: AddressBlockListFetcher? {
        get { self[GlobalBlockedFetcherKey.self] }
        set { self[GlobalBlockedFetcherKey.self] = newValue }
    }
    var globalDirectoryFetcher: GlobalAddressDirectoryFetcher? {
        get { self[GlobalDirectoryKey.self] }
        set { self[GlobalDirectoryKey.self] = newValue }
    }
    var globalStatusLogFetcher: GlobalStatusLogFetcher? {
        get { self[GlobalStatusLogKey.self] }
        set { self[GlobalStatusLogKey.self] = newValue }
    }
    var appSupportFetcher: AppSupportFetcher? {
        get { self[GlobalSupportKey.self] }
        set { self[GlobalSupportKey.self] = newValue }
    }
    var apiInterface: OMGInterface {
        get { self[InterfaceKey.self] }
        set { self[InterfaceKey.self] = newValue }
    }
    var localBlocklist: LocalBlockListFetcher? {
        get { self[LocalBlockedFetcherKey.self] }
        set { self[LocalBlockedFetcherKey.self] = newValue }
    }
    var searchQuery: String {
        get { self[SearchQueryEnvironmentKey.self] }
        set { self[SearchQueryEnvironmentKey.self] = newValue }
    }
    var pinnedFetcher: PinnedListFetcher? {
        get { self[PinnedFetcherKey.self] }
        set { self[PinnedFetcherKey.self] = newValue }
    }
    var pinAddress: (AddressName) -> Void {
        get { self[PinAddressKey.self] }
        set { self[PinAddressKey.self] = newValue }
    }
    var unpinAddress: (AddressName) -> Void {
        get { self[UnpinAddressKey.self] }
        set { self[UnpinAddressKey.self] = newValue }
    }
    var presentListable: ((NavigationDestination) -> Void)? {
        get { self[PresentListableKey.self] }
        set { self[PresentListableKey.self] = newValue }
    }
    var avatarCache: AvatarCache {
        get { self[AddressIconKey.self] }
        set { self[AddressIconKey.self] = newValue }
    }
    var picCache: ImageCache {
        get { self[PicCacheKey.self] }
        set { self[PicCacheKey.self] = newValue }
    }
    var profileCache: ProfileCache {
        get { self[PublieCacheKey.self] }
        set { self[PublieCacheKey.self] = newValue }
    }
    var privateCache: PrivateCache {
        get { self[PrivateCacheKey.self] }
        set { self[PrivateCacheKey.self] = newValue }
    }
    var searchActive: Bool {
        get { self[SearchActiveKey.self] }
        set { self[SearchActiveKey.self] = newValue }
    }
    var showAddressPage: (AddressContent) -> Void {
        get { self[ShowAddressPageKey.self] }
        set { self[ShowAddressPageKey.self] = newValue }
    }
    var setAddress: (AddressName) -> Void {
        get { self[UpdateAddressKey.self] }
        set { self[UpdateAddressKey.self] = newValue }
    }
    var searchFilters: Set<SearchView.SearchFilter> {
        get { self[SearchFilterKey.self] }
        set { self[SearchFilterKey.self] = newValue }
    }
    var setSearchFilters: (Set<SearchView.SearchFilter>) -> Void {
        get { self[UpdateSearchFilterKey.self] }
        set { self[UpdateSearchFilterKey.self] = newValue }
    }
    var setVisibleAddress: (AddressName?) -> Void {
        get { self[UpdateVisibleAddressKey.self] }
        set { self[UpdateVisibleAddressKey.self] = newValue }
    }
    var visibleAddress: AddressName? {
        get { self[VisibleAddressKey.self] }
        set { self[VisibleAddressKey.self] = newValue }
    }
    var visibleAddressPage: AddressContent {
        get { self[VisibleAddressPageKey.self] }
        set { self[VisibleAddressPageKey.self] = newValue }
    }
    var viewContext: ViewContext {
        get { self[ViewContextKey.self] }
        set { self[ViewContextKey.self] = newValue }
    }
}

fileprivate struct SceneModelKey: EnvironmentKey {
    static var defaultValue: SceneModel? { nil }
}
fileprivate struct AddressBookKey: EnvironmentKey {
    static var defaultValue: AddressBook { .init() }
}
fileprivate struct AuthenticateKey: EnvironmentKey {
    static var defaultValue: (APICredential) -> Void { { _ in } }
}
fileprivate struct BlockAddressKey: EnvironmentKey {
    static var defaultValue: (AddressName) -> Void { { _ in } }
}
fileprivate struct UnblockAddressKey: EnvironmentKey {
    static var defaultValue: (AddressName) -> Void { { _ in } }
}
fileprivate struct CredentialFetcherKey: EnvironmentKey {
    static var defaultValue: (AddressName) -> APICredential? { { _ in nil } }
}
fileprivate struct DatabaseKey: EnvironmentKey {
    static var defaultValue: Blackbird.Database { AppClient.database }
}
fileprivate struct FollowAddressKey: EnvironmentKey {
    static var defaultValue: (AddressName) -> Void { { _ in } }
}
fileprivate struct UnfollowAddressKey: EnvironmentKey {
    static var defaultValue: (AddressName) -> Void { { _ in } }
}
fileprivate struct GlobalAppStatusKey: EnvironmentKey {
    static var defaultValue: AppLatestFetcher? { nil }
}
fileprivate struct GlobalBlockedFetcherKey: EnvironmentKey {
    static var defaultValue: AddressBlockListFetcher? { nil }
}
fileprivate struct GlobalDirectoryKey: EnvironmentKey {
    static var defaultValue: GlobalAddressDirectoryFetcher? { nil }
}
fileprivate struct GlobalStatusLogKey: EnvironmentKey {
    static var defaultValue: GlobalStatusLogFetcher? { nil }
}
fileprivate struct GlobalSupportKey: EnvironmentKey {
    static var defaultValue: AppSupportFetcher? { nil }
}
fileprivate struct AddressSummaryFetcherKey: EnvironmentKey {
    static var defaultValue: (AddressName) -> AddressSummaryFetcher? {
        { _ in return nil }
    }
}
fileprivate struct SearchFilterKey: EnvironmentKey {
    static var defaultValue: Set<SearchView.SearchFilter> { [] }
}
fileprivate struct UpdateSearchFilterKey: EnvironmentKey {
    static var defaultValue: (Set<SearchView.SearchFilter>) -> Void { { _ in } }
}
fileprivate struct UpdateVisibleAddressKey: EnvironmentKey {
    static var defaultValue: (AddressName?) -> Void { { _ in } }
}
fileprivate struct VisibleAddressKey: EnvironmentKey {
    static var defaultValue: AddressName? { "" }
}
fileprivate struct VisibleAddressPageKey: EnvironmentKey {
    static var defaultValue: AddressContent { .profile }
}
fileprivate struct ViewContextKey: EnvironmentKey {
    static var defaultValue: ViewContext { .column }
}
fileprivate struct InterfaceKey: EnvironmentKey {
    static var defaultValue: OMGInterface { SampleData() }
}
fileprivate struct LocalBlockedFetcherKey: EnvironmentKey {
    static var defaultValue: LocalBlockListFetcher? { nil }
}
fileprivate struct SearchQueryEnvironmentKey: EnvironmentKey {
    static var defaultValue: String {
        ""
    }
}
fileprivate struct PinnedFetcherKey: EnvironmentKey {
    static var defaultValue: PinnedListFetcher? {
        nil
    }
}
fileprivate struct PinAddressKey: EnvironmentKey {
    static var defaultValue: (AddressName) -> Void { { _ in } }
}
fileprivate struct UnpinAddressKey: EnvironmentKey {
    static var defaultValue: (AddressName) -> Void { { _ in } }
}
fileprivate struct PresentListableKey: EnvironmentKey {
    static var defaultValue: ((NavigationDestination) -> Void)? { nil }
}
fileprivate struct AddressIconKey: EnvironmentKey {
    static var defaultValue: AvatarCache {
        .init()
    }
}
fileprivate struct PicCacheKey: EnvironmentKey {
    static var defaultValue: ImageCache {
        .init()
    }
}
fileprivate struct PublieCacheKey: EnvironmentKey {
    static var defaultValue: ProfileCache { .init() }
}
fileprivate struct PrivateCacheKey: EnvironmentKey {
    static var defaultValue: PrivateCache { .init() }
}
fileprivate struct SearchActiveKey: EnvironmentKey {
    static var defaultValue: Bool { false }
}
fileprivate struct ShowAddressPageKey: EnvironmentKey {
    static var defaultValue: ((AddressContent) -> Void) { { _ in } }
}
fileprivate struct UpdateAddressKey: EnvironmentKey {
    static var defaultValue: (AddressName) -> Void { { _ in } }
}

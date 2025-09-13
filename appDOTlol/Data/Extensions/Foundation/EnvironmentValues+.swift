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

typealias ProfileCache = NSCache<NSString, AddressSummaryFetcher>
typealias PrivateCache = NSCache<NSString, AddressPrivateSummaryFetcher>
typealias ImageCache = NSCache<NSString, AddressIconFetcher>

struct SceneNamespaceKey: EnvironmentKey {
    static var defaultValue: Namespace.ID? { nil }
}
extension EnvironmentValues {
    var namespace: Namespace.ID? {
        get { self[SceneNamespaceKey.self] }
        set { self[SceneNamespaceKey.self] = newValue}
    }
}

struct SceneModelKey: EnvironmentKey {
    static var defaultValue: SceneModel? { nil }
}
extension EnvironmentValues {
    var destinationConstructor: SceneModel? {
        get { self[SceneModelKey.self] }
        set { self[SceneModelKey.self] = newValue }
    }
}

struct AddressBookKey: EnvironmentKey {
    static var defaultValue: AddressBook { .init() }
}
extension EnvironmentValues {
    var addressBook: AddressBook {
        get { self[AddressBookKey.self] }
        set { self[AddressBookKey.self] = newValue }
    }
}

struct AddressSummaryFetcherKey: EnvironmentKey {
    static var defaultValue: (AddressName) -> AddressSummaryFetcher? {
        { _ in return nil }
    }
}
extension EnvironmentValues {
    var addressSummaryFetcher: (AddressName) -> AddressSummaryFetcher? {
        get { self[AddressSummaryFetcherKey.self] }
        set { self[AddressSummaryFetcherKey.self] = newValue }
    }
}

struct AuthenticateKey: EnvironmentKey {
    static var defaultValue: (APICredential) -> Void { { _ in } }
}
extension EnvironmentValues {
    var authenticate: (APICredential) -> Void {
        get { self[AuthenticateKey.self] }
        set { self[AuthenticateKey.self] = newValue }
    }
}

struct BlockAddressKey: EnvironmentKey {
    static var defaultValue: (AddressName) -> Void { { _ in } }
}
struct UnblockAddressKey: EnvironmentKey {
    static var defaultValue: (AddressName) -> Void { { _ in } }
}
extension EnvironmentValues {
    var blockAddress: (AddressName) -> Void {
        get { self[BlockAddressKey.self] }
        set { self[BlockAddressKey.self] = newValue }
    }
    var unblockAddress: (AddressName) -> Void {
        get { self[UnblockAddressKey.self] }
        set { self[UnblockAddressKey.self] = newValue }
    }
}

struct CredentialFetcherKey: EnvironmentKey {
    static var defaultValue: (AddressName) -> APICredential? { { _ in nil } }
}
extension EnvironmentValues {
    var credentialFetcher: (AddressName) -> APICredential? {
        get { self[CredentialFetcherKey.self] }
        set { self[CredentialFetcherKey.self] = newValue }
    }
}

struct DatabaseKey: EnvironmentKey {
    static var defaultValue: Blackbird.Database {
        AppClient.database
    }
}
extension EnvironmentValues {
    var blackbird: Blackbird.Database {
        get { self[DatabaseKey.self] }
        set { self[DatabaseKey.self] = newValue }
    }
}

struct FollowAddressKey: EnvironmentKey {
    static var defaultValue: (AddressName) -> Void { { _ in } }
}
struct UnfollowAddressKey: EnvironmentKey {
    static var defaultValue: (AddressName) -> Void { { _ in } }
}
extension EnvironmentValues {
    var followAddress: (AddressName) -> Void {
        get { self[FollowAddressKey.self] }
        set { self[FollowAddressKey.self] = newValue }
    }
    var unfollowAddress: (AddressName) -> Void {
        get { self[UnfollowAddressKey.self] }
        set { self[UnfollowAddressKey.self] = newValue }
    }
}

struct GlobalAppStatusKey: EnvironmentKey {
    static var defaultValue: AppLatestFetcher? { nil }
}
extension EnvironmentValues {
    var appLatestFetcher: AppLatestFetcher? {
        get { self[GlobalAppStatusKey.self] }
        set { self[GlobalAppStatusKey.self] = newValue }
    }
}

struct GlobalBlockedFetcherKey: EnvironmentKey {
    static var defaultValue: AddressBlockListFetcher? {
        nil
    }
}
extension EnvironmentValues {
    var globalBlocklist: AddressBlockListFetcher? {
        get { self[GlobalBlockedFetcherKey.self] }
        set { self[GlobalBlockedFetcherKey.self] = newValue }
    }
}

struct GlobalDirectoryKey: EnvironmentKey {
    static var defaultValue: GlobalAddressDirectoryFetcher? {
        nil
    }
}
extension EnvironmentValues {
    var globalDirectoryFetcher: GlobalAddressDirectoryFetcher? {
        get { self[GlobalDirectoryKey.self] }
        set { self[GlobalDirectoryKey.self] = newValue }
    }
}

struct GlobalStatusLogKey: EnvironmentKey {
    static var defaultValue: GlobalStatusLogFetcher? {
        nil
    }
}
extension EnvironmentValues {
    var globalStatusLogFetcher: GlobalStatusLogFetcher? {
        get { self[GlobalStatusLogKey.self] }
        set { self[GlobalStatusLogKey.self] = newValue }
    }
}

struct GlobalSupportKey: EnvironmentKey {
    static var defaultValue: AppSupportFetcher? {
        nil
    }
}
extension EnvironmentValues {
    var appSupportFetcher: AppSupportFetcher? {
        get { self[GlobalSupportKey.self] }
        set { self[GlobalSupportKey.self] = newValue }
    }
}

struct InterfaceKey: EnvironmentKey {
    static var defaultValue: OMGInterface {
        SampleData()
    }
}
extension EnvironmentValues {
    var apiInterface: OMGInterface {
        get { self[InterfaceKey.self] }
        set { self[InterfaceKey.self] = newValue }
    }
}

struct LocalBlockedFetcherKey: EnvironmentKey {
    static var defaultValue: LocalBlockListFetcher? {
        nil
    }
}
extension EnvironmentValues {
    var localBlocklist: LocalBlockListFetcher? {
        get { self[LocalBlockedFetcherKey.self] }
        set { self[LocalBlockedFetcherKey.self] = newValue }
    }
}

struct SearchQueryEnvironmentKey: EnvironmentKey {
    static var defaultValue: String {
        ""
    }
}
extension EnvironmentValues {
    var searchQuery: String {
        get { self[SearchQueryEnvironmentKey.self] }
        set { self[SearchQueryEnvironmentKey.self] = newValue }
    }
}

struct PinnedFetcherKey: EnvironmentKey {
    static var defaultValue: PinnedListFetcher? {
        nil
    }
}
extension EnvironmentValues {
    var pinnedFetcher: PinnedListFetcher? {
        get { self[PinnedFetcherKey.self] }
        set { self[PinnedFetcherKey.self] = newValue }
    }
}

struct PinAddressKey: EnvironmentKey {
    static var defaultValue: (AddressName) -> Void { { _ in } }
}
struct UnpinAddressKey: EnvironmentKey {
    static var defaultValue: (AddressName) -> Void { { _ in } }
}
extension EnvironmentValues {
    var pinAddress: (AddressName) -> Void {
        get { self[PinAddressKey.self] }
        set { self[PinAddressKey.self] = newValue }
    }
    var unpinAddress: (AddressName) -> Void {
        get { self[UnpinAddressKey.self] }
        set { self[UnpinAddressKey.self] = newValue }
    }
}

struct PresentListableKey: EnvironmentKey {
    static var defaultValue: ((NavigationDestination) -> Void)? { nil }
}
extension EnvironmentValues {
    var presentListable: ((NavigationDestination) -> Void)? {
        get { self[PresentListableKey.self] }
        set { self[PresentListableKey.self] = newValue }
    }
}

struct AddressIconKey: EnvironmentKey {
    static var defaultValue: ImageCache {
        .init()
    }
}
extension EnvironmentValues {
    var imageCache: ImageCache {
        get { self[AddressIconKey.self] }
        set { self[AddressIconKey.self] = newValue }
    }
}

struct PublieCacheKey: EnvironmentKey {
    static var defaultValue: ProfileCache { .init() }
}
extension EnvironmentValues {
    var profileCache: ProfileCache {
        get { self[PublieCacheKey.self] }
        set { self[PublieCacheKey.self] = newValue }
    }
}

struct PrivateCacheKey: EnvironmentKey {
    static var defaultValue: PrivateCache { .init() }
}
extension EnvironmentValues {
    var privateCache: PrivateCache {
        get { self[PrivateCacheKey.self] }
        set { self[PrivateCacheKey.self] = newValue }
    }
}

struct SearchActiveKey: EnvironmentKey {
    static var defaultValue: Bool { false }
}
extension EnvironmentValues {
    var searchActive: Bool {
        get { self[SearchActiveKey.self] }
        set { self[SearchActiveKey.self] = newValue }
    }
}

struct ShowAddressPageKey: EnvironmentKey {
    static var defaultValue: ((AddressContent) -> Void) { { _ in } }
}
extension EnvironmentValues {
    var showAddressPage: (AddressContent) -> Void {
        get { self[ShowAddressPageKey.self] }
        set { self[ShowAddressPageKey.self] = newValue }
    }
}

struct UpdateAddressKey: EnvironmentKey {
    static var defaultValue: (AddressName) -> Void { { _ in } }
}
extension EnvironmentValues {
    var setAddress: (AddressName) -> Void {
        get { self[UpdateAddressKey.self] }
        set { self[UpdateAddressKey.self] = newValue }
    }
}

struct SearchFilterKey: EnvironmentKey {
    static var defaultValue: Set<SearchLanding.SearchFilter> { [.address] }
}
extension EnvironmentValues {
    var searchFilters: Set<SearchLanding.SearchFilter> {
        get { self[SearchFilterKey.self] }
        set { self[SearchFilterKey.self] = newValue }
    }
}

struct UpdateSearchFilterKey: EnvironmentKey {
    static var defaultValue: (Set<SearchLanding.SearchFilter>) -> Void { { _ in } }
}
extension EnvironmentValues {
    var setSearchFilters: (Set<SearchLanding.SearchFilter>) -> Void {
        get { self[UpdateSearchFilterKey.self] }
        set { self[UpdateSearchFilterKey.self] = newValue }
    }
}

struct UpdateVisibleAddressKey: EnvironmentKey {
    static var defaultValue: (AddressName?) -> Void { { _ in } }
}
extension EnvironmentValues {
    var setVisibleAddress: (AddressName?) -> Void {
        get { self[UpdateVisibleAddressKey.self] }
        set { self[UpdateVisibleAddressKey.self] = newValue }
    }
}

struct VisibleAddressKey: EnvironmentKey {
    static var defaultValue: AddressName? { "" }
}
extension EnvironmentValues {
    var visibleAddress: AddressName? {
        get { self[VisibleAddressKey.self] }
        set { self[VisibleAddressKey.self] = newValue }
    }
}

struct VisibleAddressPageKey: EnvironmentKey {
    static var defaultValue: AddressContent { .profile }
}
extension EnvironmentValues {
    var visibleAddressPage: AddressContent {
        get { self[VisibleAddressPageKey.self] }
        set { self[VisibleAddressPageKey.self] = newValue }
    }
}

struct ViewContextKey: EnvironmentKey {
    static var defaultValue: ViewContext { .column }
}
extension EnvironmentValues {
    var viewContext: ViewContext {
        get { self[ViewContextKey.self] }
        set { self[ViewContextKey.self] = newValue }
    }
}

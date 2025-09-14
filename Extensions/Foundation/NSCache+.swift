//
//  File.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/14/25.
//

import Foundation


typealias ProfileCache = NSCache<NSString, AddressSummaryFetcher>
typealias PrivateCache = NSCache<NSString, AddressPrivateSummaryFetcher>
typealias AvatarCache = NSCache<NSString, AddressIconFetcher>
typealias ImageCache = NSCache<NSString, PicFetcher>

//
//  NetworkAuthentication.swift
//  ManchesterFC
//
//  Created by David Casserly on 13/02/2020.
//  Copyright © 2020 DevedUp Ltd. All rights reserved.
//

import Foundation
import DevedUpSwiftFoundation

public protocol NetworkAuthentication {
    var accessToken: String? { get set }
    func processResponseHeaders(_ allHeaderFields: [AnyHashable : Any])
    func processSessionExpiry(isLoginRequest: Bool) -> ErrorType?
    func prepareHeadersWithAccessToken(_ accessTokenNeeded: Bool) -> [String: String]
    func queryItemsToAppend() -> [URLQueryItem]?
    func userAgentToAppend() -> String
    func removeAccessToken()
    func storeUserId(userId: String)
}

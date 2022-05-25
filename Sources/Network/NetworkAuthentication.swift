//
//  NetworkAuthentication.swift
//
//  Created by David Casserly on 13/02/2020.
//  Copyright © 2020 DevedUp Ltd. All rights reserved.
//

import Foundation
import DevedUpSwiftFoundation

public protocol NetworkAuthentication {
    var log: Loggable { get set }
    var accessToken: String? { get set }
    func processResponseHeaders(_ allHeaderFields: [AnyHashable : Any])
    func processSessionExpiry(isLoginRequest: Bool, data: Data?) -> ErrorType
    func prepareHeadersWithAccessToken(headers: inout [String: String], _ accessTokenNeeded: Bool) throws
    func queryItemsToAppend() -> [URLQueryItem]?
    func userAgentToAppend() -> String
    func headersToAppend() -> [String: String]?
    func removeAccessToken()
    func storeUserId(userId: String)
}

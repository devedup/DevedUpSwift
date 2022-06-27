//
//  NetworkAuthentication.swift
//
//  Created by David Casserly on 13/02/2020.
//  Copyright © 2020 DevedUp Ltd. All rights reserved.
//

import Foundation
import DevedUpSwiftFoundation

/// Your auth delegate is going to keep your token for subsequent requests and perform other network alterations
public protocol NetworkAuthDelegate: AnyObject {
    var log: Loggable { get set }
    var accessToken: String? { get set }
    func processResponseHeaders(_ allHeaderFields: [AnyHashable : Any])
    func processSessionExpiry(isLoginRequest: Bool, data: Data?) -> ErrorType
    func prepareHeadersWithAccessToken(headers: inout [String: String], _ accessTokenNeeded: Bool) throws
    func userAgentToAppend() -> String
    func headersToAppend() -> [String: String]?
    func removeAccessToken()
    func storeUserId(userId: String)
}

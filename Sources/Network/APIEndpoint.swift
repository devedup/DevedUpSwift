//
//  APIEndpoint.swift
//
//  Created by David Casserly on 13/02/2020.
//  Copyright © 2020 DevedUp Ltd. All rights reserved.
//

import Foundation

// This is just so that in autocomplete, you see 'APIResponseModel' instead of 'Decodable'.
// Makes it a bit clearer
public typealias APIResponseModel = Decodable

public enum HTTPMethodType: String {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case delete  = "DELETE"
}

public protocol APIEndpoint {
    associatedtype ResponseModel: APIResponseModel
    var method: HTTPMethodType { get }
    var path: String { get }
    var payloadBody: Data? { get }
    var isAuthenticatedRequest: Bool { get }
    var headers: [String: String]? { get }
}

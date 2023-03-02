//
//  Network_v2.swift
//
//  Created by David Casserly on 18/07/2019.
//  Copyright © 2019 DevedUp Ltd. All rights reserved.
//

import Foundation
import DevedUpSwiftFoundation

public extension Notification.Name {
    static let appUpgradeRequired = Notification.Name("appUpgradeRequired")
}

public protocol NetworkService {
     
    /// The completion handler is executed on the main thread.
    ///
    /// - Parameters:
    ///   - endpoint: the endpoint being called
    ///   - completion: completion handler is executed on the main thread
    @available(*, renamed: "call(_:)") // Can deprecate this at some point when migrating to asyn version
    func call<Endpoint: APIEndpoint>(_ endpoint: Endpoint, completion: @escaping AsyncResultCompletion<Endpoint.ResponseModel>)
    
    
    /// The async version of calling network . It doesn't return on the main thread
    ///
    /// - Parameter endpoint: the APIEndpoint
    /// - Returns: The JSON model 
    func call<Endpoint: APIEndpoint>(_ endpoint: Endpoint) async throws -> Endpoint.ResponseModel

}

public class DefaultNetworkService: NetworkService {
    
    private let logger: NetworkLogger & Loggable
    
    private let session: URLSession = {
        var configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration)
    }()
    
    public weak var authDelegate: NetworkAuthDelegate?
    
    public init(logger: Loggable = ConsoleLogger(), networkAuth: NetworkAuthDelegate) {
        self.logger = NetworkLogger(logger: logger)
        self.authDelegate = networkAuth
    }
    
    /// This is a bridge to the async version
    @available(*, deprecated, renamed: "call(_:)")
    public func call<Endpoint: APIEndpoint>(_ endpoint: Endpoint, completion: @escaping AsyncResultCompletion<Endpoint.ResponseModel>) {
        Task {
            do {
                let result: Endpoint.ResponseModel = try await call(endpoint)
                DispatchQueue.main.async {
                    completion(.success(result))
                }
            } catch {
                DispatchQueue.main.async {
                    if let errorType = error as? ErrorType {
                        completion(.failure(errorType))
                    } else {
                        completion(.failure(FoundationError.GeneralError(error)))
                    }
                }
            }
        }
    }
    
    public func call<Endpoint: APIEndpoint>(_ endpoint: Endpoint) async throws -> Endpoint.ResponseModel {
        // Check we have a valid URL, if not return an error
        guard let urlComponents = URLComponents(string: endpoint.path),
              let url = urlComponents.url else {
            return try await withCheckedThrowingContinuation { continuation in
                continuation.resume(throwing: FoundationError.Network(error: nil))
            }
        }
        
        // Prepare headers
        var headers: [String: String] =
        [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "User-Agent": userAgent + " \(authDelegate?.userAgentToAppend() ?? "" )"
        ]
        
        // We don't want to be calling endpoint if no token, so throw the error here
        try? authDelegate?.prepareHeadersWithAccessToken(headers: &headers, endpoint.isAuthenticatedRequest)
        
        
        // Build the request
        var request = URLRequest(url: url)
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key)}
        endpoint.headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key)}
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.payloadBody
                        
        return try await processRequest(endpoint, request: request)
    }
    
    private func processRequest<Endpoint: APIEndpoint>(_ endpoint: Endpoint, request: URLRequest) async throws -> (Endpoint.ResponseModel) {
        return try await withCheckedThrowingContinuation { continuation in
            let task = session.dataTask(with: request) { data, response, error in
                let isAuthRequest = endpoint.isAuthenticatedRequest
                self.logger.log(request: request, response: response as? HTTPURLResponse, responseData: data, isLogin: !isAuthRequest)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    var isInternetOffline = false
                    if let nsError = error as NSError? {
                        isInternetOffline = (nsError.code == -1009)
                    }
                    if isInternetOffline {
                        continuation.resume(throwing: FoundationError.NoInternetConnection())
                    } else {
                        continuation.resume(throwing: FoundationError.Network(error: error))
                    }
                    return
                }
                    
                // Handle response headers
                self.authDelegate?.processResponseHeaders(httpResponse.allHeaderFields)
                    
                // Now process the response
                let status = httpResponse.statusCode
                switch status {
                case 204:
                    continuation.resume(throwing: FoundationError.Network(error: nil))
                case 200..<300:
                    guard let data = data else {
                        continuation.resume(throwing: FoundationError.Network(error: error))
                        return
                    }
                    
                    do {
                        let responseObject:Endpoint.ResponseModel = try JSONLoader.parseData(networkResponse: data, logger: self.logger)
                        continuation.resume(returning: responseObject)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case 401:
                    // Failed login return 401, we don't want to show session expired
                    if let sessionExpiredError = self.authDelegate?.processSessionExpiry(isLoginRequest: !isAuthRequest, data: data) {
                        continuation.resume(throwing: sessionExpiredError)
                    } else {
                        continuation.resume(throwing: FoundationError.Network(error: nil))
                    }
                case 426:
                    NotificationCenter.default.post(name: .appUpgradeRequired, object: nil, userInfo: nil) // Needs to be pulled out
                    continuation.resume(throwing: FoundationError.AppUpgradeRequired())
                case 422:
                    continuation.resume(throwing: FoundationError.NetworkValidation(statusCode: status, data: data))
                default:
                    continuation.resume(throwing: FoundationError.NetworkData(statusCode: status, data: data))
                }
            }
            task.resume()
        }
    }

}

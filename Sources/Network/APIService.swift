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

// This will be the entry point in future
public protocol APIService {
    var networkAuth: NetworkAuthentication { get }
    func call<Endpoint: APIEndpoint>(_ endpoint: Endpoint, completion: @escaping AsyncResultCompletion<Endpoint.ResponseModel>)
}

public class DefaultAPIService: APIService {
    
    private let logger: APILogger
    
    private let session: URLSession = {
        var configuration = URLSessionConfiguration.default
        if Debug.isDebugging() {
            configuration.timeoutIntervalForRequest = 60
        }
        return URLSession(configuration: configuration)
    }()
    
    public let networkAuth: NetworkAuthentication
    
    public init(logger: Loggable = ConsoleLogger(), networkAuth: NetworkAuthentication) {
        self.logger = APILogger(logger: logger)
        self.networkAuth = networkAuth
    }
    
    private func responseData<ResponseModel: Decodable>(networkResponse data: Data) -> AsyncResult<ResponseModel> {
        do {
            let response = try JSONDecoder().decode(ResponseModel.self, from: data)
            return .success(response)
        } catch {
            let errorString = "Error parsing response into \(ResponseModel.self) [\(error)]"
            logger.log(message: errorString)
            return .failure(GenericError.network(error: error))
        }
    }
    
    public func call<Endpoint: APIEndpoint>(_ endpoint: Endpoint, completion: @escaping AsyncResultCompletion<Endpoint.ResponseModel>) {
        // Check we have a valid URL, if not return an error
        guard var urlComponents = URLComponents(string: endpoint.path) else {
            let error = GenericError.network(error: nil)
            DispatchQueue.main.async {
                completion(AsyncResult.failure(error))
            }
            return
        }
        
        // Add extra query params if there are any
        var queryItems: [URLQueryItem] = urlComponents.queryItems ?? []
        if let extraQueryItems = networkAuth.queryItemsToAppend() {
            queryItems.append(contentsOf: extraQueryItems)
        }
        urlComponents.queryItems = queryItems
        
        // Build the url
        guard let url = urlComponents.url else {
            let error = GenericError.network(error: nil)
            DispatchQueue.main.async {
                completion(AsyncResult.failure(error))
            }
            return
        }
        
        // Prepare headers
        var headers = networkAuth.prepareHeadersWithAccessToken(endpoint.isAuthenticatedRequest)
        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"
        let userAgentAppends = " \(networkAuth.userAgentToAppend())"
        headers["User-Agent"] = userAgent + userAgentAppends
        
        var request = URLRequest(url: url)
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key)}
        endpoint.headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key)}
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.payloadBody
        
        /*
         
         var hasSetContentType = false
            if let customHeaders = endpoint.headers {
                customHeaders.forEach {
                    if $0.key == "Content-Type" {
                        hasSetContentType = true
                    }
                    request.setValue($0.value, forHTTPHeaderField: $0.key)
                }
            }
            
            if !hasSetContentType {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
         */
        
        // Now schedule the request onto the session
        let task = session.dataTask(with: request) { data, response, error in
            
            self.logger.log(request: request, response: response as? HTTPURLResponse, responseData: data, isLogin: !endpoint.isAuthenticatedRequest)
            
            // Now it's back, lets put it back on main thread
            DispatchQueue.main.async {
                guard let httpResponse = response as? HTTPURLResponse else {
                    var isInternetOffline = false
                    if let nsError = error as NSError? {
                        isInternetOffline = (nsError.code == -1009)
                    }
                    let networkError = isInternetOffline ? GenericError.noInternetConnection : GenericError.network(error: error)
                    completion(AsyncResult.failure(networkError))
                    return
                }
                
                // Handle response headers
                self.networkAuth.processResponseHeaders(httpResponse.allHeaderFields)
                
                // Now process the response
                switch self.processResponse(httpResponse) {
                case .success(let status):
                    guard let data = data else {
                        completion(AsyncResult.failure(GenericError.network(error: error)))
                        return
                    }
                    if status == 204 {
                        completion(AsyncResult.failure(GenericError.network(error: nil)))
                        return
                    }
                    let result: AsyncResult<Endpoint.ResponseModel> = self.responseData(networkResponse: data)
                    completion(result)
                case .failure(let statusCode):
                    completion(.failure(GenericError.networkData(statusCode: statusCode, context:nil, data: data)))
                case .sessionExpired(let statusCode):
                    if let sessionExpiredError = self.networkAuth.processSessionExpiry(isLoginRequest: !endpoint.isAuthenticatedRequest, data: data) {
                        // Failed login return 401, we don't want to show session expired
                        completion(AsyncResult.failure(sessionExpiredError))
                    } else {                     
                        completion(.failure(GenericError.networkData(statusCode: statusCode, context:nil, data: data)))
                    }
                case .upgradeRequired:
                    NotificationCenter.default.post(name: .appUpgradeRequired, object: nil, userInfo: nil) // Needs to be pulled out
                    completion(.failure(GenericError.appUpgradeRequired))
                }
            }
        }
        task.resume()
    }
    
    
    
    
    private func processResponse(_ response: HTTPURLResponse) -> HttpResponse {
        let statusCode = response.statusCode
        
        // Unauthorized
        if response.statusCode == 401 {
            return .sessionExpired(statusCode: statusCode)
        }
        // Upgrade required
        if response.statusCode == 426 {
            return .upgradeRequired(statusCode: statusCode)
        }
        // Success
        if (200..<300).contains(response.statusCode) {
            return .success(statusCode: statusCode)
        } else {
            return .failure(statusCode: statusCode)
        }
    }
    
    // User-Agent Header; see https://tools.ietf.org/html/rfc7231#section-5.5.3
    // Example: `iOS Example/1.0 (org.alamofire.iOS-Example; build:1; iOS 10.0.0) Alamofire/4.0.0`
    private let userAgent: String = {
        if let info = Bundle.main.infoDictionary {
            let executable = info[kCFBundleExecutableKey as String] as? String ?? "Unknown"
            let bundle = info[kCFBundleIdentifierKey as String] as? String ?? "Unknown"
            let appVersion = info["CFBundleShortVersionString"] as? String ?? "Unknown"
            let appBuild = info[kCFBundleVersionKey as String] as? String ?? "Unknown"
            
            let osNameVersion: String = {
                let version = ProcessInfo.processInfo.operatingSystemVersion
                let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
                
                let osName: String = {
                    #if os(iOS)
                    return "iOS"
                    #elseif os(watchOS)
                    return "watchOS"
                    #elseif os(tvOS)
                    return "tvOS"
                    #elseif os(macOS)
                    return "OS X"
                    #elseif os(Linux)
                    return "Linux"
                    #else
                    return "Unknown"
                    #endif
                }()
                
                return "\(osName) \(versionString)"
            }()
            
            let devedupSwiftVersion: String = {
                guard
                    let duInfo = Bundle(for: DefaultAPIService.self).infoDictionary,
                    let build = duInfo["CFBundleShortVersionString"]
                    else { return "Unknown" }
                
                return "DevedUpSwift-Network/\(build)"
            }()
            
            return "\(executable)/\(appVersion) (\(bundle); build:\(appBuild); \(osNameVersion)) \(devedupSwiftVersion)"
        }
        
        return "DevedUpSwift-Network"
    }()
}

private enum HttpResponse {
    case success(statusCode: Int)
    case failure(statusCode: Int)
    case sessionExpired(statusCode: Int)
    case upgradeRequired(statusCode: Int)
}

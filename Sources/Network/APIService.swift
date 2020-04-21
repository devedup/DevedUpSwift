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
    func call<Endpoint: APIEndpoint>(_ endpoint: Endpoint, completion: @escaping AsyncResultCompletion<Endpoint.ResponseModel>)
}

public extension String {
    var urlQueryEncoded: String {
        var characterSet = CharacterSet.urlQueryAllowed
        characterSet.remove("+")
        return addingPercentEncoding(withAllowedCharacters: characterSet)!
    }
    var urlPathEncoded: String {
        var characterSet = CharacterSet.urlPathAllowed
        characterSet.remove("@")
        return addingPercentEncoding(withAllowedCharacters: characterSet)!
    }
}

public class DefaultAPIService: APIService {
    
    private let logger: APILogger
    private let session = URLSession(configuration: .default)
    private let networkAuth: NetworkAuthentication
    
    public init(logger: Loggable = FileLogger(fileNamePrefix: "devedupnetwork"), networkAuth: NetworkAuthentication) {
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
            return .failure(GenericError.networkLoad(code: nil))
        }
    }
        
    public func call<Endpoint: APIEndpoint>(_ endpoint: Endpoint, completion: @escaping AsyncResultCompletion<Endpoint.ResponseModel>) {
        // Check we have a valid URL, if not return an error
        guard let url = URL(string: endpoint.path) else {
            let error = GenericError.network(nil)
            DispatchQueue.main.async {
                completion(AsyncResult.failure(error))
            }
            return
        }

        // Prepare headers
        var headers = networkAuth.prepareHeadersWithAccessToken(endpoint.isAuthenticatedRequest)
        headers["Content-Type"] = "application/json"
        headers["Accepte"] = "application/json"
        
        // Create the request
        var request = URLRequest(url: url)
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key)}
        endpoint.headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key)}
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.payloadBody

        // Now schedule the request onto the session
        let task = session.dataTask(with: request) { data, response, error in
            
            self.logger.log(request: request, response: response as? HTTPURLResponse, responseData: data, isLogin: !endpoint.isAuthenticatedRequest)
            
            // Now it's back, lets put it back on main thread
            DispatchQueue.main.async {
                guard let httpResponse = response as? HTTPURLResponse else {
                    let generalError = GenericError.generalError(error ?? nil)
                    completion(AsyncResult.failure(generalError))
                    return
                }
                
                // Handle response headers
                self.networkAuth.processResponseHeaders(httpResponse.allHeaderFields)

                // Now process the response
                switch self.processResponse(httpResponse) {
                case .success(let status):
                    guard let data = data else {
                        completion(AsyncResult.failure(GenericError.network(error ?? nil)))
                        return
                    }
                    if status == 204 {
                        completion(AsyncResult.failure(GenericError.networkNoContent))
                        return
                    }
                    let result: AsyncResult<Endpoint.ResponseModel> = self.responseData(networkResponse: data)
                    completion(result)
                case .failure(let statusCode):
                    if let data = data, let responseString = String(data: data, encoding: String.Encoding.utf8) {
                        completion(AsyncResult.failure(GenericError.networkDataError(details: responseString)))
                    } else {
                        completion(AsyncResult.failure(GenericError.networkLoad(code: statusCode)))
                    }
                case .sessionExpired:
                    if let error = self.networkAuth.processSessionExpiry(isLoginRequest: endpoint.isAuthenticatedRequest) {
                        // Failed login return 401, we don't want to show session expired
                        completion(AsyncResult.failure(error))
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
                
}

private enum HttpResponse {
    case success(statusCode: Int)
    case failure(statusCode: Int)
    case sessionExpired(statusCode: Int)
    case upgradeRequired(statusCode: Int)
}

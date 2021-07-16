//
//  File.swift
//  
//
//  Created by David Casserly on 13/07/2021.
//

import Foundation
import DevedUpSwiftNetwork

public struct AuthRequest {
    let client_id: String
    let redirect_uri: URL
    let response_type: String = "code"
    let approval_prompt: String = "auto"
    let scope: String = "activity:read"
    let state: String = "editprofile"
    
    var redirectURI: String {
        let encodedURL = redirect_uri.absoluteString.urlQueryEncoded
        return encodedURL
    }
    
    public init(client_id: String, redirect_uri: URL) {
        self.client_id = client_id
        self.redirect_uri = redirect_uri
    }
    
    private func queryItems() -> [URLQueryItem] {
        var queryItems:[URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "client_id", value: client_id))
        queryItems.append(URLQueryItem(name: "redirect_uri", value: redirectURI))
        queryItems.append(URLQueryItem(name: "response_type", value: response_type))
        queryItems.append(URLQueryItem(name: "approval_prompt", value: approval_prompt))
        queryItems.append(URLQueryItem(name: "scope", value: scope))
        queryItems.append(URLQueryItem(name: "state", value: state))
        return queryItems
    }
    
    var stravaAppURL: URL? {
        guard var urlComponents = URLComponents(string: "strava://oauth/mobile/authorize") else {
            return nil
        }
        urlComponents.queryItems = queryItems()
        guard let appOAuthUrlStravaScheme = urlComponents.url else {
            return nil
        }
        return appOAuthUrlStravaScheme
    }
    
    var stravaWebURL: URL? {
        guard var urlComponents = URLComponents(string: "https://www.strava.com/oauth/mobile/authorize") else {
            return nil
        }
        urlComponents.queryItems = queryItems()
        guard let stravaWebURL = urlComponents.url else {
            return nil
        }
        return stravaWebURL
    }
}

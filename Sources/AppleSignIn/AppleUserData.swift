//
//  File.swift
//  
//
//  Created by David Casserly on 28/10/2020.
//

import Foundation
import AuthenticationServices
import DevedUpSwiftFoundation

public struct AppleUserData: KeychainRestorable, Codable {
    
    public typealias CodableType = AppleUserData
    public static var restoreKey: String { "AppleUserData" }
    
  /// The email address to use for user communications.  Remember it might be a relay!
    
    public let email: String
    public let appleUserIdentifier: String
    public let identityToken: Data?
    public let authCode: Data?

    public var identityTokenString: String {
        guard let data = identityToken else {
            return ""
        }
        return String(data: data, encoding: .utf8) ?? ""
    }
}

extension AppleUserData {
    public init(_ credential: ASAuthorizationAppleIDCredential) {
        email = credential.email ?? ""
        appleUserIdentifier = credential.user
        identityToken = credential.identityToken
        authCode = credential.authorizationCode
    }
}

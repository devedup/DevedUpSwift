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
    public static var restoreKey: String { "AppleUserData2" }
    
  /// The email address to use for user communications.  Remember it might be a relay!
    
    public private (set) var  email: String
    public private (set) var  firstName: String?
    public let appleUserIdentifier: String
    public private (set) var identityToken: Data?
    public private (set) var authCode: Data?

    public var identityTokenString: String {
        guard let data = identityToken else {
            return ""
        }
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    /*
        
        If you need email a second time, you can decode it from the identity token JWT
     
     */
    public mutating func update(with credential: ASAuthorizationAppleIDCredential) {
        identityToken = credential.identityToken
        authCode = credential.authorizationCode
    }
    
//    import JWTDecode
//        // ...
//        if let identityTokenData = appleIDCredential.identityToken,
//        let identityTokenString = String(data: identityTokenData, encoding: .utf8) {
//        print("Identity Token \(identityTokenString)")
//        do {
//           let jwt = try decode(jwt: identityTokenString)
//           let decodedBody = jwt.body as Dictionary<String, Any>
//           print(decodedBody)
//           print("Decoded email: "+(decodedBody["email"] as? String ?? "n/a")   )
//        } catch {
//           print("decoding failed")
//        }
}

extension AppleUserData {
    
    /*
     
     You only get the email and the name on the very first login..
     
    To get these credential a second time go to:
     go to your device -> Settings -> Apple ID -> Password & Security -> Apps Using your Apple ID -> you get list of apps used sign in with apple {find your app} -> swift left of your apps row {show Delete option} -> click on Delete
     
     */
    public init(_ credential: ASAuthorizationAppleIDCredential) {
        email = credential.email ?? ""
        firstName = credential.fullName?.givenName
        appleUserIdentifier = credential.user
        identityToken = credential.identityToken
        authCode = credential.authorizationCode
    }
}

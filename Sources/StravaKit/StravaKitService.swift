//
//  File.swift
//  
//
//  Created by David Casserly on 13/07/2021.
//

import Foundation
import UIKit
import AuthenticationServices
import DevedUpSwiftFoundation

public protocol StravaKitService {
    func authenticate(_ request: AuthRequest, from viewController: UIViewController, completion: @escaping (AsyncResultCompletion<URL>))
}

public class DefaultStravaKitService: StravaKitService {
 
    public static let sharedInstance = DefaultStravaKitService()
    
    private init () {}
    
    private var authSession: ASWebAuthenticationSession?
    
    public func authenticate(_ request: AuthRequest, from viewController: UIViewController, completion: @escaping (AsyncResultCompletion<URL>)) {
        guard let stravaAppURL = request.stravaAppURL else {
            return
        }
        
        // Try and open the local Strava app first for auth
        if UIApplication.shared.canOpenURL(stravaAppURL) {
            UIApplication.shared.open(stravaAppURL, options: [:])
        } else {
            guard let stravaWebURL = request.stravaWebURL else {
                return
            }
            
            // Initialize the session.
            let scheme = "fitafy"
            let session = ASWebAuthenticationSession(url: stravaWebURL, callbackURLScheme: scheme)
            { callbackURL, error in
                // Handle the callback.
                if let url = callbackURL {
                    completion(.success(url))
                } else {
                    completion(.failure(FoundationError.GeneralError(error)))
                }
            }
            session.presentationContextProvider = viewController
            session.start()
            self.authSession = session
        }
    }
    
}

extension UIViewController: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return view.window!
    }
}

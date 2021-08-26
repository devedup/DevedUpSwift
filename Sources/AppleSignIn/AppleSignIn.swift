//
//  File.swift
//  
//
//  Created by David Casserly on 28/10/2020.
//

import Foundation
import DevedUpSwiftFoundation
import AuthenticationServices

public protocol AppleSignIn {
    func loginWithApple(completion: @escaping AsyncResultCompletion<AppleUserData>)
}

public class DefaultAppleSignIn: NSObject, AppleSignIn {
    
    private var completion: AsyncResultCompletion<AppleUserData>?
    
    public func loginWithApple(completion: @escaping AsyncResultCompletion<AppleUserData>) {
        self.completion = completion
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.email] // fullName
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
//        authorizationController.presentationContextProvider = viewController
        authorizationController.performRequests()
    }
    
}

extension DefaultAppleSignIn: ASAuthorizationControllerDelegate {
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        guard let asError = error as? ASAuthorizationError else {
            completion?(.failure(FoundationError.AppleSignInError(error)))
            return
        }
        switch asError.code {
        case .canceled:
            completion?(.failure(FoundationError.UserCancelled()))
        default:
            completion?(.failure(FoundationError.AppleSignInError(asError)))
        }
    }
    
    /*
     
        To get these credential a second time go to:
     go to your device -> Settings -> Apple ID -> Password & Security -> Apps Using your Apple ID -> you get list of apps used sign in with apple {find your app} -> swift left of your apps row {show Delete option} -> click on Delete
     
     */
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            if let _ = appleIdCredential.email {
                registerNewAccount(credential: appleIdCredential)
            } else {
                signInWithExistingAccount(credential: appleIdCredential)
            }
        case let passwordCredential as ASPasswordCredential:
            signInWithUserAndPassword(credential: passwordCredential)
        default:
            break
        }
    }
    
    private func registerNewAccount(credential: ASAuthorizationAppleIDCredential) {
        let userData = AppleUserData(credential)
        completion?(.success(userData))
    }
    
    private func signInWithExistingAccount(credential: ASAuthorizationAppleIDCredential) {
        let userData = AppleUserData(credential)
        completion?(.success(userData))
    }
    
    private func signInWithUserAndPassword(credential: ASPasswordCredential) {
        completion?(.failure(FoundationError.AppleSignInError(nil)))
    }
}

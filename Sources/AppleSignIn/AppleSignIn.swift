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
        request.requestedScopes = [.email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
//        authorizationController.presentationContextProvider = viewController
        authorizationController.performRequests()
    }
    
}

extension DefaultAppleSignIn: ASAuthorizationControllerDelegate {
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completion?(.failure(GenericError.appleSignInError(error)))
    }
    
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
        let success = userData.saveToKeyChain()
        if success {
            completion?(.success(userData))
        } else {
            completion?(.failure(GenericError.appleSignInError(nil)))
        }
        
    }
    
    private func signInWithExistingAccount(credential: ASAuthorizationAppleIDCredential) {
        if let savedUser = AppleUserData.restoreFromKeychain() {
            completion?(.success(savedUser))
        } else {
            let userData = AppleUserData(credential)
            completion?(.success(userData))
        }
        
        // You *should* have a fully registered account here.  If you get back an error from your server
        // that the account doesn't exist, you can look in the keychain for the credentials and rerun setup
    }
    
    private func signInWithUserAndPassword(credential: ASPasswordCredential) {
        if let savedUser = AppleUserData.restoreFromKeychain() {
            completion?(.success(savedUser))
        } else {
           // let userData = AppleUserData(credential)
           // completion?(.success(userData))
            completion?(.failure(GenericError.appleSignInError(nil)))
        }
        
        // You *should* have a fully registered account here.  If you get back an error from your server
        // that the account doesn't exist, you can look in the keychain for the credentials and rerun setup
    }
}

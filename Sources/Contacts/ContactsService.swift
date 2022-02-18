//
//  File.swift
//  
//
//  Created by David Casserly on 18/02/2022.
//

import Foundation
import DevedUpSwiftFoundation
import Contacts

public protocol ContactsService {
    func loadContacts()
}

public class DefaultContactsService: ContactsService {
    
    public static let sharedInstance = DefaultHealthKitService()
    
    private init () {}
    
    private let store = CNContactStore()
    
    private func requestAccess(completion: @escaping AsyncResultCompletion<Bool>) {
        store.requestAccess(for: .contacts) { success, errorOrNil in
            if let error = errorOrNil {
                completion(.failure(error))
            } else {
                completion(.success(success))
            }
        }
    }
    
    public func loadContacts(completion: @escaping AsyncResultCompletion<Bool>) {
        requestAccess { result in
            switch result {
            case .success(let granted):
                if granted {
                    do {
                        let keysToFetch = [CNContactGivenNameKey, CNContactPhoneNumbersKey]
                        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
                        fetchRequest.unifyResults = true
                        let contacts = try store.enumerateContacts(with: fetchRequest, usingBlock: { contact, stopPointer in
                            print(contact.givenName)
                        })
                        print("Fetched contacts: \(contacts)")
                    } catch {
                        print("Failed to fetch contact, error: \(error)")
                        // Handle the error
                    }
                } else {
                    // TODO YOU'VE BEEN DENIED
                }
            case .failure(let error):
                // TODO YOUVE BEEN ERROR'ED
                break
            }
        }
        
        
        
    }
    
}

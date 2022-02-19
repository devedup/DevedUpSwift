//
//  File.swift
//  
//
//  Created by David Casserly on 18/02/2022.
//

import Foundation
import DevedUpSwiftFoundation
import Contacts

public struct Contact: Hashable, Comparable {
            
    public let name: String
    public let number: String
    
    internal init(name: String, number: String) {
        self.name = name
        self.number = number
    }
    
    public static func < (lhs: Contact, rhs: Contact) -> Bool {
        return lhs.name < rhs.name
    }
    
}

public protocol ContactsService {
    func loadContacts(completion: @escaping AsyncResultCompletion<[Contact]>)
}

public class DefaultContactsService: ContactsService {
    
    public static let sharedInstance = DefaultContactsService()
    
    private init () {}
    
    private let store = CNContactStore()
    
    private func requestAccess(completion: @escaping AsyncResultCompletion<Bool>) {
        store.requestAccess(for: .contacts) { success, errorOrNil in
            if let error = errorOrNil {
                completion(.failure(FoundationError.ContactsError(error)))
            } else {
                completion(.success(success))
            }
        }
    }
    
    public func loadContacts(completion: @escaping AsyncResultCompletion<[Contact]>) {
        requestAccess { result in
            switch result {
            case .success(let granted):
                if granted {
                    do {
                        var contactsFound: Set<Contact> = Set<Contact>()
                        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
                        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
                        fetchRequest.unifyResults = true
                        fetchRequest.sortOrder = CNContactSortOrder.givenName
                        _ = try self.store.enumerateContacts(with: fetchRequest, usingBlock: { contact, stopPointer in
                                                        
                            let fullName = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            // Grab the first phone number
                            let phoneNumbers = contact.phoneNumbers
                            var phoneNumber: String = phoneNumbers.first?.value.stringValue ?? ""
                            // Look through the others for a mobile specific tagged one
                            for number in phoneNumbers {
                                if number.label == CNLabelPhoneNumberMobile || number.label == CNLabelPhoneNumberiPhone {
                                    phoneNumber = number.value.stringValue
                                    break // no need to search anymore
                                }
                            }
                            if !phoneNumber.isEmpty && !fullName.isEmpty {
                                contactsFound.insert(Contact(name: fullName, number: phoneNumber))
                            } else {
                                print("Not adding \(fullName) as didn't find appropriate phone number or the name is empty")
                            }
                        })
                        
                        // Need to add to array and sort them
                        let sortedArray = Array(contactsFound).sorted()
                        completion(.success(sortedArray))
                    } catch {
                        completion(.failure(FoundationError.ContactsError(error)))
                    }
                } else {
                    completion(.failure(FoundationError.ContactsAuthDenied()))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        
        
    }
    
}

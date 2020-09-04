//
//  File.swift
//  
//
//  Created by David Casserly on 04/09/2020.
//

import Foundation
import UIKit
/**
 
    USAGE:
 
        struct RegisterEndpoint: APIEndpoint {
            typealias ResponseModel = RegisterResponse
            var method: HTTPMethodType { .post }
            var path: String { Environment.current.baseURL + "/v2/register" }
            var payloadBody: Data? {
                return register.httpBody()
            }
            var isAuthenticatedRequest: Bool { false }
            var headers: [String: String]? {
                return register.headers
            }
            
            let register: RegisterRequest
        }
 
 
        See below for RegisterRequest
 
 
 
 */
extension NSMutableData {
    fileprivate func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}

/// Implement this to provide Multipart Support
public protocol MultipartRequest  {
    /// You must provide a unique ID
    var boundaryUUID: String { get }
    
    /// The file data you are uploading in this request, this could by UIImage as Data
    var files: [String: Data] { get }
        
    /// The other fields you are uploading
    var fields: [String: String] { get }
    
    /// This returns the Content-Type multipart/form-data; boundary=
    var headers: [String: String] { get }
        
    /// This is the body you put into your request
    func httpBody() -> Data
}

extension MultipartRequest {
    
    public var boundary: String {
        "Boundary-\(boundaryUUID)"
    }
    
    public var headers: [String: String]  {
         return ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
    }
    
    private func convertFormField(named name: String, value: String, using boundary: String) -> String {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"
        return fieldString
    }
    
    private func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
        let data = NSMutableData()
        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        data.appendString("Content-Type: \(mimeType)\r\n\r\n")
        data.append(fileData)
        data.appendString("\r\n")
        return data as Data
    }
    
    public func httpBody() -> Data {
        let httpBody = NSMutableData()
        for (key, value) in fields {
            httpBody.appendString(convertFormField(named: key, value: value, using: boundary))
        }
        
        for (key, value) in files {
            httpBody.append(convertFileData(fieldName: key, fileName: "\(key).jpg", mimeType: "image/jpg", fileData: value, using: boundary))
        }
        
        httpBody.appendString("--\(boundary)--")
        return httpBody as Data
    }
}

extension UIImage {
    public var toJPEGData: Data {
        return self.jpegData(compressionQuality: 0.8) ?? Data()
    }
}

/**
 
 struct RegisterRequest {
     
     let image1: UIImage
     let image2: UIImage?
     let image3: UIImage?
     let image4: UIImage?
     let image5: UIImage?
     let image6: UIImage?
     
     let mobile_number: String
     let country_code: String
     let name: String
     let gender: Gender
     let match_with: GenderMatch
     let dob: String
     let email: String
     let about_me: String
     
     var boundaryUUID: String = UUID().uuidString
     
 }

 extension RegisterRequest {
     init(_ model: RegistrationModel) {
         guard let name = model.name,
             let gender = model.gender,
             let match = model.interestedIn,
             let dob = model.dob,
             let email = model.email,
             let mobile = model.mobileNumber,
             let code = model.countryCode,
             let about = model.personalStatement else {
                 preconditionFailure()
         }
         
         self.image1 = model.photos[0]
         self.image2 = model.photos[safeIndex: 2]
         self.image3 = model.photos[safeIndex: 3]
         self.image4 = model.photos[safeIndex: 4]
         self.image5 = model.photos[safeIndex: 5]
         self.image6 = model.photos[safeIndex: 6]
         self.mobile_number = mobile
         self.country_code = code
         self.name = name
         self.gender = gender
         self.match_with = match
         self.dob = User.dobFormatter.string(from: dob)
         self.email = email
         self.about_me = about
     }
 }

 extension RegisterRequest: MultipartRequest {
             
     var files: [String: Data] {
         let images = [image1, image2, image3, image4, image5, image6]
         var imageData = [String: Data]()
         for (count, image) in images.enumerated() {
             let name = "image\(count + 1)"
             if let imageFound = image {
                 imageData[name] = imageFound.toJPEGData
             }
         }
         return imageData
     }
     
     var fields: [String: String] {
         let fields = ["mobile_number": mobile_number,
                       "country_code": country_code,
                       "name": name,
                       "gender": gender.rawValue,
                       "match_with": match_with.rawValue,
                       "dob": dob,
                       "email": email,
                       "about_me": about_me]
         return fields
     }
     
 }
 
 
 */

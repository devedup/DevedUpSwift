//
//  File.swift
//  
//
//  Created by David Casserly on 04/09/2020.
//

import Foundation
import UIKit
import DevedUpSwiftFoundation

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
        let data = self.jpegData(compressionQuality: 0.8) ?? Data()
        if Debug.isDebugging() {
            print("Image compressed size is \(data.count)")
        }
        return data
    }
}

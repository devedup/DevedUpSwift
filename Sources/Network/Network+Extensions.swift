//
//  File.swift
//  
//
//  Created by David Casserly on 13/07/2021.
//

import Foundation

public extension String {
    var urlQueryEncoded: String {
        var characterSet = CharacterSet.urlQueryAllowed
        characterSet.remove("+")
        return addingPercentEncoding(withAllowedCharacters: characterSet)!
    }
    var urlPathEncoded: String {
        var characterSet = CharacterSet.urlPathAllowed
        characterSet.remove("@")
        return addingPercentEncoding(withAllowedCharacters: characterSet)!
    }
}

//public extension URL {
//    var queryParameters: QueryParameters { return QueryParameters(url: self) }
//}
//
//public class QueryParameters {
//    let queryItems: [URLQueryItem]
//    public init(url: URL?) {
//        queryItems = URLComponents(string: url?.absoluteString ?? "")?.queryItems ?? []
//        print(queryItems)
//    }
//    subscript(name: String) -> String? {
//        return queryItems.first(where: { $0.name == name })?.value
//    }
//}

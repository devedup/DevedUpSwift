//
//  File.swift
//  
//
//  Created by David Casserly on 02/03/2020.
//

import Foundation
import DevedUpSwiftFoundation

public final class APILogger {
    
    private static let backgroundQueue = DispatchQueue(label: "NetworkLogger", attributes: .concurrent)
    
    static var logDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "HH:mm:ss:sss"
        return formatter
    }()
    
    private let logger: Loggable
    
    public init(logger: Loggable) {
        self.logger = logger
    }

    func log(message: String) {
        logger.write(message)
    }
    
    public func log(request: URLRequest?, response: HTTPURLResponse?, responseData: Data?, isLogin: Bool = false) {
        APILogger.backgroundQueue.async {
            if let request = request, let response = response {
                if let url = request.url {
                    var logString = "\n[>>>>> START REQUEST \(APILogger.logDateFormatter.string(from: Date()))]\n"
                    logString.append("\(request.httpMethod ?? "GET") \(request)")
                    
                    logString.append("\n[HEADERS]")
                    if let headers = request.allHTTPHeaderFields {
                        for header in headers {
                            logString.append("\n\(header.key) = \(header.value)")
                        }
                    }
                    
                    if let body = request.httpBody,
                        var bodyString = String(data: body, encoding: String.Encoding.utf8) {
                        if isLogin {
                            self.removePassword(from: &bodyString)
                        }
                        logString.append("\n[REQUEST BODY]")
                        logString.append("\n\(bodyString)")
                    }
                    
                    logString.append("\n[RESPONSE \(response.statusCode)]")
                    let responseHeaders = response.allHeaderFields
                    for header in responseHeaders {
                        logString.append("\n\(header.key) = \(header.value)")
                    }
                    
                    if let responseData = responseData {
                        var dataToPrint = responseData
                        do {
                            let jsonObject = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                            if JSONSerialization.isValidJSONObject(jsonObject) {
                                dataToPrint = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                            }
                        } catch {
                            //ignore
                        }
                        if let jsonString = String(data: dataToPrint, encoding: .utf8) {
                            logString.append("\n[RESPONSE DATA]")
                            logString.append("\n\(jsonString)")
                        }
                    }
                    logString.append("\n[END REQUEST \(APILogger.logDateFormatter.string(from: Date())) <<<<<]\n")
                    
                    // Write to file
                    self.logger.write(logString)                                        
                }
            }
        }
    }
    
    private func removePassword(from string: inout String) {
        let pattern = #".*(?:"password":")(?<password>.*?)(?:").*"#
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let range = NSRange(string.startIndex..<string.endIndex, in: string)
            if let match = regex.firstMatch(in: string, options: [], range: range) {
                let passwordRange = match.range(withName: "password")
                if passwordRange.location != NSNotFound, let range = Range(passwordRange, in: string) {
                    string = string.replacingCharacters(in: range, with: "********")
                }
            }
        }
    }
    
}

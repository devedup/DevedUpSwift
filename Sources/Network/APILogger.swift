//
//  File.swift
//  
//
//  Created by David Casserly on 02/03/2020.
//

import Foundation

public protocol APIServiceLogger {
    func log(_ message: String)
    func log(request: URLRequest?, response: HTTPURLResponse?, responseData: Data?, isLogin: Bool)
}

public class DefaultAPIServiceLogger: APIServiceLogger {
    
    public init() {}
    
    public func log(_ message: String) {
        print(message)
    }
    
    public func log(request: URLRequest?, response: HTTPURLResponse?, responseData: Data?, isLogin: Bool = false) {
        NetworkLogger.log(request: request, response: response, responseData: responseData, isLogin: isLogin)
    }
    
}

final class NetworkLogger {
    
    private static let backgroundQueue = DispatchQueue(label: "NetworkLogger", attributes: .concurrent)
    
    private init() {}
    
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        return formatter
    }()
    
    static var logDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "HH:mm:ss:sss"
        return formatter
    }()
    
    private static func logFile(path: String) -> URL {
        let filename = "\(dateFormatter.string(from: Date())).txt"
        let pathFolder = path.replacingOccurrences(of: "/", with: "_")
        let fm = FileManager.default
        let directory = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("logs").appendingPathComponent("http").appendingPathComponent(pathFolder)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        let file = directory.appendingPathComponent(filename)
        return file
    }
    
    private static func write(_ string: String, to logFile: URL) {
        do {
            let data = string.data(using: .utf8)
            try data?.write(to: logFile)
//            let created = FileManager.default.createFile(atPath: logFile.absoluteString, contents: nil, attributes: nil)
//            print(created)
//            let handle = try FileHandle(forWritingTo: logFile)
//            handle.seekToEndOfFile()
//            handle.write(string.data(using: .utf8)!)
//            handle.closeFile()
        } catch {
            print(error)
        }
    }
    
//    func writeDataToFile(file:String)-> Bool{
//        // check our data exists
//        guard let data = textView.text else {return false}
//        print(data)
//        //get the file path for the file in the bundle
//        // if it doesnt exisit, make it in the bundle
//        var fileName = file + ".txt"
//        if let filePath = NSBundle.mainBundle().pathForResource(file, ofType: "txt"){
//            fileName = filePath
//        } else {
//            fileName = NSBundle.mainBundle().bundlePath + fileName
//        }
//        //write the file, return true if it works, false otherwise.
//        do{
//            try data.writeToFile(fileName, atomically: true, encoding: NSUTF8StringEncoding )
//            return true
//        } catch{
//            return false
//        }
//    }
    
    static func log(request: URLRequest?, response: HTTPURLResponse?, responseData: Data?, isLogin: Bool = false) {
        backgroundQueue.async {
            if let request = request, let response = response {
                if let url = request.url {
                    let logFileURL = logFile(path: url.path)
                    
                    var logString = "\n[>>>>> START REQUEST \(logDateFormatter.string(from: Date()))]\n"
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
                            removePassword(from: &bodyString)
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
                    logString.append("\n[END REQUEST \(logDateFormatter.string(from: Date())) <<<<<]\n")
                    
                    #if targetEnvironment(simulator)
                        print(logString)
                    #else
                    if NetworkLogger.isDebugging() {
                        print(logString)
                    } else {
                        write(logString, to: logFileURL)
                        print(logString)
                    }
                    #endif
                }
            }
        }
    }
    
    private static func isDebugging() -> Bool {
        let dic = ProcessInfo.processInfo.environment
        if dic["xcodetesting"] == "true" {
            return true
        } else {
            return false
        }
    }
    
    private static func removePassword(from string: inout String) {
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

//
//  FileLogger.swift
//  
//
//  Created by David Casserly on 21/04/2020.
//

import Foundation

public struct FileLogger: TextOutputStream, Loggable {
    
    private let fileNamePrefix: String
    
    public init(fileNamePrefix: String) {
        self.fileNamePrefix = fileNamePrefix
    }
    
    private static var fileNameFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private var fileName: String {
        // The file name is the year, month and day... so on a new day it will roll over onto a new file
        let date = Date()
        return "\(fileNamePrefix)_\(FileLogger.fileNameFormatter.string(from: date)).txt"
    }

    private var logFile: URL {
        let fm = FileManager.default
        let directory = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("logs")
        let file = directory.appendingPathComponent(fileName)
        if !fm.fileExists(atPath: file.absoluteString) {
            try? fm.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        }
        return file
    }
    
    public func write(_ string: String) {
        // If we're debugging,
        #if targetEnvironment(simulator)
            print(string)
        #else
            if Debug.isDebugging() {
                print(string)
            }
        #endif
        
        if let handle = try? FileHandle(forWritingTo: logFile) {
            handle.seekToEndOfFile()
            handle.write(string.data(using: .utf8)!)
            handle.closeFile()
        } else {
            ((try? string.data(using: .utf8)?.write(to: logFile)) as ()??)
        }
    }

}

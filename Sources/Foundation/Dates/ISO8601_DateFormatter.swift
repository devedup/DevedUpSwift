//
//  File.swift
//  
//
//  Created by David Casserly on 17/08/2020.
//

import Foundation

//extension DateFormatter {
//    static let iso8601Full: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
//        formatter.calendar = Calendar(identifier: .iso8601)
//        formatter.timeZone = TimeZone(secondsFromGMT: 0)
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//        return formatter
//    }()
//}

extension ISO8601DateFormatter {
    
    public static var iso8601FormatterWithMilliseconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()

        // GMT or UTC -> UTC is standard, GMT is TimeZone
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        formatter.formatOptions = [.withInternetDateTime,
                                   .withDashSeparatorInDate,
                                   .withColonSeparatorInTime,
                                   .withTimeZone,
                                   .withFractionalSeconds]
        return formatter
    }()

    /// Formatter for ISO8601 without milliseconds
    public static var iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()

        // GMT or UTC -> UTC is standard, GMT is TimeZone
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        formatter.formatOptions = [.withInternetDateTime,
                                   .withDashSeparatorInDate,
                                   .withColonSeparatorInTime,
                                   .withTimeZone]
        return formatter
    }()
    
}



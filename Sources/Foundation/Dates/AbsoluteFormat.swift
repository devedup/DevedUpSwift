//
//  File.swift
//  
//
//  Created by David Casserly on 23/06/2022.
//

import Foundation

extension Date {
    
    private static var todayFormatter: DateFormatter = {
        let format = DateFormatter()
        format.dateFormat = "HH:mm"
        return format
    }()
    
    private static var weekFormatter: DateFormatter = {
        let format = DateFormatter()
        format.dateFormat = "EEEE HH:mm"
        return format
    }()
    
    private static var yearFormatter: DateFormatter = {
        let format = DateFormatter()
        format.dateFormat = "E, d MMM, HH:mm"
        return format
    }()
    
    private static var defaultFormatter: DateFormatter = {
        let format = DateFormatter()
        format.dateFormat = "MMM d, yyyy, HH:mm"
        return format
    }()
    
    public func absoluteVariableFormat() -> String {
        let now = Date()
        switch true {
        case Calendar.current.isDateInToday(self):
//            return Date.todayFormatter.localizedString(for: self, relativeTo: now);
            return Date.todayFormatter.string(from: self)
        case Calendar.current.isDateInYesterday(self):
            return Date.weekFormatter.string(from: self)
        case Calendar.current.isDate(self, equalTo: now, toGranularity: .weekOfYear):
            return Date.weekFormatter.string(from: self)
        case Calendar.current.isDate(self, equalTo: now, toGranularity: .year):
            return Date.yearFormatter.string(from: self)
        default:
            return Date.defaultFormatter.string(from: self)
        }
    }
    
}

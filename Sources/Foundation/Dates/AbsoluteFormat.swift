//
//  File.swift
//  
//
//  Created by David Casserly on 23/06/2022.
//

import Foundation

extension Date {
    
    private static var hourMinuteFormat: DateFormatter = {
        let format = DateFormatter()
        format.dateFormat = "HH:mm"
        return format
    }()
    
    private static var dayOfWeekFormat: DateFormatter = {
        let format = DateFormatter()
        format.dateFormat = "E, HH:mm"
        return format
    }()
        
    private static var currentYearFormatter: DateFormatter = {
        let format = DateFormatter()
        format.dateFormat = "E dd MMM, HH:mm"
        return format
    }()
    
    private static var defaultFormatter: DateFormatter = {
        let format = DateFormatter()
        format.dateFormat = "dd MMM yyyy, HH:mm"
        return format
    }()
    
    public func absoluteVariableFormat() -> String {
        let now = Date()
        let calendar = Calendar.current
                
        if(calendar.isDateInToday(self)) {
            return Date.hourMinuteFormat.string(from: self)
        } else if(calendar.isDateInYesterday(self)) {
            return "date.yesterday".localized + " \(Date.hourMinuteFormat.string(from: self))"
        } else {
            let components = calendar.dateComponents([.day, .hour, .minute], from: self, to: now)
            guard let day = components.day else {
                return Date.defaultFormatter.string(from: self)
            }
            
            switch day {
            case 2...7:
                //If earlier than yesterday, but less than 7 days ago Name of the day (ie: Tuesday)
                return Date.dayOfWeekFormat.string(from: self)
            default:
                if (Calendar.current.isDate(self, equalTo: now, toGranularity: .year)) {
                    return Date.currentYearFormatter.string(from: self)
                } else {
                    return Date.defaultFormatter.string(from: self)
                }
            }
        }
    }
    
}

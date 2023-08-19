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
    
    private static var dayOfWeekWithTimeFormat: DateFormatter = {
        let format = DateFormatter()
        format.dateFormat = "E, HH:mm"
        return format
    }()
    
    private static var weekDayFormat: DateFormatter = {
        let format = DateFormatter()
        format.dateFormat = "EEEE"
        return format
    }()
    
    private static var yearFormatter: DateFormatter = {
        let format = DateFormatter()
        format.dateFormat = "dd/MMM/yyyy"
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
                return Date.dayOfWeekWithTimeFormat.string(from: self)
            default:
                if (Calendar.current.isDate(self, equalTo: now, toGranularity: .year)) {
                    return Date.currentYearFormatter.string(from: self)
                } else {
                    return Date.defaultFormatter.string(from: self)
                }
            }
        }
    }
    
    public func absoluteTimeWithAgoFormat() -> String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self, to: now)

        guard let day = components.day else {
            return Date.defaultFormatter.string(from: self)
        }
        
        // If TODAY
        if(calendar.isDateInToday(self)) {
            return Date.hourMinuteFormat.string(from: self)
        // If YESTERDAY
        } else if(calendar.isDateInYesterday(self)) {
            return "date.yesterday".localized
        // IF OLDER
        } else {
            switch day {
            case 0...7:
                //If earlier than yesterday, but less than 7 days ago Name of the day (ie: Tuesday)
                return Date.weekDayFormat.string(from: self)
            case 7...365:
                return "\(day)d"
            case 365...Int.max:
                let components = calendar.dateComponents([.year], from: self, to: now)
                guard let year = components.year else {
                    return Date.defaultFormatter.string(from: self)
                }
                
                return "\(year)y"
            default:
                return Date.defaultFormatter.string(from: self) // shouldn't get here
            }
        }
        
        
//        let now = Date()
//        let calendar = Calendar.current
//        let components = calendar.dateComponents([.day], from: self, to: now)
//
//        guard let day = components.day else {
//            return Date.defaultFormatter.string(from: self)
//        }
//
//        // If TODAY
//        if(calendar.isDateInToday(self)) {
//            return Date.hourMinuteFormat.string(from: self)
//        // If YESTERDAY
//        } else if(calendar.isDateInYesterday(self)) {
//            return "date.yesterday".localized
//        // IF OLDER
//        } else {
//            switch day {
//            case 2...7:
//                return Date.weekDayFormat.string(from: self)
//            case 7...Int.max:
//                return "\(day)d"
//            default:
//                return Date.defaultFormatter.string(from: self) // shouldn't get here
//            }
//        }
        
        
//     return Date.defaultFormatter.string(from: self)
//        }
//
//        switch day {
//        case 0...1:
//            return Date.hourMinuteFormat.string(from: self)
//        case 1...2:
//            return "date.yesterday".localized
//        case 2...7:
//            //If earlier than yesterday, but less than 7 days ago Name of the day (ie: Tuesday)
//            return Date.weekDayFormat.string(from: self)
//        case 7...Int.max:
//            return "\(day)d"
//        default:
//            if (Calendar.current.isDate(self, equalTo: now, toGranularity: .year)) {
//                return Date.currentYearFormatter.string(from: self)
//            } else {
//                return Date.defaultFormatter.string(from: self)
//            }
//        }
        
    }
    
}

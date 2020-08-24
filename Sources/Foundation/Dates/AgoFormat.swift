//
//  File.swift
//  
//
//  Created by David Casserly on 17/08/2020.
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
        format.dateFormat = "EEEE HH:mm"
        return format
    }()
    
    private static var dateFormat: DateFormatter = {
        let format = DateFormatter()
        format.dateFormat = "E dd MMM, HH:mm"
        return format
    }()
    
    // Requirement to have HH:mm format for 1 to 24 hrs, and 'ago' format for the others
    //swiftlint:disable:next cyclomatic_complexity
    public func agoFormat() -> String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour, .minute], from: self, to: now)

        if let day = components.day {
            switch day {
            case 1:
                // If yesterday Yesterday
                return "date.yesterday".localized + " \(Date.hourMinuteFormat.string(from: self))"
            case 2...7:
                //If earlier than yesterday, but less than 7 days ago Name of the day (ie: Tuesday)
                return Date.dayOfWeekFormat.string(from: self)
            case 7...Int.max:
                return Date.dateFormat.string(from: self)
            default:
                break
            }
            
        }
        
        // If between 61mins and the end of the current day  HH:MM
        if let hour = components.hour {
            if 1...24 ~= hour {
                return "Today".localized + " \(Date.hourMinuteFormat.string(from: self))"
            }
        }
        
        if let minute = components.minute {
            switch minute {
            case 2...60:
                // If between 2 and 60 minutes, X mins ago (plural)
                return "date.minutes.ago".localized(with: "\(minute)")
            case 1...2:
                // If between 1 and 2 minutes, X min ago (singular)
                return "date.one.minute.ago".localized
            default:
                break
            }
        }
        
        // If less than a minute, 'Just now'
        return "date.just.now".localized
    }

}

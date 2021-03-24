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
        //format.timeZone = TimeZone(abbreviation: "UTC")
        return format
    }()
    
    private static var dayOfWeekFormat: DateFormatter = {
        let format = DateFormatter()
        format.dateFormat = "EEEE HH:mm"
        //format.timeZone = TimeZone(abbreviation: "UTC")
        return format
    }()
    
    private static var dateFormat: DateFormatter = {
        let format = DateFormatter()
        format.dateFormat = "E dd MMM, HH:mm"
        //format.timeZone = TimeZone(abbreviation: "UTC")
        return format
    }()
    
    // it's here but doesn't quite fit needs....
    // shows 2 hours ago... instead of like Yesterday 15:35
    private static var relativeFormat: RelativeDateTimeFormatter = {
        let format = RelativeDateTimeFormatter()
        format.dateTimeStyle = .named
        return format
    }()
    
    public func vagueAgoFormat() -> String {
        let now = Date()
        return Date.relativeFormat.localizedString(for: self, relativeTo: now);
    }
    
    // Requirement to have HH:mm format for 1 to 24 hrs, and 'ago' format for the others
    //swiftlint:disable:next cyclomatic_complexity
    public func agoFormat() -> String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour, .minute], from: self, to: now)

        guard let day = components.day, let hour = components.hour, let minute = components.minute else {
            return Date.dateFormat.string(from: self)
        }
        
        // If TODAY
        if(calendar.isDateInToday(self)) {
            // If between 61mins and the end of the current day  HH:MM
            if 1...24 ~= hour {
                return "Today".localized + " \(Date.hourMinuteFormat.string(from: self))"
            } else {
                switch minute {
                case 2...60:
                    // If between 2 and 60 minutes, X mins ago (plural)
                    return "date.minutes.ago".localized(with: "\(minute)")
                case 1...2:
                    // If between 1 and 2 minutes, X min ago (singular)
                    return "date.one.minute.ago".localized
                default:
                    // If less than a minute, 'Just now'
                    return "date.just.now".localized
                }
            }
        // If YESTERDAY
        } else if(calendar.isDateInYesterday(self)) {
            return "date.yesterday".localized + " \(Date.hourMinuteFormat.string(from: self))"
        // IF OLDER
        } else {
            switch day {
            case 2...7:
                //If earlier than yesterday, but less than 7 days ago Name of the day (ie: Tuesday)
                return Date.dayOfWeekFormat.string(from: self)
            case 7...Int.max:
                return Date.dateFormat.string(from: self)
            default:
                return Date.dateFormat.string(from: self) // shouldn't get here
            }
        }
    }
    
    // This won't show the minutes ago
    public func liveMessagingDateFormat() -> String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self, to: now)

        guard let day = components.day else {
            return Date.dateFormat.string(from: self)
        }
        
        // If TODAY
        if(calendar.isDateInToday(self)) {
            return Date.hourMinuteFormat.string(from: self)
        // If YESTERDAY
        } else if(calendar.isDateInYesterday(self)) {
            return "date.yesterday".localized + " \(Date.hourMinuteFormat.string(from: self))"
        // IF OLDER
        } else {
            switch day {
            case 2...7:
                //If earlier than yesterday, but less than 7 days ago Name of the day (ie: Tuesday)
                return Date.dayOfWeekFormat.string(from: self)
            case 7...Int.max:
                return Date.dateFormat.string(from: self)
            default:
                return Date.dateFormat.string(from: self) // shouldn't get here
            }
        }
    }

}

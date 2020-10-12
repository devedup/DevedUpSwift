//  Created by David Casserly on 07/11/2019.
//

import Foundation

fileprivate extension Calendar {
    
    static let devedupCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.autoupdatingCurrent
        calendar.firstWeekday = 2
        return calendar
    }()
    
}

extension Date {
    
    public var year: Int {
        let calendar = Calendar.devedupCalendar
        let year = calendar.component(.year, from: self)
        return year
    }
    
    public var yesterday: Date {
        let calendar = Calendar.devedupCalendar
        let yesterday = calendar.date(byAdding: .day, value: -1, to: self) ?? self
        return yesterday
    }
    
    public var oneWeekAgo: Date {
        let calendar = Calendar.devedupCalendar
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: self) ?? self
        return weekAgo
    }
    
    public var oneMonthAgo: Date {
        let calendar = Calendar.devedupCalendar
        let weekAgo = calendar.date(byAdding: .month, value: -1, to: self) ?? self
        return weekAgo
    }
    
    public var tomorrow: Date {
        let calendar = Calendar.devedupCalendar
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: self) ?? self
        return tomorrow
    }
    
    public var oneWeekAhead: Date {
        let calendar = Calendar.devedupCalendar
        let weekAhead = calendar.date(byAdding: .day, value: 7, to: self) ?? self
        return weekAhead
    }
    
    public var oneMonthAhead: Date {
        let calendar = Calendar.devedupCalendar
        let monthAhead = calendar.date(byAdding: .month, value: 1, to: self) ?? self
        return monthAhead
    }
    
    public var numberOfDaysInThisMonth: Int {
        let calendar = Calendar.devedupCalendar
        let range = calendar.range(of: .day, in: .month, for: self)
        return range?.count ?? 0
    }
    
    public func dateBySubtracting(minutes: Int) -> Date {
        let calendar = Calendar.devedupCalendar
        let minutesBehind = calendar.date(byAdding: .minute, value: -minutes, to: self) ?? self
        return minutesBehind
    }
    
    public func dateBySubtracting(years: Int) -> Date {
        let calendar = Calendar.devedupCalendar
        let yearsBehind = calendar.date(byAdding: .year, value: -years, to: self) ?? self
        return yearsBehind
    }
    
    public func dateByAdding(minutes: Int) -> Date {
        let calendar = Calendar.devedupCalendar
        let minutesAhead = calendar.date(byAdding: .minute, value: minutes, to: self) ?? self
        return minutesAhead
    }
    
    public func dateByAdding(seconds: Int) -> Date {
        let calendar = Calendar.devedupCalendar
        let secondsAhead = calendar.date(byAdding: .second, value: seconds, to: self) ?? self
        return secondsAhead
    }
    
    public func hourMinuteAsDecimal() -> Double {
        let calendar = Calendar.devedupCalendar
        let hour = calendar.component(.hour, from: self)
        let minute = calendar.component(.minute, from: self)
        let minuteDecimal = Double(minute) / 60.0
        return Double(hour) + minuteDecimal
    }
    
    public func oneMinuteAgo() -> Date {
        let calendar = Calendar.devedupCalendar
        let oneMInuteAgo = calendar.date(byAdding: .minute, value: -1, to: self) ?? self
        return oneMInuteAgo
    }
    
    public func minutesAgo(minutes: Int) -> Date {
        let calendar = Calendar.devedupCalendar
        let minutesAgo = calendar.date(byAdding: .minute, value: -minutes, to: self) ?? self
        return minutesAgo
    }
    
    public func secondsAgo(seconds: Int) -> Date {
        let calendar = Calendar.devedupCalendar
        let secondsAgo = calendar.date(byAdding: .second, value: -seconds, to: self) ?? self
        return secondsAgo
    }
    
    public func secondsLater(seconds: Int) -> Date {
        let calendar = Calendar.devedupCalendar
        let secondsLater = calendar.date(byAdding: .second, value: seconds, to: self) ?? self
        return secondsLater
    }
    
    public var currentYear: Int {
        let calendar = Calendar.devedupCalendar
        let year = calendar.component(.year, from: self)
        return year
    }
    
}

fileprivate struct TimeOffset {
    
    let seconds: Int
    let minutes: Int
    let hours: Int
    let days: Int
    
}

extension Date {

    private func offset(from date : Date) -> TimeOffset {
        let dayHourMinuteSecond: Set<Calendar.Component> = [.day, .hour, .minute, .second]
        let difference = NSCalendar.current.dateComponents(dayHourMinuteSecond, from: date, to: self);

        let seconds = abs(difference.second ?? 0)
        let minutes = abs(difference.minute ?? 0)
        let hours = abs(difference.hour ?? 0)
        let days = abs(difference.day ?? 0)

        return TimeOffset(seconds: seconds, minutes: minutes, hours: hours, days: days)
    }
    
    public func isOneDayAgo(from: Date) -> Bool {
        let offset = self.offset(from: from)
        switch offset.days {
        case 1:
            // 1 day, check the hours/mins/seconds
            if (offset.hours + offset.minutes + offset.seconds) >= 1 {
                return true
            } else {
                return false
            }
        case 0:
            // no days
            return false
        default:
            // more than one day
            return true
        }
    }

}

// Truxtun on es
extension Date {
    
    public func threeMonthsAgo() -> Date {
        var calendar = Calendar.autoupdatingCurrent
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: self)
        return threeMonthsAgo!
    }
    
    public func dateByRemovingTime() -> Date {
        // Use the user's current calendar and time zone
        var calendar = Calendar.autoupdatingCurrent
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        let dateComps = calendar.dateComponents([.year, .month, .day], from: self)
        let beginningOfDay: Date? = calendar.date(from: dateComps)
        return beginningOfDay!
    }
    
    public func dateWithYearAndMonth() -> Date {
        // Use the user's current calendar and time zone
        var calendar = Calendar.autoupdatingCurrent
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        let dateComps = calendar.dateComponents([.year, .month], from: self)
        let beginningOfDay: Date? = calendar.date(from: dateComps)
        return beginningOfDay!
    }
    
    public func isBetween13and18years() -> Bool {
        let today = Date()
        var calendar = Calendar.autoupdatingCurrent
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        let age: DateComponents =  calendar.dateComponents([Calendar.Component.year], from: self, to: today)
        if age.year! < 13 || age.year! >= 18 {
            return false
        } else {
            return true
        }
    }
    
}

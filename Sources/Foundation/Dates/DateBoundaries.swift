//
//  File.swift
//  
//
//  Created by David Casserly on 06/01/2022.
//

import Foundation

extension Date {
    
    var startOfDay: Date {
        let calendar = Calendar.devedupCalendar
        let yesterday = self.yesterday
        //swiftlint:disable force_unwrapping
        let yesterdayAtMidnight = calendar.date(bySettingHour: 0,
                                          minute: 0,
                                          second: 0,
                                          of: yesterday,
                                          direction: .backward)!
//        //swiftlint:disable force_unwrapping
//        let yesterdayAt12 = calendar.date(bySettingHour: 20,
//                                                 minute: 0,
//                                                 second: 0,
//                                                 of: yesterdayAtMidnight,
//                                                 direction: .forward)!
        return yesterdayAtMidnight
    }
    
    var endOfDay: Date {
        let calendar = Calendar.devedupCalendar
        //swiftlint:disable force_unwrapping
        let todayAtEleven59 = calendar.date(bySettingHour: 23,
                                                  minute: 59,
                                                  second: 59,
                                                  of: self,
                                                  direction: .forward)!
        return todayAtEleven59
    }
    
//    var startOfWeek: Date? {
//        let calendar = Calendar.devedupCalendar
//        let firstDayOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) ?? self
//        return firstDayOfWeek
//    }
//
//
//    var endOfWeek: Date? {
//        let calendar = Calendar.devedupCalendar
//        let weekLater = calendar.date(byAdding: .day, value: 6, to: self) ?? self
//        let weekLaterAt10am = calendar.date(bySetting: .hour, value: 10, of: weekLater)
//        return weekLaterAt10am
//    }
//
//    // MARK: - Sleep Month
//
//    var startOfSleepMonth: Date? {
//        let calendar = Calendar.current
//        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: self)) ?? self
//        let dayBefore = calendar.date(byAdding: .day, value: -1, to: firstDayOfMonth) ?? self
//        let dayBefore10pm = calendar.date(bySetting: .hour, value: 22, of: dayBefore)
//        return dayBefore10pm
//    }
//
//    var endOfSleepMonth: Date? {
//        let calendar = Calendar.current
//        let endOfMonth = calendar.date(byAdding: .month, value: 1, to: self) ?? self
//        //let dayBefore = calendar.date(byAdding: .day, value: -1, to: endOfMonth) ?? self
//        let endOfMonthAfternoon = calendar.date(bySetting: .hour, value: 13, of: endOfMonth)
//        return endOfMonthAfternoon
//    }
    
}

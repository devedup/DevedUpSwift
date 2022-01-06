//  DataPeriod.swift
//
//  Copyright © 2018 DevedUpLtd. All rights reserved.
//

import Foundation
import DevedUpSwiftFoundation

struct PeriodBoundary {
    let start: Date
    let end: Date
}

enum DataPeriod {
    
//    case day (Date)
//    case week (Date)
//    case month (Date)
//    case previous7Days (Date)
//    
//    var date: Date {
//        switch self {
//        case .day(let date), .month(let date), .week(let date), .previous7Days(let date):
//            return date
//        }
//    }
//
//    var periodBoundaries: (start: Date?, end: Date?) {
//        switch self {
//        case .day:
//            let startOfDay = date.startOfSleepDay
//            let endOfDay = date.endOfSleepDay
//            return (start: startOfDay, end: endOfDay)
//        case .week:
//            let startOfWeek = date.startOfSleepWeek
//            let endOfWeek = startOfWeek?.endOfSleepWeek
//            return (start: startOfWeek, end: endOfWeek)
//        case .month:
//            let startOfMonth = date.startOfSleepMonth
//            let endOfMonth = startOfMonth?.endOfSleepMonth
//            return (start: startOfMonth, end: endOfMonth)
//        case .previous7Days:
//            let startOfWeek = date.oneWeekAgo
//            let endOfWeek = date
//            return (start: startOfWeek, end: endOfWeek)
//        }
//    }
//    
//    // If you're gathering sleep data for 7 days, you can't naively use the start and end date, and this contains awake time too. You need to get the sleep boundaries for eadh individual day, i.e. 8pm to 8am, each day. You will then use this in your db query
//    var dayPeriodBoundaries: [SleepPeriodBoundary] {
//        switch self {
//        case .day:
//            let period = SleepPeriodBoundary(start: date.startOfSleepDay, end: date.endOfSleepDay)
//            return [period]
//        case .previous7Days:
//            // We now have 7 days of dates here
//            let startOfWeek = date.oneWeekAgo
//            let endOfWeek = date
//            var periods = [SleepPeriodBoundary]()
//            
//            var loopDate = startOfWeek
//            while loopDate <= endOfWeek {
//                let period = SleepPeriodBoundary(start: loopDate.startOfSleepDay, end: loopDate.endOfSleepDay)
//                periods.append(period)
//                // swiftlint:disable force_unwrapping
//                loopDate = Calendar.current.date(byAdding: .day, value: 1, to: loopDate)!
//            }
//            return periods
//        default:
//            preconditionFailure("Not supported yet")
//        }
//    }
//    
    
}

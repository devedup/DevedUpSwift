//
//  File.swift
//  
//
//  Created by David Casserly on 27/03/2020.
//

import Foundation

public struct GroupdByDayViewModel<T> {
    public let groupedByDay: [Date: [T]]
    public let sortedDates: [Date]
    
    public init(groupedByDay: [Date: [T]], sortedDates: [Date]) {
        self.groupedByDay = groupedByDay
        self.sortedDates = sortedDates
    }
}

public protocol DateSortable {
    var dateForSorting: Date { get }
}

extension Collection where Element: DateSortable {
    public func groupByDay() -> GroupdByDayViewModel<Element> {
        var sections: [Date: [Element]] = [:]
        var sortedDays: [Date] = []
        
        for item in self {
            let dateRepresentingThisDay = item.dateForSorting.dateByRemovingTime()
            var eventsOnThisDay = sections[dateRepresentingThisDay]
            if eventsOnThisDay == nil {
                eventsOnThisDay = [item]
            } else {
                eventsOnThisDay?.append(item)
            }
            sections.updateValue(eventsOnThisDay!, forKey: dateRepresentingThisDay)
            
            sortedDays = sections.keys.sorted(by: { (first, second) -> Bool in
                return first.compare(second) == ComparisonResult.orderedDescending
            })
        }
        return GroupdByDayViewModel<Element>(groupedByDay: sections, sortedDates: sortedDays)
    }
}

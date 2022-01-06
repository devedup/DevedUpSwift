//  HealthKitService.swift
//  SimbaSleep
//
//  Copyright © 2018 SimbaSleep. All rights reserved.
//

import Foundation
import HealthKit
import DevedUpSwiftFoundation

private let hasViewedHealthKitPermission = "hasViewedHealthKitPermission"

public protocol HealthKitService {
}

public class DefaultHealthKitService: HealthKitService {
    
    let healthStore = HKHealthStore()
    
    static let fitnessMetrics = [HKQuantityTypeIdentifier.stepCount]
    
    var hasRequestedHealthKitAccess: Bool {
        return UserDefaults.standard.bool(forKey: hasViewedHealthKitPermission)
    }
    
    func requestAccess(metrics: [HKQuantityTypeIdentifier] = DefaultHealthKitService.fitnessMetrics,
                       completion: @escaping AsyncResultCompletion<Bool>) {
        guard UserDefaults.standard.bool(forKey: hasViewedHealthKitPermission) == false else {
            completion(.failure(FoundationError.HealthKitError(nil)))
            return
        }
        
        if HKHealthStore.isHealthDataAvailable() {
            //swiftlint:disable:next force_unwrapping
            let quantityMetrics = Set( metrics.map { HKQuantityType.quantityType(forIdentifier: $0)! } )
            
            //  A Boolean value that indicates whether the request was processed successfully. This value does not indicate whether permission was actually granted. This parameter is NO if an error occurred while processing the request; otherwise, it is YES.
            healthStore.requestAuthorization(toShare: quantityMetrics, read: quantityMetrics) { (success, error) in
                UserDefaults.standard.set(true, forKey: hasViewedHealthKitPermission)
                UserDefaults.standard.synchronize()
                DispatchQueue.main.async {
                    guard success == true else {
                        completion(.failure(FoundationError.HealthKitError(error)))
                        return
                    }
                    completion(.success(true))
                }
            }
            
        }
    }

//    func queryData(metrics: [HKQuantityTypeIdentifier] = DefaultHealthKitService.fitnessMetrics,
//                       completion: @escaping AsyncResultCompletion<(count: Int, date: Date)>) {
//        // first, we define the object type we want
//        if let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
//            // Use a sortDescriptor to get the recent data first
//            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
//
//            // we create our query with a block completion to execute
//            let query = HKSampleQuery(sampleType: sleepType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
//
//                DispatchQueue.main.async {
//                    if error != nil {
//                        completion(.failure(AppErrorType.HealthKit.healthKit(error)))
//                        return
//
//                    }
//
//                    if let result = tmpResult {
//                        let first = result.first?.endDate ?? Date()
//                        completion(.success((result.count, first)))
//                    }
//                }
//            }
//
//            // finally, we execute our query
//            healthStore.execute(query)
//        }
//    }
    
    func requestData(metric: HKQuantityTypeIdentifier,
                          completion: @escaping AsyncResultCompletion<[HKSample]>) {
        // first, we define the object type we want
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: metric) else {
            fatalError()
        }
            
            
        let calendar = Calendar.devedupCalendar
        let interval = DateComponents(day: 7)
        // Set the anchor for 3 a.m. on Monday.
        let components = DateComponents(calendar: calendar,
                                        timeZone: calendar.timeZone,
                                        hour: 3,
                                        minute: 0,
                                        second: 0,
                                        weekday: 2)

        guard let anchorDate = calendar.nextDate(after: Date(),
                                                 matching: components,
                                                 matchingPolicy: .nextTime,
                                                 repeatedTimePolicy: .first,
                                                 direction: .backward) else {
            fatalError("*** unable to find the previous Monday. ***")
        }
            
        // Create the query.
        let query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
           
        // Set the results handler.
        query.initialResultsHandler = {
            query, results, error in
            
            // Handle errors here.
            if let error = error as? HKError {
                switch (error.code) {
                case .errorDatabaseInaccessible:
                    // HealthKit couldn't access the database because the device is locked.
                    return
                default:
                    // Handle other HealthKit errors here.
                    return
                }
            }
            
            guard let statsCollection = results else {
                // You should only hit this case if you have an unhandled error. Check for bugs
                // in your code that creates the query, or explicitly handle the error.
                assertionFailure("")
                return
            }
        
            let endDate = Date()
                let threeMonthsAgo = DateComponents(month: -3)
                
                guard let startDate = calendar.date(byAdding: threeMonthsAgo, to: endDate) else {
                    fatalError("*** Unable to calculate the start date ***")
                }
                
                // Plot the weekly step counts over the past 3 months.
                //var weeklyData = MyWeeklyData()
                
                // Enumerate over all the statistics objects between the start and end dates.
                statsCollection.enumerateStatistics(from: startDate, to: endDate)
                { (statistics, stop) in
                    if let quantity = statistics.sumQuantity() {
                        let date = statistics.startDate
                        let value = quantity.doubleValue(for: .count())
                        
                        // Extract each week's data.
                        //weeklyData.addWeek(date: date, stepCount: Int(value))
                        
                        
                    }
                }
                
                // Dispatch to the main queue to update the UI.
                DispatchQueue.main.async {
                    
                    
                    //myUpdateGraph(weeklyData: weeklyData)
                }
            }
    
            // finally, we execute our query
            healthStore.execute(query)
    }
    
}

extension HKSample {
    
    private static var _componentFormatter: DateComponentsFormatter?
    private static var componentFormatter: DateComponentsFormatter {
        if let formatter = _componentFormatter {
            return formatter
        }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute]
        _componentFormatter = formatter
        return formatter
    }
    
    var periodInHours: Double {
        if let result = HKSample.componentFormatter.string(from: startDate, to: endDate) {
            if let resultDouble = Double(result) {
                return resultDouble / 60
            }
        }
        preconditionFailure()
    }
    
}


//extension HKCategorySample {
//
//    var cleanedStartDate: Date {
//        let calendar = Calendar.simbaCalendar
//        let cleanedDate = calendar.date(from: calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self.startDate)) ?? self.startDate
//        return cleanedDate
//    }
//
//    var cleanedEndDate: Date {
//        let calendar = Calendar.simbaCalendar
//        let cleanedDate = calendar.date(from: calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self.endDate)) ?? self.endDate
//        return cleanedDate
//    }
//
//    // No idea what the default implementation was doing
//    override open func isEqual(_ object: Any?) -> Bool {
//        guard let other = object as? HKCategorySample else {
//            preconditionFailure()
//        }
//
//
//
//        return self.cleanedStartDate == other.cleanedStartDate &&
//            self.cleanedEndDate == other.cleanedEndDate &&
//            self.value == other.value
//    }
//
//}

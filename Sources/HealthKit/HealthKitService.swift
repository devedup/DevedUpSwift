//  HealthKitService.swift
//  SimbaSleep
//
//  Copyright © 2018 SimbaSleep. All rights reserved.
//

import Foundation
import HealthKit
import DevedUpSwiftFoundation
import StoreKit

private let hasViewedHealthKitPermission = "hasViewedHealthKitPermission"

public enum HealthData {
    case activeCalories
    case stepCount
    
    var type: HKQuantityType {
        switch self {
        case .activeCalories:
            return HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!
        case .stepCount:
            return HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
        }
    }
}

public struct HealthDataResult {
    let averageActiveCalories: Int
    let averageStepCount: Int
}


public protocol HealthKitService {
    func averageActiveCaloriesAndSteps(periodDays: Int, completion: @escaping AsyncResultCompletion<HealthDataResult>)
}

public class DefaultHealthKitService: HealthKitService {
    
    public static let sharedInstance = DefaultHealthKitService()
    
    private init () {}
    
    private let healthStore = HKHealthStore()
        
    private func requestAccess(healthData: [HealthData], completion: @escaping AsyncResultCompletion<Bool>) {
        if HKHealthStore.isHealthDataAvailable() {
            let quantityMetrics = Set( healthData.map { $0.type } )
            
            //  A Boolean value that indicates whether the request was processed successfully. This value does not indicate whether permission was actually granted. This parameter is NO if an error occurred while processing the request; otherwise, it is YES.
            healthStore.requestAuthorization(toShare: nil, read: quantityMetrics) { (success, error) in
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

    /*
     // This would only work for write permissions, not for read... if you're reading and they say no, the app doesn't tell you that they said no
    private func checkAuthStatus(healthData: HealthData, onAuthorized: @escaping () -> Void, onDenied: @escaping () -> Void, onAuthCompletion: @escaping () -> Void) {
        let status = healthStore.authorizationStatus(for: healthData.type)
        switch status {
        case .notDetermined:
            requestAccess(healthData: [healthData]) { result in
                onAuthCompletion()
            }
        case .sharingDenied:
            onDenied()
        case .sharingAuthorized:
            onAuthorized()
        @unknown default:
            onDenied()
        }
    }
    */
    
    public func averageActiveCaloriesAndSteps(periodDays: Int, completion: @escaping AsyncResultCompletion<HealthDataResult>) {
        let activeCalories = HealthData.activeCalories
        let stepCount = HealthData.stepCount
        let days = 30
        requestAccess(healthData: [activeCalories, stepCount]) { result in
            
            var averageActiveCalories = 0
            var averageStepCount = 0
            
            let dispatchGroup = DispatchGroup()
            
            // Find active calories
            dispatchGroup.enter()
            self.queryQuantity(healthData: activeCalories, periodDays: days) { result in
                if let sum = result {
                    let count = Int(sum.doubleValue(for: HKUnit.kilocalorie()))
                    averageActiveCalories = count / periodDays
                }
                dispatchGroup.leave()
            }
            
            // Find step count
            dispatchGroup.enter()
            self.queryQuantity(healthData: stepCount, periodDays: days) { result in
                if let sum = result {
                    let count = Int(sum.doubleValue(for: HKUnit.count()))
                    averageStepCount = count / periodDays
                }
                dispatchGroup.leave()
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(.success(HealthDataResult(averageActiveCalories: averageActiveCalories, averageStepCount: averageStepCount)))
            }
        }
    }
    
    private func queryQuantity(healthData: HealthData, periodDays: Int, completion: @escaping (HKQuantity?) -> Void) {
        // Get the start and end date from now
        let period = DataPeriod.previousDays(days: periodDays, from: Date()).periodBoundary
        let lastSoManyDays = HKQuery.predicateForSamples(withStart: period.start, end: period.end, options: [])
        
        // Build the query
        let query = HKStatisticsQuery(quantityType: healthData.type, quantitySamplePredicate: lastSoManyDays, options: .cumulativeSum) { (query, statisticsOrNil, errorOrNil) in
            guard let statistics = statisticsOrNil else {
                completion(nil)
                return
            }
            
            // Get data and find average
            let sum = statistics.sumQuantity()

            // Update the UI here.
            completion(sum)
        }
        self.healthStore.execute(query)
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
    
    func requestDataCollectoin(metric: HKQuantityTypeIdentifier,
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

//
//  File.swift
//  
//
//  Created by David Casserly on 26/07/2021.
//

import Foundation
import UserNotifications

public protocol LocalNotificationHandler {
    func displayNotification(title: String, body: String, userInfo: [AnyHashable: Any], after timeInterval: TimeInterval, identifier: String)
    func displayNotification(title: String, body: String, after timeInterval: TimeInterval, identifier: String)
    func cancelPendingNotification(identifier: String)
}

final public class DefaultLocalNotificationHandler: LocalNotificationHandler {
      
    public static let sharedInstance = DefaultLocalNotificationHandler()
    private init() {}
    
    public func displayNotification(title: String, body: String, userInfo: [AnyHashable: Any], after timeInterval: TimeInterval = TimeInterval(1), identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        var userInfoArray = [AnyHashable: Any]()
        userInfoArray.merge(userInfo) {(_,new) in new}
        userInfoArray[identifier] = true
        content.userInfo = userInfoArray
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        // Create the request
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content, trigger: trigger)
        
        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
            if error != nil {
                print(error)
                // Handle any errors.
            }
        }
    }
    
    public func displayNotification(title: String, body: String, after timeInterval: TimeInterval = TimeInterval(1), identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.userInfo = [identifier: true]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        // Create the request
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content, trigger: trigger)
        
        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
            if error != nil {
                // Handle any errors.
            }
        }
    }
    
    // I don't think i really need to cancel anything
    public func cancelPendingNotification(identifier: String) {
        let notificationCenter = UNUserNotificationCenter.current()
        //notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}

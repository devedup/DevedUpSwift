//
//  File.swift
//  
//
//  Created by David Casserly on 18/07/2022.
//

import Foundation
import Network

public class NetworkAvailabilityModel {
    @Published public var isConnected: Bool = true
    @Published public var isExpensiveConnection: Bool = false
}

public protocol NetworkAvailability {
    var model: NetworkAvailabilityModel { get }
}

public class DefaultNetworkAvailability: NetworkAvailability {
    
    public static let sharedInstance = DefaultNetworkAvailability()
    
    private let monitor = NWPathMonitor()
    
    public var model: NetworkAvailabilityModel = NetworkAvailabilityModel()
    
    private init() {
        setup()
    }
    
    private func setup() {
        monitor.pathUpdateHandler = { (path: NWPath) in
            switch path.status {
            case .satisfied, .requiresConnection:
                self.model.isConnected = true
            default:
                self.model.isConnected = false
            }
            
            self.model.isExpensiveConnection = path.isExpensive
        }
        
        let queue = DispatchQueue.init(label: "DefaultNetworkAvailability Queue", qos: .userInitiated)
        monitor.start(queue: queue)
    }
    
}

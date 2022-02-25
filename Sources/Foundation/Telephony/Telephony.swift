//
//  File.swift
//  
//
//  Created by David Casserly on 21/02/2022.
//

import Foundation
import CoreTelephony

public class Telephony {
    
    public static func simCountryCode() -> String? {
        var simCountryCode: String?
        let telephoney = CTTelephonyNetworkInfo()
            
        if let simCards = telephoney.serviceSubscriberCellularProviders?.values {
            for sim in simCards {
                if let isoCountryCode = sim.isoCountryCode {
                    simCountryCode = isoCountryCode.uppercased()
                    break
                }
            }
        }
              
        return simCountryCode
    }
    
    
}

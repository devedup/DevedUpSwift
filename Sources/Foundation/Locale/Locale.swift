// Created by David Casserly on 09/05/2023.
// Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import Foundation

extension Locale {
    
    public func countryCode() -> String {
        let locale = Self.current
        var countryCode = "XXX"
        if #available(iOS 16, *) {
            if let value = locale.region?.identifier {
                countryCode = value
            }
        } else {
            if let value = locale.regionCode {
                countryCode = value
            }
        }
        return countryCode
    }
    
}

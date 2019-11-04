//  Created by David Casserly on 18/11/2018.
//

import Foundation

extension String {
    
    public var localized: String {
        let value = NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "NOTFOUND", comment: "")
        if value == "NOTFOUND" {
            assertionFailure("String \(self) was not found in Bundle.main .strings file")
        }
        return value
    }
    
    public func localized(with varargs:CVarArg...) -> String {
        return String(format: self.localized, locale: Locale.current, arguments: varargs)
    }
    
}

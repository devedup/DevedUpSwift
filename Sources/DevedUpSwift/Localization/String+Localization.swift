//  Created by David Casserly on 18/11/2018.
//

import Foundation

extension String {
    
    public var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    public func localized(with varargs:CVarArg...) -> String {
        return String(format: self.localized, locale: Locale.current, arguments: varargs)
    }
    
}

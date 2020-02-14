//  Created by David Casserly on 14/02/2020.
//

import Foundation

/// A completion handler can return this object to encapsulate the object you want, generically, or an error object and you can switch at the call site on the result
enum AsyncResult<T> {
    
    case success(T)
    case failure(ErrorType)
 
    var value: T? {
        guard case .success(let value) = self else {
            return nil
        }
        return value
    }
    
    var error: Error? {
        guard case .failure(let error) = self else {
            return nil
        }
        return error
    }
    
}

/// Typealias to make the method signatures easier to read
typealias AsyncResultCompletion<T> = (AsyncResult<T>) -> Void

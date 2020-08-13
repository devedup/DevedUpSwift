//  Created by David Casserly on 14/02/2020.
//

import Foundation
import DevedUpSwiftFoundation

/// A completion handler can return this object to encapsulate the object you want, generically, or an error object and you can switch at the call site on the result
public enum AsyncResult<T> {
    
    case success(T)
    case failure(ErrorType)
 
    public var value: T? {
        guard case .success(let value) = self else {
            return nil
        }
        return value
    }
    
    public var error: ErrorType? {
        guard case .failure(let error) = self else {
            return nil
        }
        return error
    }
    
}

/// Typealias to make the method signatures easier to read
public typealias AsyncResultCompletion<T> = (AsyncResult<T>) -> Void

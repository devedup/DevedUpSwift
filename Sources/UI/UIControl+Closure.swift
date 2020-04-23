//  Created by David Casserly on 14/10/2019.
//
import UIKit

extension UIControl {
    
    public func addAction(for controlEvents: UIControl.Event, _ closure: @escaping ()->()) {
        let wrapper = ClosureWrapper(closure)
        addTarget(wrapper, action: #selector(ClosureWrapper.invoke), for: controlEvents)
        objc_setAssociatedObject(self, "[\(arc4random())]", wrapper, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
    
}

@objc public class ClosureWrapper: NSObject {
    
    let closure: ()->()
        
    init (_ closure: @escaping ()->()) {
        self.closure = closure
        super.init()
    }
    
    @objc public func invoke () {
        closure()
    }
    
}

@objc
public class DevedUpSwiftUITest: NSObject {
    
    @objc
    public static func testMethod() {
        print("My package worked");
    }
    
}

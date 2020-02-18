//  Created by David Casserly on 14/10/2019.
//
import UIKit

extension NSMutableAttributedString {
    
    public func setLineHeight(multiple: Float) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = CGFloat(multiple)
        self.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, self.length))
    }
    
}

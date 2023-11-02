// Created by David Casserly on 02/11/2023.
// Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import Foundation
import UIKit

public class LabelAndBadgeView: UIView {
    
    // swiftlint:disable:next private_outlet
    @IBOutlet public var label: UILabel!
    
    // swiftlint:disable:next private_outlet
    @IBOutlet public var badge: BadgeLabel!
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func sharedInit() {
    }
    
    
}

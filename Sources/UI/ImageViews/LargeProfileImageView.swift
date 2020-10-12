//
//  LargeProfileImageView.swift
//  Fitafy
//
//  Created by David Casserly on 10/09/2020.
//  Copyright © 2020 DevedUp Ltd. All rights reserved.
//

import Foundation
import UIKit

public final class LargeProfileImageView: UIImageView {
    
    public private (set) var heightConstraint: NSLayoutConstraint!
    
    public init() {
        super.init(image: nil)
        sharedInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    private func sharedInit() {
        let width = self.frame.width
        let height = width // We start off with square images
        contentMode = .scaleAspectFill
        translatesAutoresizingMaskIntoConstraints = false
        heightConstraint = heightAnchor.constraint(equalToConstant: height)
        heightConstraint.isActive = true
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
}

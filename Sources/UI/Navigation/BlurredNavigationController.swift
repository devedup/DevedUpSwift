//
//  CustomNavigationController.swift
//  Fitafy
//
//  Created by David Casserly on 28/06/2021.
//  Copyright © 2021 DevedUp Ltd. All rights reserved.
//

import Foundation
import UIKit

public class BlurredNavigationController: UINavigationController {
    
    private let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        if let bounds = navigationBar.bounds as CGRect? {
            visualEffectView.frame = bounds
            visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            visualEffectView.layer.zPosition = -1
            navigationBar.insertSubview(visualEffectView, at: 0)
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        navigationBar.sendSubviewToBack(visualEffectView)
    }
}

// Alternatively, you don't have to use the subclass BlurredNavigationController and yuo can use this

extension UINavigationBar {
    public func installBlurEffect() {
        isTranslucent = true
        setBackgroundImage(UIImage(), for: .default)
        let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
//        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
        var blurFrame = bounds
        blurFrame.size.height += statusBarHeight
        blurFrame.origin.y -= statusBarHeight
        let blurView  = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialLight))
        blurView.isUserInteractionEnabled = false
        blurView.frame = blurFrame
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurView)
        blurView.layer.zPosition = -1
    }
}

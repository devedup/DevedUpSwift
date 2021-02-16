//
//  TabSectionContainerViewController.swift
//  Echoes
//
//  Created by David Casserly on 21/04/2017.
//  Copyright © 2017 DevedUp Ltd. All rights reserved.
//

import Foundation
import UIKit

public protocol TabSectionContainable {
    func wasSelectedInTabbedView()
}

public class TabSectionContainerViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet private var scrollViewContainer: UIScrollView!
    
    public var selectedIndex: Int = 0 {
        didSet {
            scrollTo(index: selectedIndex)
        }
    }
    
    public var indexDidChange: ((Int) -> Void)?    
    public var viewControllers: [UIViewController]?
    
    var initialIndex: Int = 0
    var currentViewController: UIViewController {
        guard let viewController = viewControllers?[selectedIndex] else {
            preconditionFailure()
        }
        return viewController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        
//        guard let  viewControllers = viewControllers else {
//            preconditionFailure()
//        }
//        assert(viewControllers.count > 0)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if scrollViewContainer.contentSize.width == 0 {
            setupScrollView()
            scrollTo(index: initialIndex, animated: false)
        }
        scrollViewContainer.pinToSuperview()
        
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        layoutScrollViewContentSize()
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // scrollViewContainer.frame.size is wrong at this point on iPhone 11 running iOS 13
        layoutScrollViewContentSize()
    }
    
    private func layoutScrollViewContentSize() {
        guard let viewControllers = viewControllers else {
            preconditionFailure()
        }
        let size = scrollViewContainer.frame.size
        scrollViewContainer.contentSize = CGSize(width: CGFloat(viewControllers.count) *  size.width, height: size.height)
        
        for (index, element) in viewControllers.enumerated() {
            let x = CGFloat(index) * size.width
            element.view.frame = CGRect(x: x, y: 0, width: size.width, height: size.height)
        }
    }
    
    // MARK: Segement Setup 
    
    private func setupScrollView() {
        guard let viewControllers = viewControllers else {
            preconditionFailure()
        }
        viewControllers.forEach { addViewToScrollView($0) }
    }
    
    private func addViewToScrollView(_ viewController: UIViewController) {
        addChild(viewController)
        scrollViewContainer.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
    
    // MARK: Scroll to segment
        
    public func scrollTo(index: Int, animated: Bool = true) {
        guard let viewControllers = self.viewControllers,
            (index < viewControllers.count) && (index >= 0) else {
            assertionFailure("You're scrolling to a section that doesn't exist")
            return
        }
        
        let width = scrollViewContainer.frame.size.width
        let x = CGFloat(index) * width
        let offset = CGPoint(x: x, y: 0)
        scrollViewContainer.setContentOffset(offset, animated: animated)
        indexDidChange?(index)
    }
    
    // MARK: Scroll Delegate
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.x
        let currentSelected = selectedIndex
        if contentOffset > 0 {
            let width = scrollViewContainer.frame.size.width
            let index = Int(contentOffset / width)
            indexDidChange?(index)
            selectedIndex = index
        } else {
            indexDidChange?(0)
            selectedIndex = 0
        }
        if currentSelected != selectedIndex {
            viewControllerDidPresentOnScreen()
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        viewControllerDidPresentOnScreen()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //print("here")
    }
    
    private func viewControllerDidPresentOnScreen() {
        if let viewController = currentViewController as? TabSectionContainable {
            viewController.wasSelectedInTabbedView()
        }
    }
    
}

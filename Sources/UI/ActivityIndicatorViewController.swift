//
//  UIViewController+ActivityIndicator.swift
//
//  Created by David Casserly on 09/05/2018.
//
import Foundation
import UIKit

/// Presenter views which want to display activity should implement this protocol
public protocol ActivityIndicatorPresentable {
    func presentActivityIndicator()
    func presentActivityIndicator(inNavigationController inNav: Bool)
    func dismissActivityIndicator()
}

// MARK: - Lets make all ViewControllers be ActivityIndicatorPresentable
extension UIViewController: ActivityIndicatorPresentable {
    
    private struct AssociatedKeys {
        static var ActivityIndicator = "ActivityIndicator"
        static var ModalView = "ModalView"
    }
    
    public func presentActivityIndicator() {
        presentActivityIndicator(inNavigationController: true)
    }
    
    public func presentActivityIndicator(inNavigationController inNav: Bool = true) {
        dismissActivityIndicator()
        var view: UIView! = self.view
        
        // Sit the activity indicator inside a container
        if inNav {
            if let navController = navigationController {
                view = navController.view
            }
        }
        let modalView = UIView()
        modalView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.addSubview(modalView)
        modalView.pinToSuperview()
        objc_setAssociatedObject(self,
                                     &AssociatedKeys.ModalView,
                                     modalView as UIView?,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC )
        view.bringSubviewToFront(modalView)
        view = modalView

        let activityIndicator =  UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.white
        view.addSubview(activityIndicator)

        activityIndicator.centreInSuperview()
        view.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
        objc_setAssociatedObject(self,
                                 &AssociatedKeys.ActivityIndicator,
                                 activityIndicator as UIActivityIndicatorView?,
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC )
    }
    
    public func dismissActivityIndicator() {
        if let activityIndicator = objc_getAssociatedObject(self,
                                                            &AssociatedKeys.ActivityIndicator) as?  UIActivityIndicatorView {
            activityIndicator.stopAnimating()
        }
        if let modalView = objc_getAssociatedObject(self,
                                                    &AssociatedKeys.ModalView) as?  UIView {
            modalView.removeFromSuperview()
        }
    }
    
}

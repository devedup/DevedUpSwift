//
//  UIViewController+ActivityIndicator.swift
//
//  Created by David Casserly on 09/05/2018.
//
import Foundation
import UIKit

/// Presenter views which want to display activity should implement this protocol
public protocol ActivityIndicatorPresentable {
    func presentActivityIndicatorClearModal()
    func presentActivityIndicator()
    func presentActivityIndicator(inNavigationController inNav: Bool, style: UIActivityIndicatorView.Style, modal: Bool)
    func presentActivityIndicator(inNavigationController inNav: Bool, style: UIActivityIndicatorView.Style, modal: Bool, modalAlpa: CGFloat)
    func dismissActivityIndicator()
}

// MARK: - Lets make all ViewControllers be ActivityIndicatorPresentable
extension UIViewController: ActivityIndicatorPresentable {
    
    private struct AssociatedKeys {
        static var ActivityIndicator = "ActivityIndicator"
        static var ModalView = "ModalView"
    }
    
    public func presentActivityIndicatorClearModal() {
        presentActivityIndicator(inNavigationController: true, style: .gray, modal: true, modalAlpa: 0.0)
    }
    
    @objc
    open func presentActivityIndicator() {
        presentActivityIndicator(inNavigationController: true)
    }
    
    public func presentActivityIndicator(inNavigationController inNav: Bool, style: UIActivityIndicatorView.Style, modal: Bool) {
        presentActivityIndicator(inNavigationController: true, style: style, modal: modal, modalAlpa: 0.4)
    }
    
    @objc
    open func presentActivityIndicator(inNavigationController inNav: Bool = true, style: UIActivityIndicatorView.Style = .white, modal: Bool = true, modalAlpa: CGFloat = 0.4) {
        dismissActivityIndicator()
        var view: UIView! = self.view
        
        // Sit the activity indicator inside a container
        if inNav {
            if let navController = navigationController {
                view = navController.view
            }
        }
        if modal {
            let modalView = UIView()
            modalView.backgroundColor = UIColor.black.withAlphaComponent(modalAlpa)
            view.addSubview(modalView)
            modalView.pinToSuperview()
            objc_setAssociatedObject(self,
                                         &AssociatedKeys.ModalView,
                                         modalView as UIView?,
                                         .OBJC_ASSOCIATION_RETAIN_NONATOMIC )
            view.bringSubviewToFront(modalView)
            view = modalView
        }
        
        let activityIndicator =  UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = style
        view.addSubview(activityIndicator)

        activityIndicator.centreInSuperview()
        view.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
        objc_setAssociatedObject(self,
                                 &AssociatedKeys.ActivityIndicator,
                                 activityIndicator as UIActivityIndicatorView?,
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC )
    }
    
    @objc
    open func dismissActivityIndicator() {
        if let activityIndicator = objc_getAssociatedObject(self, &AssociatedKeys.ActivityIndicator) as?  UIActivityIndicatorView {
            activityIndicator.stopAnimating()
        }
        if let modalView = objc_getAssociatedObject(self, &AssociatedKeys.ModalView) as?  UIView {
            modalView.removeFromSuperview()
        }
    }
    
}

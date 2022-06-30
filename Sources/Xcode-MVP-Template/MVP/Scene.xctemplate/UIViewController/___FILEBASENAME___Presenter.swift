// Created by ___FULLUSERNAME___ on ___DATE___.
// Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.

import UIKit
import DevedUpSwiftUI

@MainActor
protocol ___VARIABLE_sceneName___View: AnyObject, ActivityIndicatorPresentable, ErrorPresentable  {

}

@MainActor
class ___VARIABLE_sceneName___Presenter {
    
    private weak var view: ___VARIABLE_sceneName___View?
    
    init(view: ___VARIABLE_sceneName___View) {
        self.view = view
    }
    
}

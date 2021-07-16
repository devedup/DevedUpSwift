//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

final class ___VARIABLE_sceneName___ViewController: UIViewController {
    
    // swiftlint:disable:next implicitly_unwrapped_optional 
    private var presenter: ___VARIABLE_sceneName___Presenter!
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = ___VARIABLE_sceneName___Presenter(view: self)
    }

}

extension ___VARIABLE_sceneName___ViewController: ___VARIABLE_sceneName___View {
    
}

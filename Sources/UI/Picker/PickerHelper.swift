//
//  File.swift
//  
//
//  Created by David Casserly on 01/09/2020.
//

import Foundation
import UIKit

/// PickerHelper will keep the references to the associated items, espeically the delegate/datasource so that it wont go out of scope
public class PickerHelper: NSObject, PickerToolbarReceiver {
    
    private let source: PickerDataSource
    public let picker: UIPickerView
    public private (set) weak var textField: UITextField?
    
    init(picker: UIPickerView, textField: UITextField) {
        self.picker = picker
        self.source = picker.dataSource! as! PickerDataSource
        self.textField = textField
    }
    
    @objc public func donePressed() {
        source.donePressed(picker)
        textField?.resignFirstResponder()
    }
    
    @objc public func cancelPressed() {
        source.cancelPressed(picker)
        textField?.resignFirstResponder()
    }
}

//
//  File.swift
//  
//
//  Created by David Casserly on 01/09/2020.
//

import Foundation
import UIKit

/// UIDatePicker is not a UIPickerView so easier to create it's own helper
public class DatePickerHelper: PickerToolbarReceiver {
    
    public let picker: UIDatePicker?
    public weak var textField: UITextField?
    private let doneAction: () -> ()
    private let dateFormat: String
    
    public init(picker: UIDatePicker, textField: UITextField, dateFormat: String, onDonePressed: @escaping () -> ()) {
        self.picker = picker
        self.textField = textField
        self.doneAction = onDonePressed
        self.dateFormat = dateFormat
    }
    
    public func selectDefault() {
        textField?.text = selectedData()
        // doesn't work if i don't wrap it
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.textField?.sendActions(for: .editingChanged)
        }
    }
    
    public func datePickerWillAppear() {
        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = dateFormat
        if let text = self.textField?.text,
            let date = formatter.date(from: text) {
            self.picker?.date = date
        }
        
    }
    
    public func selectedData() -> String {
        let date = picker?.date
        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = dateFormat
        return formatter.string(from: date!)
    }
    
    public func date() -> Date {
        return (picker?.date)!
    }
    
    @objc public func donePressed() {
        textField?.text = selectedData()
        doneAction()
    }
    
    @objc public func cancelPressed() {
        textField?.resignFirstResponder()
    }
    
}

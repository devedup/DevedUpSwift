import Foundation
import DevedUpSwiftLocalisation
import UIKit

/// Extends UIPicker protocols and provides another method to get the data from a single row type
public protocol PickerDataSource: UIPickerViewDataSource, UIPickerViewDelegate  {
    func donePressed(_ pickerView: UIPickerView)
    func cancelPressed(_ pickerView: UIPickerView)    
}

/// Factory for creating default UIPicker and UIDatePicker
public class PickerViewFactory {
    
    /// Make a date picker with a toolbar
    ///
    /// - Parameters:
    ///   - textField: the textfield to associate inputView with this picker
    ///   - onDonePressed: what to do when Done button is pressed
    /// - Returns: the new picker
    public static func makeDatePicker(withTextField textField: UITextField, dateFormat: String = "dd MMM yyyy", maxDate: Date = Date(), onDonePressed: @escaping () -> ()) -> DatePickerHelper {
        let datePicker = UIDatePicker()
//        datePicker.locale = Locale(identifier: "en_US_POSIX")
//        datePicker.timeZone = TimeZone(abbreviation: "UTC")
        datePicker.datePickerMode = .date
        datePicker.maximumDate = maxDate
        datePicker.backgroundColor = UIColor.white
        let helper = DatePickerHelper(picker: datePicker, textField: textField, dateFormat: dateFormat, onDonePressed: onDonePressed)
        let toolbar = makePickerToolbar(with: helper)
        textField.inputAccessoryView = toolbar
        textField.inputView = datePicker
        return helper
    }
    
    /// Make a UIPickerView
    ///
    /// - Parameters:
    ///   - type: the type of picker you want
    ///   - textField: the textfield to associate inputView with this picker
    ///   - onDonePressed: what to do when Done button is pressed
    /// - Returns: the new picker
    public static func makePicker(dataSource: PickerDataSource, withTextField textField: UITextField, onCancelPressed: (() -> ())? = nil) -> PickerHelper {
        let picker = UIPickerView()
        picker.backgroundColor = UIColor.white
        picker.dataSource = dataSource
        picker.delegate = dataSource
        picker.showsSelectionIndicator = true
        let helper = PickerHelper(picker: picker, textField: textField)
        let toolbar = makePickerToolbar(with: helper)
        textField.inputAccessoryView = toolbar
        textField.inputView = picker
        return helper
    }
    
    /// Create a default toolbar that will be attached to the Picker
    ///
    /// - Parameter helper: the helper that the toolbar buttons will attach to
    /// - Returns: the new toolbar
    private static func makePickerToolbar(with target: PickerToolbarReceiver) -> UIToolbar {
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = false
        toolBar.sizeToFit()

        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "General.Button.Done".localized, style: .plain, target: target, action: #selector(PickerHelper.donePressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "General.Button.Cancel".localized, style: .plain, target: target, action: #selector(PickerHelper.cancelPressed))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }
    
}

import Foundation
import DevedUpSwiftLocalisation
import UIKit

/// Extends UIPicker protocols and provides another method to get the data from a single row type
public protocol PickerSource: UIPickerViewDataSource, UIPickerViewDelegate  {

    var doneButtonTitle: String { get }
    var cancelButtonTitle: String { get }
    func donePressed(_ pickerView: UIPickerView)
    func cancelPressed(_ pickerView: UIPickerView)
    
}

extension PickerSource {
    
    var doneButtonTitle: String {
        "General.Button.Done".localized
    }
    
    var cancelButtonTitle: String {
        "General.Button.Cancel".localized
    }
    
}

/// Picker has a toolbar attached to it with Done and Cancel buttons
//@objc
//public protocol PickerHelper {
    
//    @objc func donePressed()
//    @objc func cancelPressed()
    
//}

/// PickerHelper will keep the references to the associated items, espeically the delegate/datasource so that it wont go out of scope
public class PickerHelper: NSObject {
    
    private let source: PickerSource
    let picker: UIPickerView
    weak var textField: UITextField?
    
    init(picker: UIPickerView, textField: UITextField) {
        self.picker = picker
        self.source = picker.dataSource! as! PickerSource
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

/// Factory for creating default UIPicker and UIDatePicker
public class PickerViewFactory {
    
    /// Make a UIPickerView
    ///
    /// - Parameters:
    ///   - type: the type of picker you want
    ///   - textField: the textfield to associate inputView with this picker
    ///   - onDonePressed: what to do when Done button is pressed
    /// - Returns: the new picker
    public static func makePicker(dataSource: PickerSource, withTextField textField: UITextField, onCancelPressed: (() -> ())? = nil) -> PickerHelper {
        let picker = UIPickerView()
        picker.backgroundColor = UIColor.white
        picker.dataSource = dataSource
        picker.delegate = dataSource
        picker.showsSelectionIndicator = true
        let helper = PickerHelper(picker: picker, textField: textField)
        let toolbar = makePickerToolbar(withHelper: helper, dataSource: dataSource)
        textField.inputAccessoryView = toolbar
        textField.inputView = picker
        return helper
    }
    
    /// Create a default toolbar that will be attached to the Picker
    ///
    /// - Parameter helper: the helper that the toolbar buttons will attach to
    /// - Returns: the new toolbar
    private static func makePickerToolbar(withHelper helper: PickerHelper, dataSource: PickerSource) -> UIToolbar {
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = false
        toolBar.sizeToFit()

        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: dataSource.doneButtonTitle, style: .plain, target: helper, action: #selector(PickerHelper.donePressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: dataSource.cancelButtonTitle, style: .plain, target: helper, action: #selector(PickerHelper.cancelPressed))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }
    
}

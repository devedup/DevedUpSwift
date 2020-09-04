//
//  CurrencyTextField.swift
//  ManchesterFC
//
//  Created by David Casserly on 23/08/2020.
//  Copyright © 2020 DevedUp Ltd. All rights reserved.
//

import Foundation
import UIKit

extension StringProtocol where Self: RangeReplaceableCollection {
    var digits: Self { filter (\.isWholeNumber) }
}
extension LosslessStringConvertible {
    var string: String { .init(self) }
}
extension UITextField {
     var string: String { text ?? "" }
}
extension String {
    var decimal: Decimal { Decimal(string: digits) ?? 0 }
}
extension Decimal {
    var currency: String { Formatter.currency.string(for: self) ?? "" }
}
extension NumberFormatter {
    convenience init(numberStyle: Style) {
        self.init()
        self.numberStyle = numberStyle
        self.usesGroupingSeparator = true
        self.maximumFractionDigits = 2
        self.minimumFractionDigits = 2
    }
}
private extension Formatter {
    static let currency: NumberFormatter = .init(numberStyle: .decimal) // set to .currency
}

public class CurrencyTextField: UITextField {
    
    public var decimal: Decimal { string.decimal / pow(10, Formatter.currency.maximumFractionDigits) }
    var maximum: Decimal = 999_999_999.99
    private var lastValue: String?
    public var locale: Locale = .current {
        didSet {
            Formatter.currency.locale = locale
            sendActions(for: .editingChanged)
        }
    }
    public override func willMove(toSuperview newSuperview: UIView?) {
        // you can make it a fixed locale currency if needed
        // self.locale = Locale(identifier: "pt_BR") // or "en_US", "fr_FR", etc
        Formatter.currency.locale = locale
        addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        keyboardType = .numberPad
        textAlignment = .right
        sendActions(for: .editingChanged)
    }
    public override func deleteBackward() {
        text = string.digits.dropLast().string
        // manually send the editingChanged event
        sendActions(for: .editingChanged)
    }
    @objc func editingChanged() {
        guard decimal <= maximum else {
            text = lastValue
            return
        }
        text = decimal.currency
        lastValue = text
    }
    
}

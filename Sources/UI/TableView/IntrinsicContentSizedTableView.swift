//
//  File.swift
//  
//
//  Created by David Casserly on 25/03/2020.
//

import Foundation
import UIKit

public class IntrinsicContentSizedTableView: UITableView {

    public override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    public override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }

}

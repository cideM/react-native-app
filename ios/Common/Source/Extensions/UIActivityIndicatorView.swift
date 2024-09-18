//
//  UIActivityIndicatorView.swift
//  Common
//
//  Created by CSH on 09.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import UIKit

public extension UIActivityIndicatorView {
    func setAnimating(_ animating: Bool) {
        switch animating {
        case true: startAnimating()
        case false: stopAnimating()
        }
    }
}

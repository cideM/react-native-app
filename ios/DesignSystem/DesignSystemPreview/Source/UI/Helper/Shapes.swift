//
//  Shapes.swift
//  DesignSytemPreview
//
//  Created by Elmar Tampe on 28.07.23.
//

import UIKit
import DesignSystem

class Square {

    static func with(color: UIColor, cornerRadius: CGFloat = .radius.s) -> UIView {

        let view = UIView(frame: CGRect(x: 0, y: 0, width: 80.0, height: 80.0))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = color
        view.layer.masksToBounds = false
        view.layer.borderWidth = 1
        view.apply(cornerRadius: cornerRadius)
        view.layer.borderColor = UIColor.borderPrimary.cgColor

        return view
    }
}

class Circle {

    static func with(color: UIColor, height: CGFloat = 20.0) -> UIView {

        let view = UIView(frame: CGRect(x: 0, y: 0, width: height, height: height))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = color
        view.layer.masksToBounds = false
        view.layer.borderWidth = 1
        view.apply(cornerRadius: (height / 2.0))
        view.layer.borderColor = UIColor.borderPrimary.cgColor

        return view
    }
}

class Spacer {

    static func with(height: CGFloat) -> UIView {

        let originY = (100 - height) / 2

        let view = UIView(frame: CGRect(x: 150, y: originY, width: 230, height: height))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .canvas
        view.apply(cornerRadius: 1)
        view.layer.masksToBounds = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.dividerPrimary.cgColor

        return view
    }
}

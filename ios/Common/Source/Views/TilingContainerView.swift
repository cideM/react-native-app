//
//  TilingContainerView.swift
//  Common
//
//  Created by Mohamed Abdul Hameed on 22.02.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import UIKit

public class TilingContainerView: UIView {

    private let horizontalItemSpacing: CGFloat = 8
    private let verticalItemSpacing: CGFloat = 8
    public var isMultipleLines = true
    public var contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) {
        didSet {
            setNeedsLayout()
        }
    }

    override public var intrinsicContentSize: CGSize {
        guard !subviews.isEmpty else { return .zero }

        let maxX = subviews.reduce(into: 0) { result, view in result = max(result, view.frame.maxX) }
        let maxY = subviews.reduce(into: 0) { result, view in result = max(result, view.frame.maxY) }

        let width = maxX + contentInsets.right
        let height = maxY + contentInsets.bottom

        return CGSize(width: width, height: height)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        var possibleNextItemPosition = CGPoint(x: contentInsets.left, y: contentInsets.top)

        for subview in subviews {

            subview.sizeToFit()

            if isMultipleLines {
                if possibleNextItemPosition.x + subview.bounds.width + horizontalItemSpacing > bounds.width {
                    possibleNextItemPosition.x = contentInsets.left
                    possibleNextItemPosition.y += subview.bounds.height + verticalItemSpacing
                }
            }

            subview.frame = CGRect(x: possibleNextItemPosition.x, y: possibleNextItemPosition.y, width: subview.frame.width, height: subview.frame.height)
            possibleNextItemPosition = CGPoint(x: possibleNextItemPosition.x + subview.bounds.width + horizontalItemSpacing, y: possibleNextItemPosition.y)
        }
        invalidateIntrinsicContentSize()
    }
 }

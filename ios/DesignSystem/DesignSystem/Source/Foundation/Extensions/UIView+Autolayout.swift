//
//  UIView+Autolayout.swift
//  DesignSystem
//
//  Created by Elmar Tampe on 02.06.23.
//

import UIKit

public extension UIView {

    @discardableResult
    // swiftlint:disable:next large_tuple
    func pin(to baseView: UIView, insets: UIEdgeInsets = .zero) -> (top: NSLayoutConstraint, bottom: NSLayoutConstraint, leading: NSLayoutConstraint, trailing: NSLayoutConstraint) {

        translatesAutoresizingMaskIntoConstraints = false
        let top = topAnchor.constraint(equalTo: baseView.topAnchor, constant: insets.top)
        let bottom = baseView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: insets.bottom)
        let leading = leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: insets.left)
        let trailing = baseView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: insets.right)
        NSLayoutConstraint.activate([top, bottom, leading, trailing])
        return (top: top, bottom: bottom, leading: leading, trailing: trailing)
    }

    func pin(toMarginsOf baseView: UIView, insets: UIEdgeInsets = .zero) {

        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: baseView.layoutMarginsGuide.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: baseView.layoutMarginsGuide.leadingAnchor, constant: insets.left),
            baseView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: bottomAnchor, constant: insets.bottom),
            baseView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: trailingAnchor, constant: insets.right)
        ])
    }

    func pinTop(to baseView: UIView, insets: UIEdgeInsets = .zero) {

        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: baseView.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: insets.left),
            baseView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: insets.right),
            baseView.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor, constant: insets.bottom)
        ])
    }

    func pinRight(to baseView: UIView, insets: UIEdgeInsets = .zero) {

        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: baseView.topAnchor, constant: insets.top),
            leadingAnchor.constraint(greaterThanOrEqualTo: baseView.leadingAnchor, constant: insets.left),
            baseView.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor, constant: insets.bottom),
            baseView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: insets.right)
        ])
    }

    func pinBottom(to baseView: UIView, insets: UIEdgeInsets = .zero) {

        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            topAnchor.constraint(greaterThanOrEqualTo: baseView.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: insets.left),
            baseView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: insets.right),
            baseView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: insets.bottom)
        ])
    }

    func pinLeft(to baseView: UIView, insets: UIEdgeInsets = .zero) {

        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: baseView.topAnchor, constant: insets.top),
            leftAnchor.constraint(equalTo: baseView.leftAnchor, constant: insets.left),
            rightAnchor.constraint(lessThanOrEqualTo: baseView.rightAnchor, constant: insets.right),
            baseView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: insets.bottom)
        ])
    }

    func centerVerticallyAndPinLeft(in baseView: UIView, insets: UIEdgeInsets = .zero) {

        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            centerYAnchor.constraint(equalTo: baseView.centerYAnchor),
            leftAnchor.constraint(equalTo: baseView.leftAnchor, constant: insets.left),
            rightAnchor.constraint(lessThanOrEqualTo: baseView.rightAnchor, constant: insets.right)
        ])
    }

    func centerVerticallyAndPinRight(in baseView: UIView, insets: UIEdgeInsets = .zero) {

        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            centerYAnchor.constraint(equalTo: baseView.centerYAnchor),
            rightAnchor.constraint(equalTo: baseView.rightAnchor, constant: insets.right),
            leftAnchor.constraint(lessThanOrEqualTo: baseView.leftAnchor, constant: insets.left)
        ])
    }

    func pin(toHorizontalCenterOf baseView: UIView, insets: UIEdgeInsets = .zero) {

        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: baseView.topAnchor, constant: insets.top),
            leadingAnchor.constraint(greaterThanOrEqualTo: baseView.leadingAnchor, constant: insets.left),
            baseView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: insets.bottom),
            baseView.trailingAnchor.constraint(greaterThanOrEqualTo: trailingAnchor, constant: insets.right),
            baseView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    func center(in baseView: UIView) {

        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: baseView.centerXAnchor),
            centerYAnchor.constraint(equalTo: baseView.centerYAnchor)
        ])
    }

    func centerHorizontally(in baseView: UIView) {

        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: baseView.centerXAnchor)
        ])
    }

    func centerHorizontallyAndPinToBottotom(in baseView: UIView, insets: UIEdgeInsets = .zero) {

        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: baseView.centerXAnchor),
            baseView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: insets.bottom)
        ])
    }

    func centerVerticallyAndPinHorizontally(in baseView: UIView) {

        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            centerYAnchor.constraint(equalTo: baseView.centerYAnchor),
            leadingAnchor.constraint(equalTo: baseView.leadingAnchor),
            trailingAnchor.constraint(equalTo: baseView.trailingAnchor)
        ])
    }

    func constrainSize(_ size: CGSize) {
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size.width),
            heightAnchor.constraint(equalToConstant: size.height)
        ])
    }

    func constrainWidth(_ width: CGFloat, priority: UILayoutPriority = .required) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: width).with(priority: priority)
        ])
    }

    func constrainMinimumWidth(_ width: CGFloat, priority: UILayoutPriority = .required) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(greaterThanOrEqualToConstant: width).with(priority: priority)
        ])
    }

    func constrainHeight(_ height: CGFloat, priority: UILayoutPriority = .required) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: height).with(priority: priority)
        ])
    }

    func constrainMinimumHeight(_ height: CGFloat, priority: UILayoutPriority = .required) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: height).with(priority: priority)
        ])
    }

    func constrainMaximumHeight(_ height: CGFloat, priority: UILayoutPriority = .required) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heightAnchor.constraint(lessThanOrEqualToConstant: height).with(priority: priority)
        ])
    }

    func clearConstraints() {
        for subview in self.subviews {
            subview.clearConstraints()
        }
        self.removeConstraints(self.constraints)
    }

    // MARK: - Layout Guides
    @discardableResult
    // swiftlint:disable:next large_tuple
    func pin(to layoutGuide: UILayoutGuide, insets: UIEdgeInsets = .zero) -> (top: NSLayoutConstraint, bottom: NSLayoutConstraint, leading: NSLayoutConstraint, trailing: NSLayoutConstraint) {

        translatesAutoresizingMaskIntoConstraints = false
        let top = topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: insets.top)
        let bottom = layoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor, constant: insets.bottom)
        let leading = leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: insets.left)
        let trailing = layoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor, constant: insets.right)
        NSLayoutConstraint.activate([top, bottom, leading, trailing])
        return (top: top, bottom: bottom, leading: leading, trailing: trailing)
    }

    func pinTop(to layoutGuide: UILayoutGuide, insets: UIEdgeInsets = .zero) {

        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: insets.left),
            layoutGuide.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor, constant: insets.bottom),
            layoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor, constant: insets.right)
        ])
    }

    func pinBottom(to layoutGuide: UILayoutGuide, insets: UIEdgeInsets = .zero) {

        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            topAnchor.constraint(greaterThanOrEqualTo: layoutGuide.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: insets.left),
            layoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor, constant: insets.bottom),
            layoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor, constant: insets.right)
        ])
    }

    // MARK: - Insetting

    func insetInView(insets: UIEdgeInsets) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        self.pin(to: view, insets: insets)
        return view
    }
}

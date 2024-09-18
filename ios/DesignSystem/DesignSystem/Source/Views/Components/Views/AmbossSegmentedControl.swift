//
//  UISegmentedControl+Init.swift
//  DesignSystem
//
//  Created by Roberto Seidenberg on 22.07.24.
//

import UIKit

public class AmbossSegmentedControl: UISegmentedControl {

    // MARK: - Init

    override public init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    public convenience init() {
        self.init(frame: .zero)
    }

    // MARK: - Template methods

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setup()
    }

    // MARK: - Private helpers
    func setup() {
        let background: UIColor = .backgroundAccentSubtle
        let selected: UIColor = .backgroundPrimary

        backgroundColor = background
        selectedSegmentTintColor = selected

        setTitleTextAttributes(
            .attributes(style: .paragraphSmallBold, with: [
                .color(.textSecondary)
            ]), for: .normal)

        setTitleTextAttributes(
            .attributes(style: .paragraphSmallBold, with: [
                .color(.textSecondary.withAlphaComponent(0.5))
            ]), for: .disabled)

        setTitleTextAttributes(
            .attributes(style: .paragraphSmallBold, with: [
                .color(.textAccent)
            ]), for: .selected)
    }
}

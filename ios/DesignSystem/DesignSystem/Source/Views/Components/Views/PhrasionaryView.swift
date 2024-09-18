//
//  PhrasionaryView.swift
//  DesignSystem
//
//  Created by Manaf Alabd Alrahim on 12.03.24.
//

import UIKit

public protocol PhrasionaryViewDelegate: AnyObject {
    func didTapPhrasionaryTarget(at index: Int)
}

public final class PhrasionaryView: UIView {

    public struct ViewData {
        public let title: String
        public let subtitle1: String?
        public let subtitle2: String?
        public let body: String?
        public let targets: [NSAttributedString]

        public init(title: String,
                    subtitle1: String?,
                    subtitle2: String?,
                    body: String?,
                    targets: [NSAttributedString]) {
            self.title = title
            self.body = body
            self.subtitle1 = subtitle1
            self.subtitle2 = subtitle2
            self.targets = targets
        }
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let subtitle1Label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitle2Label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let mainStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .leading
        view.distribution = .fill
        view.spacing = .spacing.xs
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let targetsStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .leading
        view.distribution = .fill
        view.spacing = .spacing.xs
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .dividerSecondary
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private weak var delegate: PhrasionaryViewDelegate?

    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public init() {
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStackView)
        addSubview(lineView)
        mainStackView.pin(to: self, insets: .init(all: .spacing.m))
        lineView.pinBottom(to: self)
        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(subtitle1Label)
        mainStackView.addArrangedSubview(subtitle2Label)
        mainStackView.addArrangedSubview(bodyLabel)
        mainStackView.addArrangedSubview(targetsStackView)
    }

    public func setUp(with viewData: ViewData, delegate: PhrasionaryViewDelegate?) {
        self.delegate = delegate

        titleLabel.attributedText = .attributedString(
            with: viewData.title,
            style: .h5)
        subtitle1Label.attributedText = .attributedString(
            with: viewData.subtitle1 ?? "",
            style: .paragraphSmall,
            decorations: [.color(.textTertiary)])

        subtitle2Label.attributedText = .attributedString(
            with: viewData.subtitle2 ?? "",
            style: .paragraphExtraSmall,
            decorations: [.italic, .color(.textTertiary)])
        bodyLabel.attributedText = .attributedString(
            with: viewData.body ?? "",
            style: .paragraphSmall)
        subtitle1Label.isHidden = viewData.subtitle1?.isEmpty ?? true
        subtitle2Label.isHidden = viewData.subtitle2?.isEmpty ?? true
        bodyLabel.isHidden = viewData.body?.isEmpty ?? true

        targetsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, target) in viewData.targets.enumerated() {
            let button = makeTargetLabel(target: target, at: index)
            targetsStackView.addArrangedSubview(button)
        }
    }

    private func makeTargetLabel(target: NSAttributedString, at index: Int) -> UIView {
        // WORKAROUND: Had to make this a UILabel instead of a UIButton
        // because buttons are not sizing properly in stackViews
        let label = UILabel()
        label.numberOfLines = 2
        label.attributedText = target
        label.translatesAutoresizingMaskIntoConstraints = false
        label.tag = index
        label.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapTarget(sender:)))
        label.addGestureRecognizer(gestureRecognizer)
        return label
    }

    @objc func didTapTarget(sender: UITapGestureRecognizer) {
        guard let tag = sender.view?.tag else { return }
        self.delegate?.didTapPhrasionaryTarget(at: tag)
    }
}

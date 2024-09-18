//
//  SearchResultView.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 01.08.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import UIKit

public protocol SearchResultViewDelegate: AnyObject {
    func didTapSearchResult(at indexPath: IndexPath, subIndex: Int?)
}

public final class SearchResultView: UIView {

    public struct ViewData {
        let title: NSAttributedString?
        let body: NSAttributedString?
        let indexPath: IndexPath
        let children: [SearchResultChildView.ViewData]

        public init(title: NSAttributedString?,
                    body: NSAttributedString?,
                    indexPath: IndexPath,
                    children: [SearchResultChildView.ViewData]) {
            self.title = title
            self.body = body
            self.indexPath = indexPath
            self.children = children
        }
    }

    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .backgroundPrimary
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.setContentCompressionResistancePriority(.required, for: .vertical)
        return stackView
    }()

    let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = .spacing.xxs
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.setContentCompressionResistancePriority(.required, for: .vertical)
        stackView.layoutMargins = UIEdgeInsets(horizontal: .spacing.m, vertical: .spacing.s)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()

    let bodyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()

    let separator: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.backgroundColor = .dividerPrimary
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let childrenStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.setContentCompressionResistancePriority(.required, for: .vertical)
        return stackView
    }()

    private var viewData: ViewData?
    private weak var delegate: SearchResultViewDelegate?

    override public init(frame: CGRect = .zero) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    public func commonInit() {
        backgroundColor = .clear

        stackView.addArrangedSubview(textStackView)
        stackView.addArrangedSubview(separator)
        stackView.addArrangedSubview(childrenStackView)
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(bodyLabel)
        addSubview(stackView)

        stackView.clipsToBounds = false
        stackView.pin(to: self,
                      insets: UIEdgeInsets(top: 1, // Special case here to make the top border show
                                           left: .spacing.none,
                                           bottom: .spacing.xs,
                                           right: .spacing.none))
        stackView.apply(elevation: .one)
    }

    public func configure(viewData: ViewData, delegate: SearchResultViewDelegate?) {
        self.viewData = viewData
        self.delegate = delegate

        titleLabel.attributedText = viewData.title
        bodyLabel.attributedText = viewData.body
        bodyLabel.isHidden = viewData.body?.string.isEmpty ?? true
        separator.isHidden = viewData.children.isEmpty

        childrenStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (index, child) in viewData.children.enumerated() {
            let childView = SearchResultChildView()
            childView.tag = index
            childView.configure(viewData: child, hideSeparator: index == viewData.children.count - 1)

            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapChild(sender:)))
            childView.addGestureRecognizer(tapRecognizer)

            childrenStackView.addArrangedSubview(childView)
        }
    }

    @objc func didTapChild(sender: UITapGestureRecognizer) {
        guard let indexPath = viewData?.indexPath,
              let subIndex = sender.view?.tag else { return }
        self.delegate?.didTapSearchResult(at: indexPath, subIndex: subIndex)
    }
}

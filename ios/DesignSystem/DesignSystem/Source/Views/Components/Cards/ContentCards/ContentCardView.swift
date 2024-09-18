//
//  ImageContentCardView.swift
//  DesignSystem
//
//  Created by Manaf Alabd Alrahim on 06.09.23.
//

import UIKit

public protocol ContentCardViewDelegate: AnyObject {
    func didTapContentCard(at index: Int)
    func didDismissContentCard(at index: Int)
    func didViewContentCard(at index: Int)
    func shouldOpenContentCardFeed()
}

public class ContentCardView: CardView {

    public struct ViewData {
        public let index: Int
        public let image: UIImage?
        public let imageURL: URL?
        public let title: String
        public let subtitle: String
        public let action: String?
        public let isDismisable: Bool
        public let isClickable: Bool
        public let isSelected: Bool
        public let insets: UIEdgeInsets

        public init(index: Int,
                    image: UIImage?,
                    imageURL: URL?,
                    title: String,
                    subtitle: String,
                    action: String?,
                    isDismisable: Bool,
                    isClickable: Bool,
                    isSelected: Bool,
                    insets: UIEdgeInsets) {
            self.index = index
            self.image = image
            self.imageURL = imageURL
            self.title = title
            self.subtitle = subtitle
            self.action = action
            self.isDismisable = isDismisable
            self.isClickable = isClickable
            self.isSelected = isSelected
            self.insets = insets
        }
    }

    private var viewData: ViewData?
    private var axis: NSLayoutConstraint.Axis
    private var heightConstraint: NSLayoutConstraint?
    private weak var delegate: ContentCardViewDelegate?

    private let mainStackView: UIStackView = {
        let view = UIStackView()
        view.distribution = .fill
        view.backgroundColor = .backgroundPrimary
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isLayoutMarginsRelativeArrangement = true
        view.setContentHuggingPriority(.required, for: .vertical)
        return view
    }()

    private let imageView: LoadableImageView = {
        let view = LoadableImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .backgroundSecondary
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: 2.0).isActive = true
        view.isHidden = true
        return view
    }()

    private let textContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let textStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = .spacing.xs
        view.distribution = .fill
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        view.setContentHuggingPriority(.required, for: .vertical)
        return view
    }()

    private let subtitleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 3
        view.lineBreakMode = .byTruncatingTail
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        return view
    }()

    private let actionLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        view.setContentHuggingPriority(.required, for: .vertical)
        return view
    }()

    private let dismissButton: UIButton = {
        let view = UIButton()
        view.heightAnchor.constraint(equalToConstant: .h48).isActive = true
        view.widthAnchor.constraint(equalToConstant: .h48).isActive = true
        view.setImage(Asset.Icon.closeCircle.image, for: .normal)
        view.tintColor = .iconQuaternary
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override public init(frame: CGRect = .zero) {
        // determine initial axis
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        let isLandscape = UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight
        let isWideLayout = isIPad || isLandscape

        self.axis = isWideLayout ? .horizontal : .vertical

        super.init(elevationLevel: ElevationLevel.one)
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        let shouldBeHorizontal = traitCollection.userInterfaceIdiom == .pad || traitCollection.verticalSizeClass == .compact
        let axis: NSLayoutConstraint.Axis = shouldBeHorizontal ? .horizontal : .vertical
        self.setup(axis: axis)
    }

    public func setInteractions(interactions: [UIInteraction]) {
        self.contentView.interactions = interactions
    }

    public func setup(with viewData: ViewData,
                      delegate: ContentCardViewDelegate?) {
        self.viewData = viewData
        self.delegate = delegate

        imageView.cancel()
        imageView.image = nil

        // Fill data in view
        margins = viewData.insets
        isUserInteractionEnabled = viewData.isClickable

        imageView.isHidden = viewData.image == nil && viewData.imageURL == nil
        if let image = viewData.image {
            imageView.image = image
        } else if let imageURL = viewData.imageURL {
            imageView.loadImage(from: imageURL)
        }
        dismissButton.isHidden = !viewData.isDismisable
        titleLabel.attributedText = .attributedString(
            with: viewData.title,
            style: .paragraphSmallBold)
        .with(.byTruncatingTail)

        subtitleLabel.attributedText = .attributedString(
            with: viewData.subtitle,
            style: .paragraphSmall,
            decorations: [.color(.textSecondary)])
        .with(.byTruncatingTail)

        actionLabel.isHidden = viewData.action == nil
        actionLabel.attributedText = .attributedString(
            with: viewData.action ?? "",
            style: .h6,
            decorations: [.color(.textTertiary), .alignment(.right)])
        .with(.byTruncatingTail)

        contentView.layer.borderColor = UIColor.borderAccent.cgColor
        contentView.layer.borderWidth = viewData.isSelected ? 3 : 0
        self.layoutIfNeeded()
    }

    public func setup(axis: NSLayoutConstraint.Axis) {
        // If view has already been setup and axis is really changed
        if mainStackView.arrangedSubviews.isEmpty || self.axis != axis {
            self.axis = axis
            mainStackView.axis = axis
            mainStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

            if axis == .vertical {
                mainStackView.addArrangedSubview(imageView)
                mainStackView.addArrangedSubview(textContainerView)
                mainStackView.alignment = .fill
                heightConstraint?.priority = .defaultLow
            } else {
                mainStackView.addArrangedSubview(textContainerView)
                mainStackView.addArrangedSubview(imageView)
                mainStackView.alignment = .center
                heightConstraint?.priority = .required
            }
            self.layoutIfNeeded()
        }
    }

    override public func commonInit() {
        super.commonInit()

        contentView.addSubview(mainStackView)
        mainStackView.pin(to: contentView)

        // Adds sub views to main stackView
        setup(axis: axis)

        textContainerView.addSubview(textStackView)
        textStackView.pin(to: textContainerView, insets: .init(all: .spacing.m))

        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(subtitleLabel)
        textStackView.addArrangedSubview(actionLabel)

        // Add height constraint
        let heightConstraint = mainStackView.heightAnchor.constraint(lessThanOrEqualToConstant: .h200)
        heightConstraint.priority = self.axis == .horizontal ? .required : .defaultLow
        heightConstraint.isActive = true
        self.heightConstraint = heightConstraint

        // Add dismiss button
        contentView.addSubview(dismissButton)
        dismissButton.addTarget(self, action: #selector(didTapDismiss), for: .touchUpInside)
        NSLayoutConstraint.activate([
            dismissButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentView.trailingAnchor.constraint(equalTo: dismissButton.trailingAnchor)
        ])
    }

    override public func didTap() {
        guard let viewData else { return }
        delegate?.didTapContentCard(at: viewData.index)
    }

    @objc func didTapDismiss(button: UIButton) {
        guard let viewData else { return }
        delegate?.didDismissContentCard(at: viewData.index)
    }
}

extension ContentCardView: UIContextMenuInteractionDelegate {
    public func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil,
                                          actionProvider: { [weak self] _ in
            guard let self, let viewData else { return UIMenu(children: []) }

            let clickAction = UIAction(title: "Log click") { _ in
                self.delegate?.didTapContentCard(at: viewData.index)
            }
            let impressionAction = UIAction(title: "Log impression") { _ in
                self.delegate?.didViewContentCard(at: viewData.index)
            }
            let dismissedAction = UIAction(title: "Log dismissal") { _ in
                self.delegate?.didDismissContentCard(at: viewData.index)
            }
            let cardFeed = UIAction(title: "Open card feed") { _ in
                self.delegate?.shouldOpenContentCardFeed()
            }
            return UIMenu(children: [clickAction, impressionAction, dismissedAction, cardFeed])
        })
    }
}

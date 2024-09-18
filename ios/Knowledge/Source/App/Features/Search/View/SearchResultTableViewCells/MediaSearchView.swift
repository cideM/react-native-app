//
//  MediaSearchView.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 30.09.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//
import Common
import Domain
import UIKit

open class MediaSearchView: UIStackView {
    private var imageWidthConstraint: NSLayoutConstraint?
    private var imageViewHasDynamicWidth = true

    private lazy var loadingBackground: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.type = .radial
        gradientLayer.colors = ThemeManager.currentTheme.mediaSearchViewBackgroundGradientColors
        gradientLayer.locations = [0, 1]
        gradientLayer.cornerRadius = 8
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = ThemeManager.currentTheme.searchMediaviewImageBackgroundColor
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.borderPrimary.cgColor
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return imageView
    }()

    private let typeStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return stack
    }()

    private let typeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .iconTertiary
        imageView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        return imageView
    }()

    private let typeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()

    private let titleStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .top
        stack.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return stack
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        return label
    }()

    init(frame: CGRect = .zero, mediaItem: MediaSearchViewItem) {
        super.init(frame: frame)
        axis = .vertical
        spacing = 8
        alignment = .leading
        distribution = .fill

        addSubviews()

        self.imageWidthConstraint = imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1)
        self.imageWidthConstraint?.isActive = true

        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor).isActive = true
        titleLabel.sizeToFit()

        fillData(mediaItem)
    }

    @available(*, unavailable)
    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        if layer.sublayers?.contains(loadingBackground) == false {
            loadingBackground.frame = imageView.frame
            layer.addSublayer(loadingBackground)
        }
    }

    private func fillData(_  mediaItem: MediaSearchViewItem) {

        if mediaItem.category == .calculator {
            imageView.contentMode = .scaleAspectFill
        }

        typeImageView.image = icon(for: mediaItem.category)
        typeLabel.attributedText = NSAttributedString(string: mediaItem.typeName.uppercased(), attributes: ThemeManager.currentTheme.searchMediaViewTypeTextAttributes)
        titleLabel.attributedText = NSAttributedString(string: mediaItem.title, attributes: ThemeManager.currentTheme.searchMediaViewTitleTextAttributes)
        mediaItem.loadImage { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let image):
                self.imageView.image = image
                self.layer.insertSublayer(self.loadingBackground, below: self.imageView.layer)
                self.updateImageViewWidthIfNeeded(for: image)
                self.setNeedsLayout()
            case .failure:
                self.imageView.contentMode = .center
                self.imageView.image = Asset.Icon.mediaBroken.image
            }
        }

        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.onTap = {
            mediaItem.tapHandler(mediaItem)
        }
        addGestureRecognizer(tapGestureRecognizer)
    }

    private func updateImageViewWidthIfNeeded(for image: UIImage) {
        if self.imageViewHasDynamicWidth {
            let aspectRatio = max(1, image.size.width / image.size.height)
            self.imageWidthConstraint?.isActive = false
            self.imageWidthConstraint = imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: aspectRatio)
            self.imageWidthConstraint?.isActive = true
        }
    }

    private func icon(for category: MediaSearchItem.Category) -> UIImage {
        switch category {
        case .flowchart: return Asset.Icon.MediaTypes.flowchart.image
        case .illustration: return Asset.Icon.MediaTypes.illustration.image
        case .photo: return Asset.Icon.MediaTypes.image.image
        case .imaging: return Asset.Icon.MediaTypes.imaging.image
        case .chart: return Asset.Icon.MediaTypes.chart.image
        case .microscopy: return Asset.Icon.MediaTypes.microscope.image
        case .audio: return Asset.Icon.MediaTypes.headphones.image
        case .auditor: return Asset.Icon.MediaTypes.auditor.image
        case .video: return Asset.Icon.MediaTypes.film.image
        case .calculator: return Asset.Icon.MediaTypes.calculator.image
        case .webContent: return Asset.Icon.MediaTypes.link.image
        case .meditricks: return Asset.Icon.Feature.meditricks.image
        case .smartzoom: return Asset.Icon.MediaTypes.microscope.image
        case .effigos: return Asset.Icon.MediaTypes.box.image
        case .other: return Asset.Icon.MediaTypes.image.image
        }
    }

    private func addSubviews() {
        addArrangedSubview(imageView)
        typeStackView.addArrangedSubview(typeImageView)
        typeStackView.setCustomSpacing(6.0, after: typeImageView)
        typeStackView.addArrangedSubview(typeLabel)
        addArrangedSubview(typeStackView)
        titleStackView.addArrangedSubview(titleLabel)
        addArrangedSubview(titleStackView)
    }
}

extension MediaSearchView {
    func setImageAspectRatio(_ aspectRatio: CGFloat) {
        imageViewHasDynamicWidth = false
        self.imageWidthConstraint?.isActive = false
        self.imageWidthConstraint = imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: aspectRatio)
        self.imageWidthConstraint?.isActive = true
    }
}

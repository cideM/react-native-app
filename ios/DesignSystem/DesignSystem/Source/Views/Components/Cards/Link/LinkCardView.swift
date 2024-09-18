//
//  LinkCardView.swift
//  DesignSystem
//
//  Created by Roberto Seidenberg on 11.09.24.
//

import UIKit

public protocol LinkCardViewDelegate: AnyObject {
    func didTapLinkCard(_ card: LinkCardView)
}

public class LinkCardView: CardView {

    public struct ViewData {
        public let image: UIImage?
        public let text: String
        public let url: URL

        public init(image: UIImage?, text: String, url: URL) {
            self.image = image
            self.text = text
            self.url = url
        }
    }

    // MARK: - Private properties

    private weak var delegate: LinkCardViewDelegate?

    public private(set) var viewData: ViewData?

    private let stackView: UIStackView = {
        let view = UIStackView()
        view.distribution = .fill
        view.backgroundColor = .backgroundPrimary
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isLayoutMarginsRelativeArrangement = true
        view.spacing = Spacing.xs
        return view
    }()

    private let label: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.lineBreakMode = .byWordWrapping
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return view
    }()

    private let imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.tintColor = .iconAccent // <- right color for template images
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 48)
        ])
        return view
    }()

    private let iconImageView: UIImageView = {
        let view = UIImageView()
        view.image = Asset.Icon.externalLink.image
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 16)
        ])
        return view
    }()

    private let spinner: UIActivityIndicatorView = {
        UIActivityIndicatorView(style: .medium)
    }()

    // MARK: - Template methods

    override public func didTap() {
        guard !spinner.isAnimating else { return }
        spinner.startAnimating()
        iconImageView.isHidden = true
        delegate?.didTapLinkCard(self)
    }

    // MARK: - Setters

    public func setup(with viewData: ViewData, delegate: LinkCardViewDelegate? = nil) {
        self.delegate = delegate
        self.viewData = viewData

        imageView.isHidden = viewData.image == nil
        imageView.image = viewData.image

        label.attributedText = .attributedString(
            with: viewData.text,
            style: .paragraphSmall,
            decorations: [.color(.textSecondary)])
        .with(.byWordWrapping)
    }

    public func hideSpinner() {
        spinner.stopAnimating()
        iconImageView.isHidden = false
    }

    // MARK: - Init

    override public func commonInit() {
        super.commonInit()

        contentView.addSubview(stackView)
        stackView.pin(to: contentView, insets: .init(all: .spacing.m))

        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(label)

        // Stackview inside stackvie to get icon to the bottom ...
        let verticalStackView = UIStackView()
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.axis = .vertical
        verticalStackView.addArrangedSubview(UIView())
        verticalStackView.addArrangedSubview(iconImageView)
        verticalStackView.addArrangedSubview(spinner)
        stackView.addArrangedSubview(verticalStackView)
    }
}

// MARK: - Preview

#if DEBUG
import SwiftUI

struct LinkCardViewPreviews: PreviewProvider {
    static var previews: some View {
        Group {
            SwiftUILinkCardView()
        }
        .padding(.init(.spacing.m))
    }
}

struct SwiftUILinkCardView: UIViewRepresentable {
    typealias UIViewType = LinkCardView

    func makeUIView(context: Context) -> LinkCardView {
        LinkCardView()
    }

    func updateUIView(_ uiView: LinkCardView, context: Context) {
        let text = "Mit unseren Online-Fortbildungen den klinischen Horizont erweitern und CME-Punkte sammeln."
        let url = URL(string: "https://www.amboss.com/de/app2web/courses")! // swiftlint:disable:this force_unwrapping
        let image = UIImage(systemName: "photo.on.rectangle.angled")
        uiView.setup(with: .init(image: image, text: text, url: url))
    }
}
#endif

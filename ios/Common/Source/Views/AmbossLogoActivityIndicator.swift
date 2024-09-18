//
//  AnimatedActivityIndicator.swift
//  Common
//
//  Created by Silvio Bulla on 23.08.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import UIKit

public class AmbossLogoActivityIndicator: UIView {

    public static let animationDuration: TimeInterval = 0.3

    // These transformations are purely cosmetic
    // It just looks a bit slicker when the indicator also shrinks a bit while fading out ...
    private static let animatingTransform = CGAffineTransform.identity
    private static let nonAnimatingTransform = CGAffineTransform(scaleX: 0.8, y: 0.8)

    private let imageView: UIImageView = {
        let view = UIImageView()
        view.transform = nonAnimatingTransform
        return view
    }()

    private var initialImage = UIImage(named: "RefreshAnimationFrame_21")?.withRenderingMode(.alwaysTemplate) ?? UIImage()

    private var animationImages: [UIImage] = {
        var images = [UIImage]()
        for index in 0...21 {
            guard let image = UIImage(named: "RefreshAnimationFrame_\(index)")?.image(withTint: Color.brandMain38.value) else { return [] }
            images.append(image)
        }
        return images
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        isUserInteractionEnabled = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = self.initialImage
        imageView.image = initialImage
        imageView.animationImages = animationImages
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        setupConstraint()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func startLogoAnimation(animated: Bool = false) {
        imageView.animationDuration = TimeInterval(animationImages.count) * 1.0 / 21.0
        imageView.startAnimating()
        imageView.transform = AmbossLogoActivityIndicator.nonAnimatingTransform

        UIView.animate(withDuration: AmbossLogoActivityIndicator.animationDuration,
                       delay: 0,
                       options: [.curveEaseInOut, .beginFromCurrentState]) { [weak self] in
            self?.imageView.transform = AmbossLogoActivityIndicator.animatingTransform
            self?.imageView.alpha = 1.0
        }
    }

    public func stopLogoAnimation(animated: Bool = false) {
        UIView.animate(withDuration: animated ? AmbossLogoActivityIndicator.animationDuration : 0.00,
                       delay: 0,
                       options: [.curveEaseInOut, .beginFromCurrentState],
                       animations: { [weak self] in
            self?.imageView.alpha = 0.0
            self?.imageView.transform = AmbossLogoActivityIndicator.nonAnimatingTransform
        }, completion: { [weak self] _ in
            self?.imageView.stopAnimating()
        })
    }

    private func setupConstraint() {
        imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
}

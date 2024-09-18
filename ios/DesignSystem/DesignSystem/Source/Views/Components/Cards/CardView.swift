//
//  CardView.swift
//  DesignSystem
//
//  Created by Manaf Alabd Alrahim on 06.09.23.
//

import UIKit

open class CardView: UIView {

    private let elevationLevel: ElevationLevel
    public var margins: UIEdgeInsets {
        didSet {
            topConstraint?.constant = margins.top
            bottomConstraint?.constant = margins.bottom
            leadingConstraint?.constant = margins.left
            trailingConstraint?.constant = margins.right
        }
    }

    private var elevatedView: ElevatedView?

    private var topConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?
    private var leadingConstraint: NSLayoutConstraint?
    private var trailingConstraint: NSLayoutConstraint?

    private static let scaleDownPercentage: CGFloat = 0.98

    private static let animationDuration: CGFloat = 0.2

    private static let startAnimationDelay: CGFloat = 0.05
    private static let endAnimationDelay: CGFloat = 0
    private static let cancelAnimationDelay: CGFloat = 0

    private static let startAnimationDamping: CGFloat = 0.3
    private static let endAnimationDamping: CGFloat = 0.5
    private static let cancelAnimationDamping: CGFloat = 0.8

    private static let startAnimationInitialVelocity: CGFloat = 0.7
    private static let endAnimationInitialVelocity: CGFloat = 0.5
    private static let cancelAnimationInitialVelocity: CGFloat = 0.1

    let contentView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = .backgroundPrimary
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    @available(*, unavailable)
    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(elevationLevel: ElevationLevel,
                margins: UIEdgeInsets = .zero) {
        self.elevationLevel = elevationLevel
        self.margins = margins
        super.init(frame: .zero)
        self.commonInit()
    }

    override public init(frame: CGRect) {
        self.elevationLevel = .one
        self.margins = .zero
        super.init(frame: frame)
        self.commonInit()
    }

    open func commonInit() {
        clipsToBounds = false

        addSubview(contentView)
        contentView.apply(cornerRadius: .radius.s)

        self.topConstraint?.isActive = false
        self.bottomConstraint?.isActive = false
        self.leadingConstraint?.isActive = false
        self.trailingConstraint?.isActive = false

        let (top, bottom, leading, trailing) = contentView.pin(to: self, insets: margins)

        self.topConstraint = top
        self.bottomConstraint = bottom
        self.leadingConstraint = leading
        self.trailingConstraint = trailing
        self.bottomConstraint?.priority = .default
    }

    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.elevatedView = contentView.apply(elevation: elevationLevel)
    }

    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.elevatedView?.removeFromSuperview()
        self.elevatedView = contentView.apply(elevation: elevationLevel)
    }

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: Self.animationDuration,
                       delay: Self.startAnimationDelay,
                       usingSpringWithDamping: Self.startAnimationDamping,
                       initialSpringVelocity: Self.startAnimationInitialVelocity) {
            let transform = CGAffineTransform(scaleX: Self.scaleDownPercentage, y: Self.scaleDownPercentage)
            self.contentView.transform = transform
            self.elevatedView?.transform = transform
        }
    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let touchPoint = touches.first?.location(in: self) else { return }
            if self.bounds.contains(touchPoint) {
                UIView.animate(withDuration: Self.animationDuration,
                               delay: Self.endAnimationDelay,
                               usingSpringWithDamping: Self.endAnimationDamping,
                               initialSpringVelocity: Self.endAnimationInitialVelocity) {
                    let transform = CGAffineTransform.identity
                    self.contentView.transform = transform
                    self.elevatedView?.transform = transform
                }
                didTap()
            } else {
                touchesCancelled(touches, with: event)
            }
    }

    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: Self.animationDuration,
                       delay: Self.cancelAnimationDelay,
                       usingSpringWithDamping: Self.cancelAnimationDamping,
                       initialSpringVelocity: Self.cancelAnimationDamping) {
            let transform = CGAffineTransform.identity
            self.contentView.transform = transform
            self.elevatedView?.transform = transform
        }
    }

    open func didTap() { }
}

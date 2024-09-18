//
//  StripeView.swift
//  Knowledge DE
//
//  Created by Roberto Seidenberg on 02.02.24.
//  Copyright © 2024 AMBOSS GmbH. All rights reserved.
//

#if Debug || QA

import UIKit
import CloudKit

class ZebraView: UIView {

    var showsStripes = true
    var stripeThickness: CGFloat = 15
    var stripeDistance: CGFloat = 15
    var speed: CGFloat = 0.25

    private var offset: CGFloat = 0

    private var _isAnimating = false { didSet {
        displayLink?.isPaused = _isAnimating == false
        setNeedsDisplay()
    }}

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private let gradient: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = .zero
        layer.endPoint = CGPoint(x: 0, y: 1)
        let white = UIColor.white
        layer.colors = [white.withAlphaComponent(1).cgColor, white.withAlphaComponent(0).cgColor]
        layer.locations = [NSNumber(value: 0), NSNumber(value: 1)]
        return layer
    }()

    func setup() {
        gradient.frame = bounds
        layer.mask = gradient
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }

    func setIsAnimating(_ isAnimating: Bool, animated: Bool) {
        guard isAnimating != _isAnimating else { return }
        if animated {
            if _isAnimating == true, isAnimating == true {
                // Do nothing ...
            } else if _isAnimating, isAnimating == false {
                UIView.animate(withDuration: 0.25, animations: { self.alpha = 0 }, completion: { _ in
                    self._isAnimating = false
                    self.alpha        = 1
                })
            } else if _isAnimating == false, isAnimating == true {
                self.alpha        = 0
                self._isAnimating = true
                UIView.animate(withDuration: 0.25, animations: { self.alpha = 1 })
            }
        } else {
            _isAnimating = isAnimating
        }
    }

    private var displayLink: CADisplayLink?

    var color: UIColor = .clear { didSet {
        backgroundColor = color.withAlphaComponent(0.05)

        layer.borderWidth = 1.0
        layer.borderColor = color.withAlphaComponent(0.15).cgColor
    }}

    var stripeColor: UIColor = .clear { didSet { setNeedsDisplay() } }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        displayLink?.isPaused = _isAnimating == false
        if superview == nil { displayLink?.isPaused = true }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        if window != nil {
            displayLink = CADisplayLink(target: self, selector: #selector(update))
            displayLink?.add(to: .main, forMode: .common)
            displayLink?.isPaused = _isAnimating == false
        } else {
            displayLink?.invalidate()
        }
    }

    deinit {
        displayLink?.invalidate()
    }

    @objc func update() {
        offset += 1 * speed

        if UIApplication.shared.applicationState == .active {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        // Taken from here and modified:
        // https://stackoverflow.com/questions/35750554/fill-a-uiview-with-diagonally-drawn-lines
        guard showsStripes else { return }

        let T: CGFloat = stripeThickness
        let G: CGFloat = stripeDistance
        let W = rect.size.width
        let H = rect.size.height
        guard let c = UIGraphicsGetCurrentContext() else { return }
        c.setStrokeColor(stripeColor.cgColor)
        c.setLineWidth(T)

        var p = -(W > H ? W : H) - T - offset
        while p <= W {
            c.move(to: CGPoint(x: p - T, y: -T))
            c.addLine(to: CGPoint(x: p + T + H, y: T + H))
            c.strokePath()
            p += G + T + T
        }
    }
}
#endif

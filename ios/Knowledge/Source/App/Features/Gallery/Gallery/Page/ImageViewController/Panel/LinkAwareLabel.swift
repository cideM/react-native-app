//
//  LinkAwareLabel.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 20.06.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import UIKit

class LinkAwareLabel: UILabel {

    var linkTapCallback: ((URL) -> Void)?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    override var attributedText: NSAttributedString? {
        didSet {
            guard let attributedText = attributedText else { return }

            let textContainer = NSTextContainer(size: bounds.size)
            let layoutManager = NSLayoutManager()
            let textStorage = NSTextStorage(attributedString: attributedText)

            layoutManager.addTextContainer(textContainer)
            textStorage.addLayoutManager(layoutManager)

            textContainer.lineFragmentPadding = 0
            textContainer.lineBreakMode = lineBreakMode
            textContainer.maximumNumberOfLines = numberOfLines

            self.layoutManager = layoutManager
            self.textContainer = textContainer
            self.textStorage = textStorage
        }
    }

    private var layoutManager: NSLayoutManager?
    private var textContainer: NSTextContainer?
    private var textStorage: NSTextStorage?

    private func setup() {
        isUserInteractionEnabled = true // required to make the recognizer work
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(recognizer)
    }

    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        guard let layoutManager = layoutManager, let textContainer = textContainer, let attributedText = attributedText else {
            return
        }

        // This logic taken from here:
        // https://stackoverflow.com/questions/1256887/create-tap-able-links-in-the-nsattributedstring-of-a-uilabel
        // Find out if user tapped a link ...
        let location = sender.location(in: self)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(
            x: (bounds.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
            y: (bounds.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y
        )
        let locationOfTouchInTextContainer = CGPoint(
            x: location.x - textContainerOffset.x,
            y: location.y - textContainerOffset.y
        )
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer,
                                                            in: textContainer,
                                                            fractionOfDistanceBetweenInsertionPoints: nil)

        let tappedCharacterRange = NSRange(location: indexOfCharacter, length: 1)

        attributedText.enumerateAttribute(.attachment, in: tappedCharacterRange) { [weak self] value, _, _ in
            if let value = value as? Data, let url = URL(dataRepresentation: value, relativeTo: nil) {
                self?.open(url: url)
            }
        }

        attributedText.enumerateAttribute(.link, in: tappedCharacterRange) { [weak self] value, _, _ in
            if let value = value, let url = URL(string: String(describing: value)) {
                self?.open(url: url)
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        textContainer?.size = bounds.size
    }

    private func open(url: URL) {
        // WORKAROUND:
        // There are plenty of "http" URLs in the library which iOS wont open anyways
        // Hence we're brute forcing everything to https here ...
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            assertionFailure("URL not supported")
            return
        }
        components.scheme = "https"

        if let url = components.url {
            linkTapCallback?(url)
        }
    }
}

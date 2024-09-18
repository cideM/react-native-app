//
//  RichTextCell.swift
//  RichTextRenderer
//
//  Created by Mohamed Abdul Hameed on 20.01.21.
//

import UIKit
/*
 This class is inspired by Contentful's RichTextViewController (https://github.com/contentful-labs/rich-text-renderer.swift/blob/master/Sources/RichTextRenderer/ViewController/RichTextViewController.swift).
 */
public class RichTextCell: UICollectionViewCell {
    
    private enum Constant {
        static let hrSuffix = "-hr"
    }
    
    public weak var delegate: RichTextCellDelegate?

    /// Renderer of the `Contentful.RichTextDocument`.
    private var renderer: RichTextDocumentRenderer? {
        didSet {
            guard let renderer = renderer else { return }
            
            layoutManager.blockQuoteDecorationRenderer = BlockQuoteDecorationRenderer(
                blockQuoteConfiguration: renderer.configuration.blockQuote,
                textContainerInsets: renderer.configuration.contentInsets
            )
            
            textContainer.add(provider: BlockLineFragmentProvider(
                blockQuoteConfiguration: renderer.configuration.blockQuote)
            )
            
            textView.textContainerInset = renderer.configuration.contentInsets
        }
    }

    /// The `renderer` renders `Contentful.RichTextDocument` into this view.
    private var textView: UITextView!

    /// The underlying text storage.
    private let textStorage = NSTextStorage()

    /// The custom `NSLayoutManager` which lays out the text within the text container and text view.
    private let layoutManager = DefaultLayoutManager()

    /// Document to be rendered.
    public var richTextDocument: RichTextDocument? {
        didSet {
            if richTextDocument != oldValue {
                renderDocument()
            }
        }
    }

    /// Storage for exclusion paths, regions where a text is not rendered in the text container.
    private var exclusionPathsStorage: [String: UIBezierPath] = [:]

    private var attachmentViews = [String: UIView]()

    /// The custom `NSTextContainer` which manages the areas text can be rendered to.
    private var textContainer: ConcreteTextContainer!

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    public func configure(rendererConfiguration: RendererConfiguration, richTextDocument: RichTextDocument?) {
        self.renderer = RichTextDocumentRenderer(configuration: rendererConfiguration, nodeRenderers: DefaultRenderersProvider())
        self.richTextDocument = richTextDocument
        self.textView.backgroundColor = .clear
    }

    private func setupTextView() {
        textView = UITextView(frame: contentView.bounds, textContainer: textContainer)
        textView.backgroundColor = renderer?.configuration.backgroundColor

        contentView.addSubview(textView)

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 5).isActive = true
        textView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -11).isActive = true
        textView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor).isActive = true

        textView.isScrollEnabled = false
        textView.isEditable = false
        
        textView.delegate = self
    }

    private func invalidateLayout() {
        exclusionPathsStorage.removeAll()

        attachmentViews.forEach { _, view in view.removeFromSuperview() }
        attachmentViews.removeAll()

        textView.textContainer.exclusionPaths.removeAll()
    }

    private func renderDocument() {
        guard let renderer = renderer else { return assertionFailure("RichTextDocumentRenderer is not initialized") }
        guard let document = richTextDocument else { return }

        let output = renderer.render(document: document)
        self.textStorage.beginEditing()
        self.textStorage.setAttributedString(output)
        self.textStorage.endEditing()
    }

    private func layoutElementsOnTextView(containerSize: CGSize) {
        textView.textStorage.enumerateAttributes(
            in: textView.textStorage.fullRange,
            options: []
        ) { attributes, range, _ in
            if attributes.keys.contains(.horizontalRule) {
                layoutHorizontalRuleElement(attributes: attributes, range: range, containerSize: containerSize)
            }
        }
    }

    private func layoutHorizontalRuleElement(attributes: [NSAttributedString.Key: Any], range: NSRange, containerSize: CGSize) {
        guard let renderer = renderer else { return assertionFailure("RichTextDocumentRenderer is not initialized") }
        
        let contentInset = renderer.configuration.contentInsets

        guard let attrView = attributes[.horizontalRule] as? UIView else {
            return
        }

        let glyphRange = layoutManager.glyphRange(
            forCharacterRange: NSRange(location: range.location, length: 1),
            actualCharacterRange: nil
        )

        let glyphIndex = glyphRange.location
        guard glyphIndex != NSNotFound && glyphRange.length == 1 else {
            attrView.isHidden = true
            return
        }

        let lineFragmentRect = layoutManager.lineFragmentRect(
            forGlyphAt: glyphIndex,
            effectiveRange: nil
        )

        let glyphLocation = layoutManager.location(forGlyphAt: glyphIndex)

        let newWidth = containerSize.width
            - lineFragmentRect.minX
            - contentInset.left
            - contentInset.right

        let boundingRect = CGRect(
            x: lineFragmentRect.minX,
            y: lineFragmentRect.minY,
            width: containerSize.width,
            height: 0
        )

        let attachmentRect = CGRect(
            x: lineFragmentRect.minX + glyphLocation.x + contentInset.left,
            y: lineFragmentRect.minY + contentInset.top,
            width: newWidth,
            height: attrView.frame.height
        )

        let exclusionKey = String(range.hashValue) + Constant.hrSuffix
        addExclusionPath(for: boundingRect, key: exclusionKey)

        if attrView.superview == nil {
            attrView.frame = attachmentRect
            textView.addSubview(attrView)
            attachmentViews[exclusionKey] = attrView
        }
    }

    /**
     Adds exclusion path for a passed in rect.
     - Parameters:
        - rect: Rect for which exclusion path should be set.
        - key: String uniquely representing the exlusioned rect.
     */
    private func addExclusionPath(for rect: CGRect, key: String) {
        guard exclusionPathsStorage[key] == nil else { return }

        let exclusionPath = UIBezierPath(rect: rect)
        exclusionPathsStorage[key] = exclusionPath
        textView.textContainer.exclusionPaths.append(exclusionPath)
    }
}

extension RichTextCell {
    private func commonInit() {
        textStorage.addLayoutManager(layoutManager)

        textContainer = ConcreteTextContainer(size: contentView.bounds.size)
        textContainer.widthTracksTextView = true
        textContainer.heightTracksTextView = true
        textContainer.lineBreakMode = .byWordWrapping

        layoutManager.addTextContainer(textContainer)
        layoutManager.delegate = self

        setupTextView()

        contentView.addSubview(textView)
    }
}

extension RichTextCell: NSLayoutManagerDelegate {
    // Inspired by: https://github.com/vlas-voloshin/SubviewAttachingTextView/blob/master/SubviewAttachingTextView/SubviewAttachingTextViewBehavior.swift
    public func layoutManager(
        _ layoutManager: NSLayoutManager,
        didCompleteLayoutFor textContainer: NSTextContainer?,
        atEnd layoutFinishedFlag: Bool
    ) {
        guard layoutFinishedFlag == true else { return }

        layoutElementsOnTextView(containerSize: textView.bounds.size)
    }
}

extension RichTextCell: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let tappedAttributedString = textView.attributedText.attributedSubstring(from: characterRange)
        let attributes = tappedAttributedString.attributes(at: 0, effectiveRange: nil)
        let link = attributes[PharmaRichTextAttribute.ambossLink.key] as? AmbossLink.Data
        let phrasionary = attributes[PharmaRichTextAttribute.phrasionary.key] as? Phrasionary.Data
        delegate?.didTapPharmaRichTextLink(phrasionary: phrasionary, ambossLink: link)
        return false
    }
}

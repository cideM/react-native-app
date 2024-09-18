//
//  TextInputField.swift
//  DesignSystem
//
//  Created by Elmar Tampe on 22.11.23.
//

import UIKit

internal protocol ValidationResultDelegate: AnyObject {
    func validationResultDidChange(_ isValid: Bool, message: String?)
}

public class TextInputField: UITextField {

    // MARK: - Configuration
    public enum TextInputFieldType {
        case textInput
        case search
        case secureTextInput
    }

    internal weak var validationDelegate: ValidationResultDelegate?

    // MARK: - Public
    // UIControl.State is used as type since it represents the states we need for the TextField.
    // Since we do not want to have another Enum for the same purpose we recycle the Type.
    public var componentState: UIControl.State {
        get { textFieldLayer?.componentState ?? .normal }
        set { textFieldLayer?.componentState = newValue }
    }

    override public var isEnabled: Bool {
        get { super.isEnabled }
        set {
            componentState = newValue ? .normal : .disabled
            super.isEnabled = newValue
        }
    }

    public var inputFieldType: TextInputFieldType = .textInput {
        didSet {
            compose()
        }
    }

    public var validator: StringValidation? {
        didSet {
            updateValidator(self)
        }
    }

    override public var placeholder: String? {
        didSet {
            let content: NSAttributedString = .attributedString(with: placeholder ?? "",
                                                                         style: .paragraph,
                                                                         decorations: [.color(.textSecondary)])
            attributedPlaceholder = content.with(.byTruncatingTail)
        }
    }

    override public var text: String? {
        didSet {
            updateValidator(self)
        }
    }

    // MARK: - Initialization
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public init(validator: StringValidation? = nil,
                inputFieldType: TextInputFieldType = .textInput) {
        self.validator = validator
        self.inputFieldType = inputFieldType
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        addTarget(self, action: #selector(updateValidator(_:)), for: .editingChanged)
        clearButtonMode = .whileEditing
        contentVerticalAlignment = UIControl.ContentVerticalAlignment.center

        componentState = .normal
        constrainHeight(.h44)
        compose()
        updateValidator(self)
    }

    // MARK: - Private
    internal var isValidInput = true {
        didSet {
            validationDelegate?.validationResultDidChange(isValidInput, message: validator?.errorMessage)
            textFieldLayer?.isValidInput = isValidInput
            let color: UIColor = isValidInput ? .textPrimary : .textError
            defaultTextAttributes = .attributes(style: .paragraph, with: [.color(color)]).with(.byTruncatingTail)
        }
    }

    // MARK: - Layer
    private var textFieldLayer: TextFieldLayer? {
        layer as? TextFieldLayer
    }

    override public class var layerClass: AnyClass {
        TextFieldLayer.self
    }

    // MARK: Style
    private func compose() {
        switch inputFieldType {
        case .textInput:
            isSecureTextEntry = false
            addClearButton()
        case .search:
            isSecureTextEntry = false
            addLeftIcon()
            addClearButton()
        case .secureTextInput:
            isSecureTextEntry = true
            addShowPlainTextInputButton()
        }
    }

    private func addClearButton() {
        clearButton.addTarget(self, action: #selector(didTapClearButton), for: .touchUpInside)
        rightView = clearButton
        rightViewMode = .never
    }

    private func addLeftIcon() {
        leftView = iconImageView
        leftViewMode = .always
    }

    private func addShowPlainTextInputButton() {
        // TODO: Implement Design
    }

    private var clearButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(Asset.Icon.xCircleFilled.image, for: .normal)
        view.imageView?.contentMode = .center
        return view
    }()

    private let iconImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let image = Asset.Icon.search.image
        view.tintColor = .iconSecondary
        view.contentMode = .center
        view.constrainSize(image.size)
        view.image = image
        return view
    }()

    @objc private func didTapClearButton() {
        if delegate?.textFieldShouldClear?(self) ?? true {
            text = ""
            rightViewMode = .never
        }
    }

    // MARK: - Insets
    private var contentRectInset: UIEdgeInsets {
        if inputFieldType == .search {
            return UIEdgeInsets(top: -5.0, left: 35.0, bottom: 0.0, right: 10.0)
        }
        return UIEdgeInsets(top: -5.0, left: 10.0, bottom: 0.0, right: 10.0)
    }

    private var editingRect: UIEdgeInsets {
        if inputFieldType == .search {
            return UIEdgeInsets(top: -5.0, left: 35.0, bottom: 0.0, right: 40.0)
        }
        return UIEdgeInsets(top: -5.0, left: 10.0, bottom: 0.0, right: 40.0)
    }

    private var placeholderRectInset: UIEdgeInsets {
        if inputFieldType == .search {
            return UIEdgeInsets(top: 0.0, left: 35.0, bottom: 0.0, right: 40.0)
        }
        return UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 40.0)
    }

    override public func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: contentRectInset)
    }

    override public func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: placeholderRectInset)
    }

    override public func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: editingRect)
    }

    override public func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let buttonRectInset = UIEdgeInsets(top: 0.0, left: bounds.width - .spacing.xxl, bottom: 0.0, right: 0.0)
        return bounds.inset(by: buttonRectInset)
    }

    override public func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        let leftInset = -bounds.width + (iconImageView.image?.size.width ?? 0.0) + .spacing.s
        let buttonRectInset = UIEdgeInsets(top: 0.0, left: leftInset, bottom: 0.0, right: 0.0)
        return bounds.inset(by: buttonRectInset)
    }

    // MARK: - Validation
    @objc
    private func updateValidator(_ sender: AnyObject?) {
        if let input = text {
            if input.isEmpty {
                rightViewMode = .never
                isValidInput = true
            } else {
                isValidInput = validator?.validate(input: text) ?? true
                rightViewMode = .whileEditing
            }
        }
    }

    // MARK: - Responder Handling
    override public func becomeFirstResponder() -> Bool {
        willChangeValue(for: \.isFirstResponder)
        defer {
            didChangeValue(for: \.isFirstResponder)
        }
        componentState = .focused
        return super.becomeFirstResponder()
    }

    override public func resignFirstResponder() -> Bool {
        willChangeValue(for: \.isFirstResponder)
        defer {
            didChangeValue(for: \.isFirstResponder)
        }
        componentState = .normal
        return super.resignFirstResponder()
    }

    // MARK: - TraitCollectionChange
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        textFieldLayer?.userTraitDidChange(traitCollection: traitCollection)
    }
}

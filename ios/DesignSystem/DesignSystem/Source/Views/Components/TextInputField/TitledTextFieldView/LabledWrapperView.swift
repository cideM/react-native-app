//
//  LabledWrapperView.swift
//  DesignSystem
//
//  Created by Elmar Tampe on 29.11.23.
//

import UIKit

public protocol LabledWrapperViewDelegate: AnyObject {
    func willDisplayErrorView(isVisible: Bool)
}

public class LabeledWrapperView<InputField: UIView>: UIView, ValidationResultDelegate {

    public weak var delegate: LabledWrapperViewDelegate?

    // MARK: - Public
    public private(set) var inputTextField: InputField = {
        let view = InputField()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public var title: String = "" {
        didSet {
            titleLabel.attributedText = .attributedString(with: title,
                                                          style: .paragraphSmall,
                                                          decorations: [.color(.textSecondary)])
        }
    }

    // MARK: - Initialization
    public init() {
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        compose()
        addDelegateIfConformed()
        registerKVOObserver()
    }

    // MARK: - Composition
    private func compose() {
        addSubview(stackView)
        stackView.pin(to: self)

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(inputTextField)
        stackView.addArrangedSubview(errorView)
    }

    // MARK: - Private
    private var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var errorView: TextFieldErrorView = {
        let view = TextFieldErrorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = .spacing.xs
        stackView.clipsToBounds = false
        return stackView
    }()

    // MARK: - KVO
    private var inputFieldResponderObserver: NSKeyValueObservation?
    private func registerKVOObserver() {
        inputFieldResponderObserver = inputTextField.observe(\.isFirstResponder, options: .initial) { [weak self] inputField, _ in
            let color: UIColor = inputField.isFirstResponder ? .textPrimary : .textSecondary
            self?.titleLabel.attributedText = .attributedString(with: self?.title ?? "",
                                                                style: .paragraphSmall,
                                                                decorations: [.color(color)])
        }
    }

    // MARK: - Validation Delegation
    private func addDelegateIfConformed() {
        if let embeddedView = inputTextField as? TextInputField {
            embeddedView.validationDelegate = self
        }
    }

    func validationResultDidChange(_ isValid: Bool, message: String?) {
        errorView.title = message
        errorView.isHidden = isValid
        delegate?.willDisplayErrorView(isVisible: isValid)
    }
}

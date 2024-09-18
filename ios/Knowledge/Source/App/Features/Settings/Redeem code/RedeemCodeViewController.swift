//
//  RedeemCodeViewController.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 20.12.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import UIKit
import DesignSystem
import Localization

protocol RedeemCodeViewType: AnyObject {
    func setCode(_ code: String)
    func setLoading(_ isLoading: Bool)
    func setRedeemButtonTitle(_ text: String)
    func setCallout(message: String?, type: CalloutView.CalloutType?, animated: Bool)

}

class RedeemCodeViewController: UIViewController, RedeemCodeViewType {

    private let presenter: RedeemCodePresenterType

    private let baseView: RedeemCodeView = {
        let view = RedeemCodeView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init(presenter: RedeemCodePresenterType) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .canvas
        view.addSubview(baseView)

        NSLayoutConstraint.activate([
            baseView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            baseView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            baseView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            baseView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        ])

        baseView.delegate = self
        presenter.view = self
    }

    func setCode(_ code: String) {
        baseView.setTextFieldText(code)
    }

    func setLoading(_ isLoading: Bool) {
        baseView.setLoading(isLoading)
    }

    func setCallout(message: String?, type: CalloutView.CalloutType?, animated: Bool) {
        if let message, let type {
            baseView.setCallout(
                viewData: CalloutView.ViewData(
                    description: message,
                    calloutType: type),
                animated: animated)
        } else {
            baseView.setCallout(viewData: nil, animated: animated)
        }
    }

    func setRedeemButtonTitle(_ text: String) {
        baseView.setButtonTitle(text)
    }
}

extension RedeemCodeViewController: RedeemCodeViewDelegate {
    func didTapSupportButton() {
        presenter.helpButtonTapped()
    }

    func didTapRedeemButton() {
        presenter.redeemButtonTapped(code: self.baseView.textField.inputTextField.text ?? "")
    }

    func codeDidChange(_ code: String) {
        presenter.codeDidChange(code: code)
    }
}

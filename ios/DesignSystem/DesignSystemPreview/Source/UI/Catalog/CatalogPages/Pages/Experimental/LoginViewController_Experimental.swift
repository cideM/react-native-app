//
//  LoginViewController.swift
//  DesignSytemPreview
//
//  Created by Elmar Tampe on 14.12.23.
//

import UIKit
import DesignSystem

class LoginViewController_Experimental: UIViewController, LoginViewDelegate_Experimental {
    override func loadView() {
        let loginView = LoginViewDemo_Experimental()
        loginView.delegate = self
        view = loginView
    }
    
    func didTapRegistrationButton() {
        dismiss(animated: true)
    }
}

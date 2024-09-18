//
//  InitialLibraryInstantiationViewController.swift
//  Knowledge
//
//  Created by CSH on 17.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit
import Localization

protocol InitialLibraryInstantiationViewType: AnyObject { }

final class InitialLibraryInstantiationViewController: UIViewController, InitialLibraryInstantiationViewType {

    @IBOutlet private weak var initializationTextLabel: UILabel!

    private let presenter: InitialLibraryInstantiationPresenterType

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    init(presenter: InitialLibraryInstantiationPresenterType) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self

        initializationTextLabel.text = L10n.Initialization.label
        initializationTextLabel.font = Font.heavy.font(withSize: 22)
        initializationTextLabel.textColor = ThemeManager.currentTheme.initializationScreenTextColor
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

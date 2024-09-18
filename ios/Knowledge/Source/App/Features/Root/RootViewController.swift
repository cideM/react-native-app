//
//  RootViewController.swift
//  Knowledge
//
//  Created by Mohamed Abdul-Hameed on 9/23/19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit

protocol RootViewType: AnyObject {
    var selectedIndex: Int { get set }
}

final class RootViewController: UITabBarController, RootViewType {
    let presenter: RootPresenterType

    init(presenter: RootPresenterType) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self
    }
}

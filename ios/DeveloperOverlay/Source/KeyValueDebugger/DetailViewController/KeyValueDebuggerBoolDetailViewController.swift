//
//  KeyValueDebuggerBoolDetailViewController.swift
//  DeveloperOverlay
//
//  Created by CSH on 24.06.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit

class KeyValueDebuggerBoolDetailViewController: UIViewController {

    private var valueSwitch: UISwitch?

    private let value: Bool
    private let onChange: (Bool) -> Void

    init(key: String, value: Bool?, onChange: @escaping (Bool) -> Void) {
        self.value = value ?? false
        self.onChange = onChange
        super.init(nibName: nil, bundle: nil)
        self.title = key
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let valueSwitch = valueSwitch else { return }
        onChange(valueSwitch.isOn)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ThemeManager.currentTheme.textBackgroundColor
        let valueSwitch = UISwitch()
        self.valueSwitch = valueSwitch
        valueSwitch.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(valueSwitch)
        valueSwitch.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        valueSwitch.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        valueSwitch.isOn = value
    }

}

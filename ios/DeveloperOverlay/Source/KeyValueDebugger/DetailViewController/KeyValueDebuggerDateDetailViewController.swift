//
//  KeyValueDebuggerDateDetailViewController.swift
//  DeveloperOverlay
//
//  Created by Roberto Seidenberg on 03.02.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit

class KeyValueDebuggerDateDetailViewController: UIViewController {

    private var picker: UIDatePicker = {
        let view = UIDatePicker()
        view.datePickerMode = .dateAndTime
        return view
    }()

    private var value: Date?
    private let onChange: (Date) -> Void

    init(key: String, value: Date?, onChange: @escaping (Date) -> Void) {
        picker.date = value ?? Date()
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
        if let value = value { onChange(value) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ThemeManager.currentTheme.textBackgroundColor
        picker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(picker)
        picker.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        picker.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        picker.addTarget(self, action: #selector(valueChanged(sender:)), for: .valueChanged)
    }

    @objc func valueChanged(sender: UIDatePicker) {
        value = sender.date
    }
}

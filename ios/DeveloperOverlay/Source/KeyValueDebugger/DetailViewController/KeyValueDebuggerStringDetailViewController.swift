//
//  KeyValueDebuggerStringDetailViewController.swift
//  DeveloperOverlay
//
//  Created by CSH on 24.06.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit

class KeyValueDebuggerStringDetailViewController: UIViewController { // swiftlint:disable:this type_name

    private var textView: UITextView?

    private let value: String?
    private let onChange: (String) -> Void

    init(key: String, value: String?, onChange: @escaping (String) -> Void) {
        self.value = value
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
        guard let textView = textView else { return }
        onChange(textView.text)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ThemeManager.currentTheme.textBackgroundColor
        let textView = UITextView()
        self.textView = textView
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        textView.constrainEdges(to: view.layoutMarginsGuide)
        textView.text = value
    }

}

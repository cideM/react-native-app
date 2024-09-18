//
//  TabsControlViewController.swift
//  DesignSystem
//
//  Created by Roberto Seidenberg on 18.06.24.
//

import UIKit
import DesignSystem

class TabsControlViewController: UIViewController {

    private let titles: [String] = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        return Array(1...100).map {
            formatter.string(from: .init(value: $0))!.capitalized
        }
    }()

    private lazy var tabsControl: TabsControl = {
        let actions = titles.map { title in
                let attributedTitle = NSAttributedString(string: title, attributes: [:])
                return TabsControl.Action(title: attributedTitle, handler: { [weak self] _ in
                    self?.update(title: title)
                })
            }
        return TabsControl(frame: .init(origin: .zero, size: .init(width: 100, height: 100)), actions: actions)
    }()

    private let label = UILabel(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        update(title: titles.first!)
    }

    private func setUp() {
        view.backgroundColor = .canvas
        title = "TabsControl"

        view.addSubview(tabsControl)
        NSLayoutConstraint.activate([
            view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: tabsControl.topAnchor),
            view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: tabsControl.leadingAnchor),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: tabsControl.trailingAnchor),
            tabsControl.heightAnchor.constraint(equalToConstant: TabsControl.defaultHeight)
        ])

        view.addSubview(label)
        label.center(in: view)
    }

    private func update(title: String) {
        label.attributedText = .attributedString(with: title, style: .h3, decorations: [.color(.textSecondary)])
    }
}

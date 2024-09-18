//
//  SegementedControlSectionedViewController.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 26.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//
import Common
import UIKit

class SegementedControlSectionedViewController: UIViewController {

    private var viewController: UIViewController?
    private let segementedControl: UISegmentedControl

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        segementedControl = UISegmentedControl()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        navigationItem.titleView = segementedControl
        segementedControl.backgroundColor = .backgroundAccent
        segementedControl.setTitleTextAttributes([.foregroundColor: UIColor.iconOnAccent], for: .normal)
        segementedControl.selectedSegmentTintColor = ThemeManager.currentTheme.tintColor
        segementedControl.addTarget(self, action: #selector(segmentedControlValueDidChange), for: .valueChanged)
        segementedControl.heightAnchor.constraint(equalToConstant: 28).isActive = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var images: [UIImage] = [] {
        didSet {
            segementedControl.removeAllSegments()
            images.enumerated().forEach { index, image in
                segementedControl.insertSegment(with: image, at: index, animated: false)
            }
            segementedControl.widthAnchor.constraint(equalToConstant: CGFloat(images.count * 70)).isActive = true
            segementedControl.selectedSegmentIndex = 0
        }
    }

    var items: [String] = [] {
        didSet {
            segementedControl.removeAllSegments()
            items.enumerated().forEach { index, item in
                segementedControl.insertSegment(withTitle: item, at: index, animated: false)
            }
            segementedControl.widthAnchor.constraint(equalToConstant: CGFloat(items.count * 70)).isActive = true
        }
    }

    func set(_ viewController: UIViewController) {
        self.viewController?.willMove(toParent: nil)
        self.viewController?.removeFromParent()
        self.viewController?.view.removeFromSuperview()

        view.addSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.constrainEdges(to: view.safeAreaLayoutGuide)
        addChild(viewController)
        viewController.didMove(toParent: viewController)
        self.viewController = viewController
    }

    func setSelectedItem(_ index: Int) {
        segementedControl.selectedSegmentIndex = index
    }

    @objc
    private func segmentedControlValueDidChange() {
        didSelectItem(at: segementedControl.selectedSegmentIndex)
    }

    // This will be called whenever the segemented control is changed
    func didSelectItem(at index: Int) { }
}

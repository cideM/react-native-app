//
//  LibraryUpdateProgressViewController.swift
//  Knowledge
//
//  Created by Silvio Bulla on 15.01.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit
import Localization

protocol ForceLibraryUpdateViewType: AnyObject {
    func setUpdating(_ fractionCompleted: Double)
    func setInstalling()
    func setFailed(with error: LibraryUpdateError, actions: [MessageAction])
}

final class LibraryUpdateProgressViewController: UIViewController, ForceLibraryUpdateViewType {

    @IBOutlet private var headerImageView: UIImageView! {
        didSet {
            headerImageView.image = Asset.Image.coffeeCup.image
        }
    }

    @IBOutlet private var downloadingInstallingTitleLabel: UILabel! {
        didSet {
            downloadingInstallingTitleLabel.attributedText = NSMutableAttributedString(string: L10n.ForceLibraryUpdate.Updating.title, attributes: ThemeManager.currentTheme.titleTextAttributes)
        }
    }
    @IBOutlet private var downloadingInstallingSubtitleLabel: UILabel? {
        didSet {
            downloadingInstallingSubtitleLabel?.attributedText = NSMutableAttributedString(string: L10n.ForceLibraryUpdate.Updating.message, attributes: ThemeManager.currentTheme.welcomeViewSubtitleTextAttributes)
        }
    }

    @IBOutlet private var downloadingWrapperView: UIView!
    @IBOutlet private var downloadingProgressBar: UIProgressView!
    @IBOutlet private var downloadingLabel: UILabel! {
        didSet {
            downloadingLabel.attributedText = NSMutableAttributedString(string: L10n.ForceLibraryUpdate.Downloading.status, attributes: ThemeManager.currentTheme.textFieldTextAttributes)
        }
    }

    @IBOutlet private var installingWrapperView: UIView!
    @IBOutlet private var installingLabel: UILabel! {
        didSet {
            installingLabel.attributedText = NSMutableAttributedString(string: L10n.ForceLibraryUpdate.Installing.status, attributes: ThemeManager.currentTheme.textFieldTextAttributes)
        }
    }

    private let presenter: LibraryUpdateProgressPresenterType
    private var subviewMessagePresenter: SubviewMessagePresenter?

    init(presenter: LibraryUpdateProgressPresenterType) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        subviewMessagePresenter = SubviewMessagePresenter(rootView: view)
        presenter.view = self
    }

    func setUpdating(_ fractionCompleted: Double) {
        downloadingWrapperView.isHidden = false
        installingWrapperView.isHidden = true
        downloadingProgressBar.progress = Float(fractionCompleted)
    }

    func setInstalling() {
        downloadingWrapperView.isHidden = true
        installingWrapperView.isHidden = false
    }

    func setFailed(with error: LibraryUpdateError, actions: [MessageAction]) {
        subviewMessagePresenter?.present(error, actions: actions)
    }
}

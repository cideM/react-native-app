//
//  LibrariesSettingsTableViewController.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 17.10.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit
import Localization

/// @mockable
protocol LibrariesSettingsViewType: AnyObject {
    func setState(_ state: LibrariesSettingsStateViewData)
    func setIsLibraryAutoUpdateEnabled(_ isAutoUpdateEnabled: Bool)
    func setIsPharmaAutoUpdateEnabled(_ isAutoUpdateEnabled: Bool)
    func removePharmaData()
    func setPharmaDatabaseDeletable(_ isDeletable: Bool)
    func presentMessage(_ message: PresentableMessageType, actions: [MessageAction])
}

final class LibrariesSettingsTableViewController: UITableViewController, StoryboardIdentifiable {

    @IBOutlet private weak var libraryTitleLabel: UILabel!
    @IBOutlet private weak var librarySubtitleLabel: UILabel!
    @IBOutlet private weak var libraryUpdateButton: BigButton!

    @IBOutlet private weak var pharmaTableViewCell: UITableViewCell!
    @IBOutlet private weak var pharmaTitleLabel: UILabel!
    @IBOutlet private weak var pharmaSubtitleLabel: UILabel!
    @IBOutlet private weak var pharmaUpdateButton: BigButton!
    @IBOutlet private weak var deletePharmaLabel: UILabel!

    @IBOutlet private weak var automaticUpdatesTitleLabel: UILabel!
    @IBOutlet private weak var automaticUpdatesSubtitleLabel: UILabel!
    @IBOutlet private weak var pharmaAutoUpdateStackView: UIStackView!
    @IBOutlet private weak var libraryWifiAutoUpdateLabel: UILabel!
    @IBOutlet private weak var libraryWifiAutoUpdateSwitch: UISwitch!

    @IBOutlet private weak var pharmaWifiAutoUpdateLabel: UILabel!
    @IBOutlet private weak var pharmaWifiAutoUpdateSwitch: UISwitch!

    @IBOutlet private weak var pharmaCellDeletionInfoLabel: UILabel! {
        didSet {
            pharmaCellDeletionInfoLabel.isHidden = true
        }
    }

    private var presenter: LibrariesSettingsPresenterType! // swiftlint:disable:this implicitly_unwrapped_optional

    private var isPharmaDatabaseDeletable = false {
        didSet {
            pharmaCellDeletionInfoLabel.isHidden = !isPharmaDatabaseDeletable
            tableView.reloadData()
        }
    }

    static func viewController(with presenter: LibrariesSettingsPresenterType) -> LibrariesSettingsTableViewController {
        let storyboard = UIStoryboard(name: "LibrariesSettings", bundle: nil)
        let librarySettingsTableViewController = storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as! LibrariesSettingsTableViewController // swiftlint:disable:this force_cast
        librarySettingsTableViewController.presenter = presenter
        return librarySettingsTableViewController
    }

    @IBAction private func updateLibraryButtonHandler(_ sender: UIButton) {
        presenter.updateLibrary()
    }

    @IBAction private func updatePharmaButtonHandler(_ sender: UIButton) {
        presenter.updatePharma()
    }

    @IBAction private func didChangeWifiUpdate(_ sender: UISwitch) {
        presenter.didChangeIsAutoUpdateEnabled(sender.isOn)
    }

    @IBAction private func didChangePharmaWifiUpdate(_ sender: UISwitch) {
        presenter.didChangePharmaIsAutoUpdateEnabled(sender.isOn)
    }

    /// Private init to protect the view from  crashing as we need to initilise presenter: instead viewController(with presenter: LibrarySettingsPresenterType) should be called
    override private init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self
        setupView()
    }

    private func setupView() {
        libraryWifiAutoUpdateSwitch.onTintColor = .backgroundAccent
        pharmaWifiAutoUpdateSwitch.onTintColor = .backgroundAccent
        title = L10n.LibrarySettings.update
        navigationItem.largeTitleDisplayMode = .never

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100.0
        tableView.backgroundColor = ThemeManager.currentTheme.backgroundColor
        tableView.tableFooterView = UIView()

        libraryTitleLabel.attributedText = NSAttributedString(string: L10n.LibrarySettings.Library.title, attributes: ThemeManager.currentTheme.settingsLibraryAndPharmaTitleTextAttributes)
        pharmaTitleLabel.attributedText = NSAttributedString(string: L10n.LibrarySettings.Pharma.title, attributes: ThemeManager.currentTheme.settingsLibraryAndPharmaTitleTextAttributes)
        deletePharmaLabel.attributedText = NSAttributedString(string: L10n.LibrarySettings.Pharma.DeleteDisclaimer.title, attributes: ThemeManager.currentTheme.settingsLibraryAndPharmaDeleteDisclaimerTextAttributes)

        automaticUpdatesTitleLabel.attributedText = NSAttributedString(string: L10n.LibrarySettings.AutomaticUpdates.title, attributes: ThemeManager.currentTheme.settingsLibraryAndPharmaTitleTextAttributes)
        if !L10n.LibrarySettings.AutomaticUpdates.subtitle.isEmpty {
            automaticUpdatesSubtitleLabel.attributedText = NSAttributedString(string: L10n.LibrarySettings.AutomaticUpdates.subtitle, attributes: ThemeManager.currentTheme.settingsLibraryAndPharmaSubtitleTextAttributes)
        } else {
            automaticUpdatesSubtitleLabel.isHidden = true
        }
        libraryWifiAutoUpdateLabel.attributedText = NSAttributedString(string: L10n.LibrarySettings.LibraryUpdate.title, attributes: ThemeManager.currentTheme.settingsLibraryAndPharmaNormalTextAttributes)
        pharmaWifiAutoUpdateLabel.attributedText = NSAttributedString(string: L10n.LibrarySettings.PharmaUpdate.title, attributes: ThemeManager.currentTheme.settingsLibraryAndPharmaNormalTextAttributes)

        libraryUpdateButton.setTitle(L10n.LibrarySettings.UpdateButton.title, for: [])
        pharmaUpdateButton.setTitle(L10n.LibrarySettings.UpdateButton.title, for: [])
        [libraryUpdateButton, pharmaUpdateButton].forEach {
            $0?.style = .linkWithBorders
            $0?.setTitleColor(ThemeManager.currentTheme.tintColor, for: [])
            $0?.layer.borderColor = ThemeManager.currentTheme.tintColor.cgColor
            $0?.sizeToFit()
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if pharmaTableViewCell.isHidden, indexPath.row == 1 { return 0 }
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 30 }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? { UIView() }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        guard isPharmaDatabaseDeletable, indexPath == IndexPath(item: 1, section: 0) else { return .none }
        return .delete
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        presenter.presentDeletePharmaDatabaseAlert()
    }

    func presentMessage(_ message: PresentableMessageType, actions: [MessageAction]) {
        UIAlertMessagePresenter(presentingViewController: self).present(message, actions: actions)
    }
}

extension LibrariesSettingsTableViewController: LibrariesSettingsViewType {

    func setState(_ state: LibrariesSettingsStateViewData) {
        assert(Thread.isMainThread)
        switch state {
        case .library(.checking):
            setLibraryChecking()
        case .library(.upToDate):
            setLibraryUpToDate()
        case .library(.downloading(let progress)):
            setLibraryDownloading(fractionCompleted: progress)
        case .library(.installing):
            setLibraryInstalling()
        case .library(.outdated(let updateByteSize, _)):
            setLibraryOutdated(updateByteSize: updateByteSize)
        case .library(.failed(let updateByteSize, let title, let message)):
            setLibraryUpdateFailed(updateByteSize: updateByteSize, title: title, message: message)

        case .pharma(.checking):
            setPharmaChecking()
        case .pharma(.upToDate):
            setPharmaUpToDate()
        case .pharma(.downloading(let progress)):
            setPharmaDownloading(fractionCompleted: progress)
        case .pharma(.installing):
            setPharmaInstalling()
        case .pharma(.outdated(let updateBytesSize, let isPharmaDatabaseAlreadyInstalled)):
            setPharmaOutdated(updateByteSize: updateBytesSize, isPharmaDatabaseAlreadyInstalled: isPharmaDatabaseAlreadyInstalled)
        case .pharma(.failed(let updateByteSize, let title, let message)):
            setPharmaUpdateFailed(updateByteSize: updateByteSize, title: title, message: message)
        }
    }

    func setIsLibraryAutoUpdateEnabled(_ isAutoUpdateEnabled: Bool) {
        libraryWifiAutoUpdateSwitch.setOn(isAutoUpdateEnabled, animated: true)
    }

    func setIsPharmaAutoUpdateEnabled(_ isAutoUpdateEnabled: Bool) {
        pharmaWifiAutoUpdateSwitch.setOn(isAutoUpdateEnabled, animated: true)
    }

    func removePharmaData() {
        pharmaTableViewCell.isHidden = true
        pharmaAutoUpdateStackView.isHidden = true
    }

    func setPharmaDatabaseDeletable(_ isDeletable: Bool) {
        // This is called constantly during download of a db and updating "isPharmaDatabaseDeletable" causes the tableview to reload
        // Hence only update the property it in case the value actually changed
        if isDeletable != isPharmaDatabaseDeletable {
            isPharmaDatabaseDeletable = isDeletable
        }
    }
}

private extension LibrariesSettingsTableViewController {

    func setLibraryChecking() {
        librarySubtitleLabel.attributedText = NSAttributedString(string: L10n.LibrarySettings.checkingForUpdateMessage, attributes: ThemeManager.currentTheme.settingsLibraryAndPharmaSubtitleTextAttributes)
        libraryUpdateButton.isHidden = true
    }

    func setLibraryDownloading(fractionCompleted: Double) {
        let progressInPercentage = String(format: "%1.0f%%", arguments: [fractionCompleted * Double(100)])
        librarySubtitleLabel.attributedText = NSAttributedString(string: L10n.LibrarySettings.Library.Subtitle.downloading(progressInPercentage), attributes: ThemeManager.currentTheme.settingsLibraryAndPharmaSubtitleTextAttributes)
        libraryUpdateButton.isHidden = true
    }

    func setLibraryInstalling() {
        librarySubtitleLabel.attributedText = NSAttributedString(string: L10n.LibrarySettings.Library.Subtitle.installing, attributes: ThemeManager.currentTheme.settingsLibraryAndPharmaSubtitleTextAttributes)
        libraryUpdateButton.isHidden = true
    }

    func setLibraryUpdateFailed(updateByteSize: Int?, title: String, message: String) {
        setLibraryUpdateAvailable(updateByteSize: updateByteSize)

        let errorBody = NSMutableAttributedString(string: title + "\n", attributes: ThemeManager.currentTheme.settingsDestructiveButtonTextAttributes)
        errorBody.append(NSAttributedString(string: message, attributes: ThemeManager.currentTheme.footerViewTextAttributes))
        librarySubtitleLabel.attributedText = errorBody
    }

    func setLibraryUpToDate() {
        librarySubtitleLabel.attributedText = NSAttributedString(string: L10n.LibrarySettings.upToDateMessage, attributes: ThemeManager.currentTheme.settingsLibraryAndPharmaSubtitleTextAttributes)
        libraryUpdateButton.isHidden = true
    }

    func setLibraryOutdated(updateByteSize: Int?) {
        setLibraryUpdateAvailable(updateByteSize: updateByteSize)
    }

    func setLibraryUpdateAvailable(updateByteSize: Int?) {
        let formatter = ByteCountFormatter()
        if let updateByteSize = updateByteSize {
            let sizeInMbs = formatter.string(fromByteCount: Int64(updateByteSize))
            librarySubtitleLabel.attributedText = NSAttributedString(string: L10n.LibrarySettings.updateAvailableMessage + " - " + sizeInMbs, attributes: ThemeManager.currentTheme.settingsLibraryAndPharmaSubtitleTextAttributes)
        } else {
            librarySubtitleLabel.attributedText = NSAttributedString(string: L10n.LibrarySettings.updateAvailableMessage, attributes: ThemeManager.currentTheme.settingsLibraryAndPharmaSubtitleTextAttributes)
        }
        libraryUpdateButton.isHidden = false
    }
}

private extension LibrariesSettingsTableViewController {

    func setPharmaChecking() {
        pharmaSubtitleLabel.attributedText = NSAttributedString(string: L10n.LibrarySettings.checkingForUpdateMessage, attributes: ThemeManager.currentTheme.settingsLibraryAndPharmaSubtitleTextAttributes)
        pharmaUpdateButton.isHidden = true
        tableView.reloadData() // -> Doing this in order to force enable/disable "swipe to delete"
    }

    func setPharmaDownloading(fractionCompleted: Double) {
        let progressInPercentage = String(format: "%1.0f%%", arguments: [fractionCompleted * Double(100)])
        pharmaSubtitleLabel.attributedText = NSAttributedString(string: L10n.LibrarySettings.Library.Subtitle.downloading(progressInPercentage), attributes: ThemeManager.currentTheme.settingsLibraryAndPharmaSubtitleTextAttributes)
        pharmaUpdateButton.isHidden = true
    }

    func setPharmaInstalling() {
        pharmaSubtitleLabel.attributedText = NSAttributedString(string: L10n.LibrarySettings.Library.Subtitle.installing, attributes: ThemeManager.currentTheme.settingsLibraryAndPharmaSubtitleTextAttributes)
        pharmaUpdateButton.isHidden = true
        tableView.reloadData() // -> Doing this in order to force enable/disable "swipe to delete"
    }

    func setPharmaUpdateFailed(updateByteSize: Int?, title: String, message: String, isPharmaDatabaseAlreadyInstalled: Bool = true) {
        setPharmaUpdateAvailable(updateByteSize: updateByteSize, isPharmaDatabaseAlreadyInstalled: isPharmaDatabaseAlreadyInstalled)

        let errorBody = NSMutableAttributedString(string: title + "\n", attributes: ThemeManager.currentTheme.settingsDestructiveButtonTextAttributes)
        errorBody.append(NSAttributedString(string: message, attributes: ThemeManager.currentTheme.footerViewTextAttributes))
        pharmaSubtitleLabel.attributedText = errorBody
        tableView.reloadData() // -> Doing this in order to force enable/disable "swipe to delete"
    }

    func setPharmaUpToDate() {
        pharmaSubtitleLabel.attributedText = NSAttributedString(string: L10n.LibrarySettings.upToDateMessage, attributes: ThemeManager.currentTheme.settingsLibraryAndPharmaSubtitleTextAttributes)
        pharmaUpdateButton.isHidden = true
        tableView.reloadData() // -> Doing this in order to force enable/disable "swipe to delete"
    }

    func setPharmaOutdated(updateByteSize: Int?, isPharmaDatabaseAlreadyInstalled: Bool?) {
        setPharmaUpdateAvailable(updateByteSize: updateByteSize, isPharmaDatabaseAlreadyInstalled: isPharmaDatabaseAlreadyInstalled)
    }

    func setPharmaUpdateAvailable(updateByteSize: Int?, isPharmaDatabaseAlreadyInstalled: Bool?) {
        let formatter = ByteCountFormatter()
        if let updateByteSize = updateByteSize, let updateByteSize64 = Int64(exactly: updateByteSize) {
            let sizeInMbs = formatter.string(fromByteCount: updateByteSize64)
            pharmaSubtitleLabel.attributedText = NSAttributedString(string: L10n.LibrarySettings.updateAvailableMessage + " - " + sizeInMbs, attributes: ThemeManager.currentTheme.settingsLibraryAndPharmaSubtitleTextAttributes)
        } else {
            pharmaSubtitleLabel.attributedText = NSAttributedString(string: L10n.LibrarySettings.updateAvailableMessage, attributes: ThemeManager.currentTheme.settingsLibraryAndPharmaSubtitleTextAttributes)
        }

        pharmaUpdateButton.isHidden = false
        if let isPharmaDatabaseAlreadyInstalled = isPharmaDatabaseAlreadyInstalled, isPharmaDatabaseAlreadyInstalled {
            pharmaUpdateButton.setTitle(L10n.LibrarySettings.UpdateButton.title, for: [])
        } else {
            pharmaUpdateButton.setTitle(L10n.LibrarySettings.InstallButton.title, for: [])
        }

        tableView.reloadData() // -> Doing this in order to force enable/disable "swipe to delete"
    }
}

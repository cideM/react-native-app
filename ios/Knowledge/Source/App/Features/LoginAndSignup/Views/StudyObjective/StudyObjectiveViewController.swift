//
//  StudyObjectiveTableViewController.swift
//  Knowledge
//
//  Created by Silvio Bulla on 16.10.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit
import Localization

/// @mockable
protocol StudyObjectiveViewType: AnyObject {
    func setStudyObjectives(_ studyObjectives: [StudyObjective])
    func setCurrentStudyObjective(withId id: String)
    func setIsSyncing(_ isSyncing: Bool)
    func presentStudyObjectiveSubviewError(_ error: PresentableMessageType)
    func presentStudyObjectiveAlertError(_ error: PresentableMessageType)
    func setBottomButtonIsEnabled(_ isEnabled: Bool)
    func setBottomButtonTitle(_ title: String)
}

final class StudyObjectiveViewController: UIViewController, StudyObjectiveViewType {

    private let presenter: StudyObjectivePresenterType
    private var dataSource = StudyObjectiveDataSource(studyObjectives: [])

    init(presenter: StudyObjectivePresenterType) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.rowHeight = UITableView.automaticDimension
        view.sectionFooterHeight = UITableView.automaticDimension
        view.estimatedSectionFooterHeight = 50
        view.backgroundColor = .canvas
        view.delegate = self
        return view
    }()

    private lazy var bottomButton: BigButton = {
        let button = BigButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.style = .primary
        button.isEnabled = false
        button.touchUpInsideActionClosure = { [weak self] in
            self?.presenter.bottomButtonTapped()
        }
        return button
    }()

    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.style = .medium
        view.hidesWhenStopped = true
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self

        title = L10n.StudyObjective.title
        view.backgroundColor = .canvas
        dataSource.setupTableView(tableView)

        setupView()
    }

    private func setupView() {
        view.backgroundColor = .canvas

        let bottomView = UIView()
        bottomView.backgroundColor = .canvas
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomView)
        NSLayoutConstraint.activate([
            bottomView.leftAnchor.constraint(equalTo: view.leftAnchor),
            bottomView.rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 64)
        ])

        bottomView.layer.shadowColor = UIColor.black.cgColor
        bottomView.layer.shadowOffset = CGSize(width: 0, height: -10)
        bottomView.layer.shadowRadius = 3
        bottomView.layer.shadowOpacity = 0.1
        bottomView.layer.masksToBounds = false

        bottomView.addSubview(bottomButton)
        NSLayoutConstraint.activate([
            bottomButton.leftAnchor.constraint(equalTo: bottomView.leftAnchor, constant: 16),
            bottomButton.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 8),
            bottomButton.rightAnchor.constraint(equalTo: bottomView.rightAnchor, constant: -16),
            bottomButton.heightAnchor.constraint(equalToConstant: 48)
        ])

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomView.topAnchor, constant: -1)
        ])

        tableView.addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
    }

    func setStudyObjectives(_ studyObjectives: [StudyObjective]) {
        dataSource = StudyObjectiveDataSource(studyObjectives: studyObjectives)
        tableView.dataSource = dataSource
        tableView.reloadData()
    }

    func setCurrentStudyObjective(withId id: String) {
        guard let index = dataSource.indexOfStudyObjectiveWithId(id) else { return }
        tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .none)
    }

    func setIsSyncing(_ isSyncing: Bool) {
        isSyncing ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating()
    }

    func presentStudyObjectiveSubviewError(_ error: PresentableMessageType) {
        let subviewErrorPresenter = SubviewMessagePresenter(rootView: view)
        let retryErrorAction = MessageAction(title: L10n.Generic.retry, style: .normal) { () -> Bool in
            self.presenter.getAvailableStudyObjectives()
            return true
        }
        subviewErrorPresenter.present(error, actions: [retryErrorAction])
    }

    func presentStudyObjectiveAlertError(_ error: PresentableMessageType) {
        let errorPresenter = UIAlertMessagePresenter(presentingViewController: self)
        errorPresenter.present(error, actions: [.dismiss])
    }

    func setBottomButtonIsEnabled(_ isEnabled: Bool) {
        bottomButton.isEnabled = isEnabled
    }

    func setBottomButtonTitle(_ title: String) {
        bottomButton.setTitle(title, for: [])
    }
}

extension StudyObjectiveViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = NSAttributedString(string: L10n.StudyObjective.header, attributes: ThemeManager.currentTheme.headerTextAttributes)

        let view = UIView()
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8.5)
        ])

        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        56
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = TableViewFooterView()
        footerView.set(text: L10n.StudyObjective.info)
        return (dataSource.studyObjectiveAtIndex(section) != nil) ? footerView : nil
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let studyObjective = dataSource.studyObjectiveAtIndex(indexPath.row) else { return }
        presenter.selectedStudyObjectiveDidChange(studyObjective: studyObjective)
    }
}

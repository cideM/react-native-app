//
//  SearchViewController.swift
//  Knowledge
//
//  Created by Silvio Bulla on 23.06.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import DesignSystem
import UIKit
import Localization

/// @mockable
protocol SearchViewType: AnyObject {
    func showSections(_ sections: [SearchResultSection], searchTerm: String, scope: SearchScope?)
    func showSectionsScrolledToTop(_ sections: [SearchResultSection], searchTerm: String, scope: SearchScope?)
    func showIsLoading(_ isLoading: Bool)
    func scrollToSelectedMediaFilter()

    func setSearchTextFieldText(_ text: String)
    func hideKeyboard()

    func showAvailableSearchScopes(_ searchScopes: [SearchScope])
    func changeSelectedScope(_ selectedScope: SearchScope)

    func showDisclaimerDialog(completion: @escaping (Bool) -> Void)

    func showOfflineHint(retryAction: @escaping () -> Void)
    func hideOfflineHint()

    func showDidYouMeanViewIfNeeded(searchTerm: String, didYouMean: String?)
    func hideDidYouMeanView()

    func showNoResultView()
    func hideNoResultView()

    func setUserActivity(_ userActivity: NSUserActivity)
    func presentMessage(_ message: PresentableMessageType, actions: [MessageAction])
}

final class SearchViewController: UIViewController, SearchViewType {
    private let presenter: SearchPresenterType
    private var searchScopes: [SearchScope]?
    private var segmentedControlHeightConstraint: NSLayoutConstraint?
    private static let paginationThreshold = 5
    private var shouldScrollToSelectedFilter = false

    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchTextField.clearButtonMode = .whileEditing
        searchBar.showsCancelButton = true
        let attributedPlaceholder = NSAttributedString(string: L10n.Search.placeholder,
                                                       attributes: ThemeManager.currentTheme.searchTextFieldPlaceholderTextAttributes)
        searchBar.styled(with: attributedPlaceholder,
                         image: Asset.Icon.search.image,
                         backgroundColor: .backgroundPrimary,
                         tintColor: .iconOnAccent,
                         barTintColor: .backgroundAccentSubtle,
                         imageTintColor: .iconSecondary)
        searchBar.delegate = self
        searchBar.searchTextField.delegate = self
        return searchBar
    }()

    private lazy var segmentedControl: TabsControl = {
        let segmentedControl = TabsControl()
        segmentedControl.backgroundColor = .canvas
        return segmentedControl
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1)) // Remove the last separator
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 44
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.insetsContentViewsToSafeArea = false
        tableView.backgroundColor = .canvas
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 34, right: 0)

        return tableView
    }()

    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 24
        layout.sectionHeadersPinToVisibleBounds = true
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.backgroundColor = .backgroundPrimary
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()

    private lazy var didYouMeanView: DidYouMeanView = {
        DidYouMeanView { [weak self] searchTerm, didYouMean in
            self?.presenter.didYouMeanResultTapped(searchTerm: searchTerm, didYouMean: didYouMean)
        }
    }()

    private lazy var offlineModeView: OfflineModeView = {
        OfflineModeView()
    }()

    private lazy var noResultView: SearchNoResultView = {
        SearchNoResultView(buttonAction: presenter.contactUsButtonTapped)
    }()

    private lazy var informationStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()

    private var tableViewDataSource: SearchResultsDatasource? {
        didSet {
            tableViewDataSource?.setup(in: tableView)
            tableView.dataSource = tableViewDataSource
            tableView.reloadData()
        }
    }

    private var collectionViewDataSource: SearchResultsDatasource? {
        didSet {
            collectionViewDataSource?.setup(in: collectionView)
            collectionView.dataSource = collectionViewDataSource
            collectionView.reloadData()
        }
    }

    private lazy var loadingOverlayView: ActivityIndicatorView = {
        ActivityIndicatorView()
    }()

    init(presenter: SearchPresenterType) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)

        view.backgroundColor = .backgroundAccent
        extendedLayoutIncludesOpaqueBars = true

        view.addSubview(searchBar)

        view.addSubview(informationStackView)
        view.addSubview(segmentedControl)
        view.addSubview(collectionView)
        view.addSubview(tableView)
        tableView.addSubview(loadingOverlayView)

        informationStackView.translatesAutoresizingMaskIntoConstraints = false
        setupInformationStackViewConstraints()

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        setupSearchBarConstraints()

        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        setupSegmentedControlConstraints()

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        setupCollectionviewConstraints()

        tableView.translatesAutoresizingMaskIntoConstraints = false
        setupTableViewConstraints()

        searchBar.becomeFirstResponder()

        presenter.view = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let headerView = tableView.tableHeaderView {
            let fittingSize = CGSize(width: tableView.bounds.width, height: 44)
            let size = headerView.systemLayoutSizeFitting(fittingSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            let headerViewFrame = CGRect(origin: .zero, size: size)

            if headerView.frame != headerViewFrame {
                headerView.frame = headerViewFrame
                tableView.tableHeaderView = headerView
            }
        }

        if let footerView = tableView.tableFooterView {
            let fittingSize = CGSize(width: tableView.bounds.width, height: 44)
            let size = footerView.systemLayoutSizeFitting(fittingSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            let footerViewFrame = CGRect(origin: .zero, size: size)

            if footerView.frame != footerViewFrame {
                footerView.frame = footerViewFrame
                tableView.tableFooterView = footerView
            }
        }
        calculateItemSizeOftheCollectionView()
    }

    private func setupSearchBarConstraints() {
        let layoutGuide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            searchBar.leftAnchor.constraint(equalTo: layoutGuide.leftAnchor),
            searchBar.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
            searchBar.rightAnchor.constraint(equalTo: layoutGuide.rightAnchor)
        ])
    }

    private func setupNoResultViewConstraints() {
        NSLayoutConstraint.activate([
            noResultView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            noResultView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            noResultView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            noResultView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupInformationStackViewConstraints() {
        NSLayoutConstraint.activate([
            informationStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            informationStackView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            informationStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupSegmentedControlConstraints() {
        let segmentedControlHeightConstraint = segmentedControl.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: informationStackView.bottomAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            segmentedControlHeightConstraint
        ])
        self.segmentedControlHeightConstraint = segmentedControlHeightConstraint
    }

    private func setupCollectionviewConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupTableViewConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func setSearchTextFieldText(_ text: String) {
        searchBar.text = text
    }

    func hideKeyboard() {
        searchBar.endEditing(false)
    }

    private func headerView(with attributedString: NSAttributedString) -> UIView {
        SimpleTableHeaderFooterView(attributedText: attributedString)
    }

    private func footerView(message: String, action: @escaping () -> Void) -> UIView {
        let attributedText = NSAttributedString(string: message, attributes: ThemeManager.currentTheme.footerViewTextAttributes)
        let view = SimpleTableHeaderFooterView(attributedText: attributedText, action: action)
        view.label.textAlignment = .center
        return view
    }

    // MARK: State transition

    func showSectionsScrolledToTop(_ sections: [SearchResultSection], searchTerm: String, scope: SearchScope?) {
        showSections(sections, searchTerm: searchTerm, scope: scope)
        if let scope = scope {
            scrollToTop(scope)
        }
    }

    func showSections(_ sections: [SearchResultSection], searchTerm: String, scope: SearchScope?) {
        switch scope {
        case .media:
            showCollectionView()
            hideTableView()
            collectionViewDataSource = SearchResultsDatasource(searchTerm: searchTerm, sections: sections, delegate: self)
        default:
            showTableView()
            hideCollectionView()
            tableViewDataSource = SearchResultsDatasource(searchTerm: searchTerm, sections: sections, delegate: self)
        }

    }

    func scrollToSelectedMediaFilter() {

        if let mediaFiltersView = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) as? SearchResultsMediaSectionHeaderView {

            mediaFiltersView.scrollToSelected()
        } else {
            self.shouldScrollToSelectedFilter = true
        }
    }

    func showIsLoading(_ isLoading: Bool) {
        isLoading ? loadingOverlayView.show() : loadingOverlayView.hide()
    }

    func showAvailableSearchScopes(_ searchScopes: [SearchScope]) {
        if searchScopes.isEmpty {
            self.searchScopes = nil
            segmentedControl.selectSegment(at: 0, isAnimated: false)
            segmentedControlHeightConstraint?.constant = 0
        } else {
            self.searchScopes = searchScopes

            let actions = searchScopes.map { TabsControl.Action(title: $0.title) { [weak self] selectedIndex in
                self?.segmentedControlSelectedSegmentChanged(selectedIndex)
            }
            }
            segmentedControl.setActions(actions)
            segmentedControlHeightConstraint?.constant = TabsControl.defaultHeight
        }
    }

    func changeSelectedScope(_ selectedScope: SearchScope) {
        if let selectedScopeIndex = searchScopes?.firstIndex(where: {
            $0.isSameCase(selectedScope)
        }) {
            segmentedControl.selectSegment(at: selectedScopeIndex, isAnimated: false)
        }
    }

    func showDisclaimerDialog(completion: @escaping (Bool) -> Void) {
        UIAlertMessagePresenter.presentHealthcareDisclaimer(in: self, didAgree: completion)
    }

    func showOfflineHint(retryAction: @escaping () -> Void) {
        hideDidYouMeanView()
        offlineModeView.setAction(retryAction)
        informationStackView.addArrangedSubview(offlineModeView)
    }

    func hideOfflineHint() {
        offlineModeView.removeFromSuperview()
    }

    func showDidYouMeanViewIfNeeded(searchTerm: String, didYouMean: String?) {
        if let didYouMean = didYouMean {
            offlineModeView.removeFromSuperview()
            didYouMeanView.set(searchTerm: searchTerm, didYouMean: didYouMean)
            informationStackView.addArrangedSubview(didYouMeanView)
        } else {
            tableView.tableHeaderView = UIView()
            hideDidYouMeanView()
        }
    }

    func hideDidYouMeanView() {
        didYouMeanView.removeFromSuperview()
    }

    func showNoResultView() {
        view.addSubview(noResultView)
        noResultView.translatesAutoresizingMaskIntoConstraints = false
        setupNoResultViewConstraints()
    }

    func hideNoResultView() {
        noResultView.removeFromSuperview()
    }

    func showCollectionView() {
        collectionView.isHidden = false
    }

    func hideCollectionView() {
        collectionView.isHidden = true
    }

    func showTableView() {
        tableView.isHidden = false
    }

    func hideTableView() {
        tableView.isHidden = true
    }

    private func calculateItemSizeOftheCollectionView() {
        /* This function is calculating the item size in the collectionView in a dynamic way.
            The calculation depends on these rules:
                - At least there should be 2 columns,
                - items should have a minimum width,
                - there can be may rows as the items fits with the static minimum width,
                - paddings and spacings should have a static value
                - item images should have aspect ratio as 1
         */

        let minimumItemWidth: CGFloat = 136  // Minimum item width is calculated depending on the oldest and smallest device which has the 320 px width.
        let collectionViewWidth = collectionView.frame.width
        var width: CGFloat = 0

        for columns in 2..<20 {
            let availableContentSpace = (collectionViewWidth - collectionView.safeAreaInsets.left - collectionView.safeAreaInsets.right - layout.sectionInset.left - layout.sectionInset.right - collectionView.adjustedContentInset.left - collectionView.adjustedContentInset.right - CGFloat((columns - 1)) * layout.minimumInteritemSpacing)
            let widthCandidate = availableContentSpace / CGFloat(columns)
            if widthCandidate >= minimumItemWidth || width == 0 {
                width = widthCandidate
            } else {
                break
            }
        }
        let heightOfTheTitleLabels: CGFloat = 72
        layout.itemSize = CGSize(width: width, height: width + heightOfTheTitleLabels)

        collectionView.layoutIfNeeded()
    }

    func setUserActivity(_ userActivity: NSUserActivity) {
        self.userActivity = userActivity
        userActivity.becomeCurrent()
    }

    func presentMessage(_ message: PresentableMessageType, actions: [MessageAction]) {
        UIAlertMessagePresenter(presentingViewController: self).present(message, actions: actions)
    }

    @objc private func searchBarClearButtonTapped() {
        presenter.searchBarClearButtonTapped()
    }

    private func scrollToTop(_ scope: SearchScope) {
        switch scope {
        case .media:
            guard let dataSource = collectionViewDataSource, !dataSource.sections.isEmpty else { return }
            collectionView.setContentOffset(CGPoint.zero, animated: false)
        default:
            // WORKAROUND: We want to scroll the table view to top on reload
            guard let dataSource = tableViewDataSource, !dataSource.sections.isEmpty else { return }
            let indexPath = IndexPath(row: NSNotFound, section: 0)
            tableView.scrollToRow(at: indexPath, at: .none, animated: false)
        }
    }

    private func segmentedControlSelectedSegmentChanged(_ selectedIndex: Int) {
        if let newScope = self.searchScopes?[selectedIndex] {
            self.presenter.didTapScope(newScope, query: self.searchBar.text ?? "")
        }
    }
}

extension SearchViewController: UISearchBarDelegate {

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        presenter.dismissView(query: searchBar.text ?? "")
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.searchBarTextDidChange(query: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        presenter.searchBarSearchButtonTapped(query: searchBar.text ?? "")
    }
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        // WORKAROUND: Enable cancel button whenever the search bar resigns first responder
        DispatchQueue.main.async {
            if let cancelButton: UIButton = searchBar.value(forKey: "cancelButton") as? UIButton {
                cancelButton.isEnabled = true
            }
        }
        return true
    }
}

extension SearchViewController: UITextFieldDelegate {
    // unused:ignore textFieldShouldClear
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        presenter.searchBarClearButtonTapped()
        return true
    }

    // unused:ignore textFieldDidBeginEditing
    func textFieldDidBeginEditing(_ textField: UITextField) {
        presenter.searchBarTextFieldTapped(text: textField.text ?? "")
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = tableViewDataSource?.item(at: indexPath) else { return }
        didTapSearchResult(item: item, at: indexPath, subIndex: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        tableViewDataSource?.tableView(tableView, viewForHeaderInSection: section)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let sectionHeaderType = tableViewDataSource?.sections[section].headerType else { return 0 }

        switch sectionHeaderType {
        case .default: return 44
        case .searchResult: return 64
        case .mediaResult: return 0
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard
            let dataSource = tableViewDataSource,
            dataSource.sections.count == 1,
            let selectedSegmentedIndex = segmentedControl.selectedSegmentIndex,
            let searchScopes = searchScopes
        else { return }

        // This might get out of sync and crash
        // in case the user switches search scoppe while the content is still scrolling
        // Hence the extra check here ...
        guard searchScopes.count > selectedSegmentedIndex else { return }

        let selectedScope = searchScopes[selectedSegmentedIndex]
        let numberOfItems = dataSource.tableView(tableView, numberOfRowsInSection: 0)
        if indexPath.row == numberOfItems - SearchViewController.paginationThreshold {
            presenter.didScrollToBottom(with: selectedScope)
        }
    }
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard
            let dataSource = collectionViewDataSource,
            dataSource.sections.count == 1,
            let selectedSegmentedIndex = segmentedControl.selectedSegmentIndex,
            let searchScopes = searchScopes
        else { return }

        // This might get out of sync and crash
        // in case the user switches search scoppe while the content is still scrolling
        // Hence the extra check here ...
        guard searchScopes.count > selectedSegmentedIndex else { return }

        let selectedScope = searchScopes[selectedSegmentedIndex]
        let numberOfItems = dataSource.collectionView(collectionView, numberOfItemsInSection: 0)
        if indexPath.row == numberOfItems - SearchViewController.paginationThreshold {
            presenter.didScrollToBottom(with: selectedScope)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        collectionViewDataSource?.collectionView(collectionView, layout: layout, referenceSizeForHeaderInSection: section) ?? CGSize.zero
    }

    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if shouldScrollToSelectedFilter,
            let mediaFiltersHeader = view as? SearchResultsMediaSectionHeaderView {

            mediaFiltersHeader.scrollToSelected()
            shouldScrollToSelectedFilter = false
        }
    }
}

extension SearchViewController: SearchResultsDelegate {

    func didTapPhrasionaryTarget(at index: Int) {
        presenter.didTapPhrasionaryTarget(at: index)
    }

    func didTapSearchResult(item: SearchResultItemViewData, at indexPath: IndexPath, subIndex: Int?) {
        let actualIndex = Array(0..<indexPath.section).reduce(0) { $0 + tableView.numberOfRows(inSection: $1) } + indexPath.row
        presenter.didSelect(searchItem: item, at: actualIndex, subIndex: subIndex)
    }
}

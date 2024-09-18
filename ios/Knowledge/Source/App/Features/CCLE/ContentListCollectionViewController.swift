//
//  ContentListCollectionViewController.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 19.04.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit

final class ContentListCollectionViewController: UIViewController {

    private let presenter: ContentListPresenterType
    private static let overlayAlpha: CGFloat = 0.7
    private static let animationsDuration: CGFloat = 0.3

    private var dataSource: ContentListDataSource? {
        didSet {
            dataSource?.setup(in: collectionView)
            collectionView.dataSource = dataSource
            collectionView.reloadData()
        }
    }

    init(presenter: ContentListPresenterType) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .backgroundPrimary
        return collectionView
    }()

    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.searchTextField.delegate = self
        searchBar.backgroundColor = .canvas
        searchBar.showsCancelButton = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.style = .medium
        view.hidesWhenStopped = true
        return view
    }()

    private lazy var messagView: ContentListMessageView = {
        let view = ContentListMessageView()
        view.delegate = self
        view.alpha = .zero
        view.backgroundColor = ThemeManager.currentTheme.backgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var overlayView: UIView = {
        let view = UIView(frame: self.view.bounds)
        view.backgroundColor = .backgroundPrimary
        view.alpha = .zero
        view.isHidden = true
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ThemeManager.currentTheme.backgroundColor
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(messagView)
        view.addSubview(overlayView)
        view.addSubview(activityIndicatorView)

        messagView.constrain(to: collectionView)
        overlayView.constrain(to: collectionView)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: -1),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        presenter.view = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.calculateItemSizeOftheCollectionView()
    }

    /// This function is calculating the item size in the collectionView in a dynamic way.
    ///    The calculation depends on these rules:
    ///       - At least there should be 2 rows,
    ///       - items should have a minimum width,
    ///       - there can be may rows as the items fits with the static minimum width,
    ///       - paddings and spacings should have a static value
    ///       - item images should have aspect ratio as 1
    private func calculateItemSizeOftheCollectionView() {

        let minimumItemWidth: CGFloat = 136  // Minimum item width is calculated depending on the oldest and smallest device which has the 320 px width.
        let collectionViewWidth = collectionView.frame.width
        var width: CGFloat = 0

        let minimumNumberOfRows = 2
        let maximumNumberOfRows = 20

        for columns in minimumNumberOfRows..<maximumNumberOfRows {
            let availableContentSpace = (collectionViewWidth - layout.sectionInset.left - layout.sectionInset.right - collectionView.adjustedContentInset.left - collectionView.adjustedContentInset.right - CGFloat((columns - 1)) * layout.minimumInteritemSpacing)
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

}

extension ContentListCollectionViewController: ContentListViewType {
    func setUp(title: String, placeholder: String) {
        self.title = title
        let attributedPlaceholder = NSAttributedString(string: placeholder,
                                                       attributes: ThemeManager.currentTheme.searchTextFieldPlaceholderTextAttributes)
        searchBar.styled(with: attributedPlaceholder,
                         image: Asset.Icon.searchList.image,
                         backgroundColor: .backgroundPrimary,
                         tintColor: .iconOnAccent,
                         barTintColor: ThemeManager.currentTheme.tintColor,
                         imageTintColor: ThemeManager.currentTheme.contentListSearchIconTintColor)
    }

    func setViewState(_ state: ContentListViewState) {
        switch state {
        case .loading:
            navigationItem.backBarButtonItem?.title = ""
            hideMessage()
            setOverlay(visible: true, animated: true)
            activityIndicatorView.startAnimating()
        case .loaded(let viewData, let scrolledToTop):
            dataSource = ContentListDataSource(viewData: viewData)
            setOverlay(visible: false, animated: false)
            activityIndicatorView.stopAnimating()
            if scrolledToTop, !viewData.items.isEmpty {
                collectionView.setContentOffset(.zero, animated: false)
            }
        case .error(let title, let subtitle, let actionTitle):
            showMessage(title: title, subtitle: subtitle, actionTitle: actionTitle)
            setOverlay(visible: false, animated: false)
            activityIndicatorView.stopAnimating()
        case .empty(let title, let subtitle):
            showMessage(title: title, subtitle: subtitle)
            setOverlay(visible: false, animated: false)
            activityIndicatorView.stopAnimating()
        }
    }

    func setOverlay(_ isOn: Bool) {
        setOverlay(visible: isOn, animated: true)
    }

    private func showMessage(title: String, subtitle: String, actionTitle: String? = nil) {
        messagView.configure(title: title, subtitle: subtitle, actionTitle: actionTitle)

        UIView.animate(withDuration: Self.animationsDuration) { [weak self] in
            self?.messagView.alpha = 1
        }
    }

    private func hideMessage() {
        UIView.animate(withDuration: Self.animationsDuration) { [weak self] in
            self?.messagView.alpha = 0
        }
    }

    private func setOverlay(visible: Bool, animated: Bool) {
        if animated {
            if visible {
                self.overlayView.alpha = 0
                self.overlayView.isHidden = false
            }
            UIView.animate(withDuration: Self.animationsDuration, animations: { [weak self] in
                self?.overlayView.alpha = visible ? Self.overlayAlpha : .zero
            }, completion: { [weak self] _ in
                self?.overlayView.isHidden = !visible
            })
        } else {
            overlayView.alpha = visible ? Self.overlayAlpha : .zero
            overlayView.isHidden = !visible
        }
    }
}

extension ContentListCollectionViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let dataSource = dataSource else { return }
        let numberOfItems = dataSource.collectionView(collectionView, numberOfItemsInSection: 0)
        if indexPath.row == numberOfItems - presenter.paginationThreshold {
            presenter.didScrollToBottom()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let dataSource = dataSource else { return }
        presenter.didSelect(item: dataSource.item(at: indexPath))
    }
}

extension ContentListCollectionViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        presenter.searchButtonTapped(query: searchBar.text ?? "")
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(true, animated: false)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presenter.searchBarCancelButtonTapped()
        searchBar.searchTextField.text = ""
        searchBar.resignFirstResponder()
    }
}

extension ContentListCollectionViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        presenter.searchBarTapped()
        return presenter.searchBarTextFieldCanBeginEditting()
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        presenter.searchBarTextFieldDidBeginEditing()
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        presenter.searchBarTextFieldDidEndEditing()
        if textField.text?.isEmpty ?? true {
            searchBar.setShowsCancelButton(false, animated: true)
        }
    }
}

extension ContentListCollectionViewController: ContentListMessageViewDelegate {
    func didTapActionButton() {
        presenter.retryButtonTapped()
    }
}

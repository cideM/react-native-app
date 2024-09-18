//
//  SearchResultsDatasource.swift
//  Knowledge
//
//  Created by Cornelius Horstmann on 05.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit
import DesignSystem

protocol SearchResultsDelegate: AnyObject {
    func didTapPhrasionaryTarget(at index: Int)
    func didTapSearchResult(item: SearchResultItemViewData, at indexPath: IndexPath, subIndex: Int?)
}

final class SearchResultsDatasource: NSObject {
    let searchTerm: String
    let sections: [SearchResultSection]

    weak var delegate: SearchResultsDelegate?

    init(searchTerm: String, sections: [SearchResultSection], delegate: SearchResultsDelegate?) {
        self.searchTerm = searchTerm
        self.sections = sections
        self.delegate = delegate
    }

    func setup(in tableView: UITableView) {
        tableView.register(InstantResultTableViewCell.self, forCellReuseIdentifier: InstantResultTableViewCell.reuseIdentifier)
        tableView.register(AutocompleteTableViewCell.self, forCellReuseIdentifier: AutocompleteTableViewCell.reuseIdentifier)
        tableView.register(SearchHistoryTableViewCell.self, forCellReuseIdentifier: SearchHistoryTableViewCell.reuseIdentifier)
        tableView.register(GenericTableViewCell<PhrasionaryView>.self, forCellReuseIdentifier: GenericTableViewCell<PhrasionaryView>.reuseIdentifier)
        tableView.register(UINib(nibName: SearchResultTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: SearchResultTableViewCell.reuseIdentifier)
        tableView.register(TableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: TableViewHeaderView.reuseIdentifier)
        tableView.register(SearchResultSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: SearchResultSectionHeaderView.reuseIdentifier)
        tableView.register(MediaOverviewSearchResultTableViewCell.self, forCellReuseIdentifier: MediaOverviewSearchResultTableViewCell.reuseIdentifier)
        tableView.register(GenericTableViewCell<SearchResultView>.self, forCellReuseIdentifier: GenericTableViewCell<SearchResultView>.reuseIdentifier)
    }

    func setup(in collectionView: UICollectionView) {
        collectionView.register(MediaSearchResultCollectionViewCell.self, forCellWithReuseIdentifier: MediaSearchResultCollectionViewCell.reuseIdentifier)
        collectionView.register(SearchResultsMediaSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SearchResultsMediaSectionHeaderView.reuseIdentifier)
    }

    func section(at index: Int) -> SearchResultSection? {
        guard index < sections.count, index >= 0 else { return nil }
        return sections[index]
    }

    func item(at indexPath: IndexPath) -> SearchResultItemViewData? {
        guard let section = self.section(at: indexPath.section),
              indexPath.row >= 0,
              indexPath.row < section.items.count else { return nil }
        return section.items[indexPath.row]
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection index: Int) -> UIView? {
        guard let sectionHeaderType = section(at: index)?.headerType else { return nil }

        switch sectionHeaderType {
        case .default(let title):
            let defaultSectionHeaderView: TableViewHeaderView = tableView.dequeueReusableHeaderFooterView()
            defaultSectionHeaderView.setTitle(title)
            return defaultSectionHeaderView
        case .searchResult(let data):
            let searchResultSectionHeaderView: SearchResultSectionHeaderView = tableView.dequeueReusableHeaderFooterView()
            searchResultSectionHeaderView.configure(with: data)
            return searchResultSectionHeaderView
        default:
            assertionFailure("Unexpected table view header type \(sectionHeaderType)")
            return nil
        }
    }
}

extension SearchResultsDatasource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.section(at: section)?.items.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let sectionHeaderType = section(at: indexPath.section)?.headerType {
            switch sectionHeaderType {
            case .mediaResult(let filters):
                let mediaSectionHeaderView: SearchResultsMediaSectionHeaderView = collectionView.dequeueReusableHeaderView(at: indexPath)
                mediaSectionHeaderView.configure(filters: filters)
                return mediaSectionHeaderView
            default:
                assertionFailure("Unexpected collection view header type \(sectionHeaderType)")
            }
        }
        preconditionFailure("Invalid supplementary view type for collection view")
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = self.item(at: indexPath), case .media(mediaSearchViewItem: let mediaSearchViewItem, _) = item  else {
            fatalError("No Item found")
        }

        return configured(mediaCell: collectionView.dequeueReusableCell(withReuseIdentifier: MediaSearchResultCollectionViewCell.reuseIdentifier, for: indexPath) as? MediaSearchResultCollectionViewCell ?? MediaSearchResultCollectionViewCell(), with: mediaSearchViewItem)
    }
}

extension SearchResultsDatasource: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let sectionHeaderType = self.section(at: section)?.headerType else { return .zero }

        switch sectionHeaderType {
        case .mediaResult(let filters):
            return filters.isEmpty ? .zero : CGSize(width: collectionView.bounds.width, height: 60)
        default:
            assertionFailure("Unexpected collection view header type \(sectionHeaderType)")
            return .zero
        }
    }
}

extension SearchResultsDatasource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.section(at: section)?.items.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = self.item(at: indexPath) else {
            fatalError("No Item found")
        }
        switch item {
        case .history(let item):
            return configured(historyCell: tableView.dequeuedCell(), with: item)
        case .autocomplete(let suggestedTerm, _):
            return configured(suggestionCell: tableView.dequeuedCell(), with: suggestedTerm)
        case .phrasionary(let phrasionaryItem):
            return configured(phrasionaryCell: tableView.dequeuedCell(), with: phrasionaryItem)
        case .article(let articleSearchViewItem, _):
            return configured(articleCell: tableView.dequeuedCell(), indexPath: indexPath, with: articleSearchViewItem)
        case .pharma(let pharmaSearchViewItem, _, _):
            return configured(pharmaCell: tableView.dequeuedCell(), with: pharmaSearchViewItem)
        case .monograph(let monographSearchViewItem, _):
            return configured(monographCell: tableView.dequeuedCell(), indexPath: indexPath, with: monographSearchViewItem)
        case .instantResult(suggestedTerm: let suggestedTerm, _):
            return configured(instantResultCell: tableView.dequeuedCell(), with: suggestedTerm)
        case .guideline(guidelineSearchViewItem: let guidelineSearchViewItem, _):
            return configured(guidelineCell: tableView.dequeuedCell(), with: guidelineSearchViewItem)
        case .mediaOverview(mediaSearchOverviewItems: let mediaSearchOverviewItems, _):
            return configured(mediaCell: tableView.dequeuedCell(), with: mediaSearchOverviewItems)
        case .media:
            fatalError("No Item found")
        }
    }
}

private extension SearchResultsDatasource {

    func configured(historyCell cell: SearchHistoryTableViewCell, with historyItem: String) -> SearchHistoryTableViewCell {
        cell.set(historyItem: historyItem)
        cell.backgroundColor = .backgroundPrimary
        return cell
    }

    func configured(suggestionCell cell: AutocompleteTableViewCell, with suggestionItem: AutocompleteViewItem) -> AutocompleteTableViewCell {
        cell.set(suggestion: suggestionItem.text)
        cell.backgroundColor = .backgroundPrimary
        return cell
    }

    func configured(instantResultCell cell: InstantResultTableViewCell, with suggestionItem: InstantResultViewItem) -> InstantResultTableViewCell {
        cell.set(suggestion: suggestionItem.attributedText, type: suggestionItem.type)
        cell.backgroundColor = .backgroundPrimary
        return cell
    }

    func configured(phrasionaryCell cell: GenericTableViewCell<PhrasionaryView>, with viewData: PhrasionaryView.ViewData) -> GenericTableViewCell<PhrasionaryView> {
        cell.view.setUp(with: viewData, delegate: self)
        return cell
    }

    func configured(articleCell cell: GenericTableViewCell<SearchResultView>, indexPath: IndexPath, with articleSearchItem: ArticleSearchViewItem) -> GenericTableViewCell<SearchResultView> {
        cell.view.configure(articleItem: articleSearchItem, indexPath: indexPath, delegate: self)
        cell.separatorInset.right = .greatestFiniteMagnitude // hide system separator
        return cell
    }

    func configured(pharmaCell cell: SearchResultTableViewCell, with pharmaSearchItem: PharmaSearchViewItem) -> SearchResultTableViewCell {
        cell.configure(item: pharmaSearchItem)
        cell.backgroundColor = .backgroundPrimary
        return cell
    }

    func configured(monographCell cell: GenericTableViewCell<SearchResultView>, indexPath: IndexPath, with monographSearchItem: MonographSearchViewItem) -> GenericTableViewCell<SearchResultView> {
        cell.view.configure(monographItem: monographSearchItem, indexPath: indexPath, delegate: self)
        cell.separatorInset.right = .greatestFiniteMagnitude // hide system separator
        return cell
    }

    func configured(guidelineCell cell: SearchResultTableViewCell, with guidelineSearchItem: GuidelineSearchViewItem) -> SearchResultTableViewCell {
        cell.configure(item: guidelineSearchItem)
        cell.backgroundColor = .backgroundPrimary
        return cell
    }

    func configured(mediaCell cell: MediaOverviewSearchResultTableViewCell, with mediaSearchOverviewItems: [MediaSearchOverviewItem]) -> MediaOverviewSearchResultTableViewCell {
        cell.configure(items: mediaSearchOverviewItems)
        cell.backgroundColor = .backgroundPrimary
        return cell
    }

    func configured(mediaCell cell: MediaSearchResultCollectionViewCell, with mediaSearchItem: MediaSearchViewItem) -> MediaSearchResultCollectionViewCell {
        cell.configure(item: mediaSearchItem)
        cell.backgroundColor = .backgroundPrimary
        return cell
    }
}

extension SearchResultsDatasource: PhrasionaryViewDelegate {
    func didTapPhrasionaryTarget(at index: Int) {
        self.delegate?.didTapPhrasionaryTarget(at: index)
    }

}

extension SearchResultsDatasource: SearchResultViewDelegate {
    func didTapSearchResult(at indexPath: IndexPath, subIndex: Int?) {
        guard let item = item(at: indexPath) else { return }
        self.delegate?.didTapSearchResult(item: item, at: indexPath, subIndex: subIndex)
    }
}

//
//  PharmaViewController+UICollectionViewDataSource.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 23.11.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import RichTextRenderer
import UIKit

extension PharmaViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sections[section] {
        case .section: return 1
        case .simpleTitle: return 0 // <- This is just used as a headline in between sections, hence 0
        default: return 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let viewData = sections[indexPath.section]
        switch viewData {

        case .substance(let item):
            let cell: PharmaSubstanceCell = collectionView.dequeuedCell( at: indexPath)
            cell.configure(item)
            cell.delegate = self
            return cell

        case .drug(let item):
            let cell: PharmaDrugCell = collectionView.dequeuedCell(at: indexPath)
            cell.configure(item)
            cell.delegate = self
            return cell

        case .section(let item):
            // This cell should not be recycled ever cause setting it up again while scrolling leads to stuttering ...
            let reuseIdentifier = RichTextCell.uniqueReuseIdentifier(with: viewData) ?? RichTextCell.reuseIdentifier
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
            if let richTextCell = cell as? RichTextCell {
                richTextCell.configure(rendererConfiguration: pharmaRichTextRendererConfiguration, richTextDocument: item.richText)
                richTextCell.delegate = presenter
                richTextCell.backgroundColor = .backgroundPrimary
            } else {
                assertionFailure("Unexpected nil value. Expected RichTextCell but got nil")
            }
            return cell

        case .prescribingInfo(let data):
            let cell: PharmaPrescribingInfoCell = collectionView.dequeuedCell(at: indexPath)
            let prescribingInformationAction: (() -> Void)? = { [weak self] in
                self?.presenter.prescriptionInformationButtonTapped(with: data)
            }
            let patientPackageAction: (() -> Void)? = { [weak self] in
                self?.presenter.patientPackageInsertButtonTapped(with: data)
            }
            cell.setData(data, prescribingInformationAction: prescribingInformationAction, patientPackageAction: patientPackageAction)
            return cell

        case .simpleTitle:
            assertionFailure("Sections of this type only have a header and no content.")
            let cell: RichTextCell = collectionView.dequeuedCell(at: indexPath)
            return cell

        case .feedback:
            let cell: PharmaFeedbackCell = collectionView.dequeuedCell(at: indexPath)
            cell.delegate = self
            return cell

        case .segmentedControl(let segments):
            let cell: PharmaSegmentedControlCell = collectionView.dequeuedCell(at: indexPath)
            cell.setSegments(
                segments.map {
                    .init(title: $0.title, anchor: $0.anchor, isEmpty: $0.isEmpty, isSelected: $0.isSelected)
                }
            )
            cell.delegate = presenter
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // WORKAROUND: Accessing the section of an IndexPath object
        // that has only one component (section), should not cause
        // an exception but it does. The workaround for this is
        // casting the IndexPath to an NSIndexPath object. After that
        // accessing the section property won't crash the app.
        let section = (indexPath as NSIndexPath).section

        // Conbfigure header looks ...
        let data = sections[section]
        switch data {
        case .simpleTitle(let title, let isHighlighted):
            // Dequeue view ...
            let kind = UICollectionView.elementKindSectionHeader
            let identifier = SimpleSectionHeader.reuseIdentifier
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath)

            guard let header = view as? SimpleSectionHeader else { return UICollectionReusableView() }
            header.setTitle(title, isHighlighted: isHighlighted)
            return header

        default:
            // Dequeue view ...
            let kind = UICollectionView.elementKindSectionHeader
            let identifier = PharmaSectionHeader.reuseIdentifier
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath)

            // Make header tappable ...
            guard let header = view  as? PharmaSectionHeader else { return UICollectionReusableView() }
            layout.make(view: header, toggle: section)

            // We are getting this value from the layout object cause the viewData does not change
            // Notions of expanded sections in viewData are only used for initial display and are outdated
            // as soon as the user starts interacting with the collectionview ...
            let isExpanded = layout.isSectionExpanded(at: section)
            header.configure(at: section, with: data, isExpanded: isExpanded, animated: false)
            return header
        }
    }
}

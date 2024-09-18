//
//  PharmaViewController.swift
//  Knowledge
//
//  Created by Silvio Bulla on 21.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import RichTextRenderer
import UIKit

/// @mockable
protocol PharmaViewType: AnyObject {
    func setData(for pharmaViewData: PharmaViewData)
    func presentMessage(_ message: PresentableMessageType, actions: [MessageAction])
}

final class PharmaViewController: UIViewController, PharmaViewType {

    private(set) var sections: [PharmaViewData.SectionViewData] = [] { didSet {
        sections.forEach {
            // All of the RichTextCells should not be recycled at all cause preparing them
            // while scrolling can lead to stuttering (rendering long strings is expensive)
            // Hence RichTextCells get an unique id so they are never resetted once properly configured
            // There is additional code in "var RichTextCell.richTextDocument" that makes sure
            // the cell only gets modified if the content actually differs ...
            if let reuseIdentifier = RichTextCell.uniqueReuseIdentifier(with: $0) {
                collectionView.register(RichTextCell.self, forCellWithReuseIdentifier: reuseIdentifier)
            }
        }
    }}

    let presenter: PharmaPresenterType
    let pharmaRichTextRendererConfiguration = PharmaRichTextRendererConfiguration()

    init(presenter: PharmaPresenterType) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    private(set) lazy var layout = AccordionListLayout(delegagte: self)

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .canvas
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self

        view.addSubview(collectionView)
        collectionView.constrainEdges(to: view)

        // Cell registration
        // Via class ...
        [
            (RichTextCell.self, RichTextCell.reuseIdentifier),
            (PharmaFeedbackCell.self, PharmaFeedbackCell.reuseIdentifier),
            (PharmaSegmentedControlCell.self, PharmaSegmentedControlCell.reuseIdentifier),
            (PharmaSubstanceCell.self, PharmaSubstanceCell.reuseIdentifier)
        ].forEach { [weak self] type, identifier in
            self?.collectionView.register(type, forCellWithReuseIdentifier: identifier)
        }
        // Via nib ...
        [
            (UINib(nibName: PharmaPrescribingInfoCell.reuseIdentifier, bundle: nil), PharmaPrescribingInfoCell.reuseIdentifier),
            (UINib(nibName: PharmaDrugCell.reuseIdentifier, bundle: nil), PharmaDrugCell.reuseIdentifier)
        ].forEach { [weak self] nib, identifier in
            self?.collectionView.register(nib, forCellWithReuseIdentifier: identifier)
        }
        // Header ...
        collectionView.register(PharmaSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PharmaSectionHeader.reuseIdentifier)
        collectionView.register(SimpleSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SimpleSectionHeader.reuseIdentifier)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.viewDismissed()
    }

    func setData(for pharmaViewData: PharmaViewData) {
        title = pharmaViewData.title
        sections = pharmaViewData.sections
        collectionView.reloadData()

        // WORKAROUND:
        // Scrolling to an empty section crashes
        // Doing this "manually" via a rect works ...
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let index = sections
                .firstIndex { data in
                    switch data {
                    case .simpleTitle(_, let isHighlighted): isHighlighted
                    default: false
                    }
                }
            if let index, sections.count > index {
                let section = layout.sections[index]
                let height = collectionView.bounds.height - collectionView.safeAreaInsets.top - collectionView.safeAreaInsets.bottom
                collectionView.scrollRectToVisible(.init(x: 0,
                                                         y: section.originY,
                                                         width: section.frame.width,
                                                         height: height), animated: true)
            }
        }
    }

    func presentMessage(_ message: PresentableMessageType, actions: [MessageAction]) {
        UIAlertMessagePresenter(presentingViewController: self).present(message, actions: actions)
    }
}

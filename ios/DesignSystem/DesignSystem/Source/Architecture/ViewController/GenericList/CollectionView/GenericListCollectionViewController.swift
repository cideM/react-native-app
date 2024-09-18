//
//  GenericListCollectionViewController.swift
//  DesignSystem
//
//  Created by Manaf Alabd Alrahim on 23.10.23.
//

import UIKit

public class GenericListCollectionViewController<DataSource: GenericListCollectionViewDataSourceType, Presenter: GenericListViewPresenterType>: UIViewController, GenericListViewType {

    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    public var presenter: Presenter?
    public var dataSource: DataSource?

    // TODO: Layout should be passed to the collection view
    public var layout: UICollectionViewLayout

    public init(dataSource: DataSource,
                presenter: Presenter?,
                layout: UICollectionViewLayout) {
        self.dataSource = dataSource
        self.presenter = presenter
        self.layout = layout
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .canvas
        view.addSubview(collectionView)
        dataSource?.registerCells(in: collectionView)
        collectionView.pin(to: view)
        collectionView.dataSource = self.dataSource
        collectionView.delegate = self.dataSource
        presenter?.view = self as? Presenter.View
    }

    public func update(with data: [DataSource.ViewData]) {
        dataSource?.data = data
        collectionView.reloadData()
    }
}

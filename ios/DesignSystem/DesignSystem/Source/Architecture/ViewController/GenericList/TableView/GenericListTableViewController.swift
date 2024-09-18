//
//  GenericListTableViewController.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 17.10.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import UIKit

public class GenericListTableViewController<DataSource: GenericListTableViewDataSourceType, Presenter: GenericListViewPresenterType>: UIViewController, GenericListViewType {

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        return tableView
    }()

    public var presenter: Presenter?
    public var dataSource: DataSource?

    public init(dataSource: DataSource,
                presenter: Presenter?) {
        self.dataSource = dataSource
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .canvas
        view.addSubview(tableView)
        dataSource?.registerCells(in: tableView)
        tableView.pin(to: view)
        tableView.dataSource = self.dataSource
        tableView.delegate = self.dataSource
        presenter?.view = self as? Presenter.View
    }

    public func update(with data: [DataSource.ViewData]) {
        dataSource?.data = data
        tableView.reloadData()
    }
}

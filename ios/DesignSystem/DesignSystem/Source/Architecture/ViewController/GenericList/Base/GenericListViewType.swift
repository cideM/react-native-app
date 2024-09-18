//
//  GenericListViewType.swift
//  DesignSystem
//
//  Created by Manaf Alabd Alrahim on 23.10.23.
//

import Foundation

public protocol GenericListViewType: AnyObject {
    associatedtype DataSource: GenericListViewDataSourceType
    associatedtype Presenter: GenericListViewPresenterType

    var dataSource: DataSource? { get set }
    var presenter: Presenter? { get set }

    func update(with data: [DataSource.ViewData])
}

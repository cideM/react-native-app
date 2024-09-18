//
//  GenericTableViewPresenter.swift
//  DesignSystem
//
//  Created by Manaf Alabd Alrahim on 20.10.23.
//

import Foundation

public protocol GenericListViewPresenterType: AnyObject {
    associatedtype View: GenericListViewType

    var view: View? { get set }
}

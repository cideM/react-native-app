//
//  LibraryDownloadStateView.swift
//  Knowledge
//
//  Created by CSH on 22.01.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common

import UIKit

protocol LibraryDownloadStateViewType: AnyObject {
    func setProgress(_ progress: Double)
    func setInstalling()
    func setIsUpToDate()
    func setIsFailed()
}

extension UINavigationController: LibraryDownloadStateViewType {

    private var pieChartView: PieChartView? {
        get {
            amboss_customBadgeView as? PieChartView
        }
        set {
            amboss_customBadgeView = newValue
        }
    }

    private var activityIndicator: UIActivityIndicatorView? {
        get {
            amboss_customBadgeView as? UIActivityIndicatorView
        }
        set {
            amboss_customBadgeView = newValue
        }
    }

    func setIsUpToDate() {
        tabBarItem.badgeValue = nil
        pieChartView = nil
        activityIndicator = nil
    }

    func setProgress(_ progress: Double) {
        tabBarItem.badgeValue = nil
        setDownloadProgress(progress)
    }

    func setInstalling() {
        tabBarItem.badgeValue = nil
        activityIndicator = UIActivityIndicatorView()
        activityIndicator?.startAnimating()
        activityIndicator?.style = .medium
    }

    func setIsFailed() {
        tabBarItem.badgeValue = "!"
        pieChartView = nil
        activityIndicator = nil
    }

    private func setDownloadProgress(_ progress: Double) {
        guard let pieChartView = pieChartView else {
            let pieChartView = PieChartView(backgroundLayerColor: ThemeManager.currentTheme.pieChartBackgroundColor,
                                        foregroundLayerColor: ThemeManager.currentTheme.tintColor)
            self.pieChartView = pieChartView
            pieChartView.heightAnchor.constraint(equalToConstant: 12).isActive = true
            pieChartView.widthAnchor.constraint(equalToConstant: 12).isActive = true
            return setDownloadProgress(progress)
        }
        pieChartView.setProgress(Float(progress))
    }
}

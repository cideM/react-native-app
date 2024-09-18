//
//  MediaSearchMoreView.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 22.08.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Common

import UIKit

class MediaSearchMoreView: UIView {

    private let mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundPrimary
        view.layer.borderWidth = 1
        view.layer.borderColor = ThemeManager.currentTheme.searchMediaViewMoreBorderColor.cgColor
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(frame: CGRect = .zero, viewMoreItem: MediaSearchViewMoreItem) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(mainView)
        mainView.addSubview(label)
        NSLayoutConstraint.activate([
            mainView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainView.topAnchor.constraint(equalTo: topAnchor),
            mainView.heightAnchor.constraint(equalTo: mainView.widthAnchor),
            label.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -8),
            label.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -8),
            mainView.heightAnchor.constraint(equalToConstant: 155)
        ])

        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.onTap = {
            viewMoreItem.tapHandler()
        }
        mainView.addGestureRecognizer(tapGestureRecognizer)

        fillData(viewMoreItem: viewMoreItem)
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func fillData(viewMoreItem: MediaSearchViewMoreItem) {
        self.label.attributedText = NSAttributedString(string: viewMoreItem.title, attributes: ThemeManager.currentTheme.searchMediaViewMoreTitleTextAttributes)
    }
}

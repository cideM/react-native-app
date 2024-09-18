//
//  SearchScope.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 07.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//
import Common
import Localization

enum SearchScope {
    case overview
    case library(itemCount: Int)
    case pharma(itemCount: Int)
    case guideline(itemCount: Int)
    case media(itemCount: Int)

    var title: NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = .attributes(style: .paragraphSmallBold, with: [.color(.textSecondary)])
        switch self {
        case .overview:
            return NSMutableAttributedString(string: L10n.Search.SearchScope.Overview.title, attributes: attributes)
        case .library(let itemCount):
            let title = NSMutableAttributedString(string: L10n.Search.SearchScope.Library.title, attributes: attributes)
            let count = NSAttributedString(string: " (\(itemCount))", attributes: attributes)
            title.append(count)
            return title
        case .pharma(let itemCount):
            let title = NSMutableAttributedString(string: L10n.Search.SearchScope.Pharma.title, attributes: attributes)
            let count = NSAttributedString(string: " (\(itemCount))", attributes: attributes)
            title.append(count)
            return title
        case .guideline(itemCount: let itemCount):
            let title = NSMutableAttributedString(string: L10n.Search.SearchScope.Guideline.title, attributes: attributes)
            let count = NSAttributedString(string: " (\(itemCount))", attributes: attributes)
            title.append(count)
            return title
        case .media(itemCount: let itemCount):
            let title = NSMutableAttributedString(string: L10n.Search.SearchScope.Media.title, attributes: attributes)
            let count = NSAttributedString(string: " (\(itemCount))", attributes: attributes)
            title.append(count)
            return title
        }
    }

    func isSameCase(_ otherCase: SearchScope) -> Bool {
        title.string.components(separatedBy: " ").first == otherCase.title.string.components(separatedBy: " ").first
    }
}

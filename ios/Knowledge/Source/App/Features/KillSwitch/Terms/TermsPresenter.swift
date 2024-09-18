//
//  TermsPresenter.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 23.04.24.
//  Copyright © 2024 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Networking
import Domain

protocol TermsPresenterType {
    var view: TermsViewType? { get set }
    func viewDidAppear()
    func acceptTerms()
    func openExternally(url: URL)
}

final class TermsPresenter: TermsPresenterType {

    weak var view: TermsViewType?

    private let html: HtmlDocument
    private let id: TermsIdentifier
    private let completion: (TermsIdentifier) -> Void

    init(id: TermsIdentifier, html: HtmlDocument, completion: @escaping (TermsIdentifier) -> Void) {
        self.id = id
        self.html = html
        self.completion = completion
    }

    func viewDidAppear() {
        view?.set(html: html)
    }

    func acceptTerms() {
        completion(id)
    }

    func openExternally(url: URL) {
        UIApplication.shared.open(url)
    }
}

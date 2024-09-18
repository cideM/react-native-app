//
//  SubviewMessagePresenter.swift
//  Knowledge
//
//  Created by Silvio Bulla on 25.09.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Domain
import UIKit

/// This class is responsible for presenting a  `UIView` for every `PresentableError`.
public final class SubviewMessagePresenter {

    let rootView: UIView
    var errorView: ErrorView?

    /// Initializes the `SubviewErrorPresenter` with an instance of `UIViewC`.
    ///
    /// - Parameters:
    ///   - rootView: The view that is going to be responsible for the presentation of the error `UIView`.
    public init(rootView: UIView) {
        self.rootView = rootView
    }
}

extension SubviewMessagePresenter: MessagePresenter {

    public func present(_ message: PresentableMessageType, actions: [MessageAction]) {
        let errorView = ErrorView(actions: actions, message: message)
        errorView.translatesAutoresizingMaskIntoConstraints = false
        rootView.addSubview(errorView)
        errorView.preservesSuperviewLayoutMargins = true
        errorView.constrainEdges(to: rootView)
        self.errorView = errorView
    }
}

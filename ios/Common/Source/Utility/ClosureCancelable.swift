//
//  Cancelable.swift
//  Common
//
//  Created by CSH on 27.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain

/// A ClosureCancelable defines the cancel action via a closure.
public final class ClosureCancelable: NSObject, Cancelable {

    private var closure: (() -> Void)?

    deinit {
        cancel()
    }

    /// Initializes a new ClosureCancelable with a closure to be called when
    /// the cancel function is called.
    ///
    /// - Parameter closure: The cancel closure.
    public init(_ closure: @escaping () -> Void) {
        self.closure = closure
    }

    public func cancel() {
        closure?()
        closure = nil
    }
}

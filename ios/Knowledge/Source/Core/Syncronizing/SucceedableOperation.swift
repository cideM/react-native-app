// swift:disable identifier_name
//
//  SucceedableOperation.swift
//  Knowledge
//
//  Created by CSH on 11.11.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Foundation

/// The SucceedableOperation is a wrapper for an `Operation`, simplifying the implementation
/// of an asynchronous operation.
/// In order to implement an `SucceedableOperation`, create a subclass,
/// override the `execute()` function and call the `completion` closure with the result.
class SucceedableOperation: Operation {

    override var isAsynchronous: Bool {
        true
    }

    private var _isFinished = false
    override var isFinished: Bool {
        get {
            _isFinished
        }
        set {
            _isFinished = newValue
        }
    }

    private var _isExecuting = false
    override var isExecuting: Bool {
        get {
            _isExecuting
        }
        set {
            _isExecuting = newValue
        }
    }

    var result: Result<Void, Error>?

    override func start() {
        isExecuting = true
        execute { [weak self] result in
            self?.result = result
            self?.isExecuting = false
            self?.isFinished = true
        }
    }

    /// Child classes should override this function, perform their work in it and call the completion closure.
    /// Make sure you perform your work in a different thread.
    /// - Parameter completion: The completion closure to call once the work is done.
    func execute(completion: @escaping (Result<Void, Error>) -> Void) {
        assertionFailure("Should be overridden by child classes.")
        completion(.failure(OperationError.executionFunctionIsntImplementedByChild))
    }
}

private extension SucceedableOperation {
    enum OperationError: Error {
        case executionFunctionIsntImplementedByChild
    }
}

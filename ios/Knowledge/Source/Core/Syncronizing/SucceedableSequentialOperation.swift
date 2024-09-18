//
//  SucceedableSequentialOperation.swift
//  Knowledge
//
//  Created by CSH on 11.11.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Foundation

/// The SucceedableSequentialOperation executes an array of operations in sequence in the background.
/// If any of it's child operations fail, it will cancel all the remaining operations and complet it's own execution.
class SucceedableSequentialOperation: SucceedableOperation {

    private var operations: [SucceedableOperation]

    init(operations: [SucceedableOperation]) {
        self.operations = operations
        super.init()
    }

    override func execute(completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async { [operations] in
            SucceedableSequentialOperation.execute(operations: operations, completion: completion)
        }
    }

    private static func execute(operations: [SucceedableOperation], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let first = operations.first else { return completion(.success(())) }
        let nextOperations = Array(operations.suffix(from: 1))
        first.execute { result in
            switch result {
            case .success: SucceedableSequentialOperation.execute(operations: nextOperations, completion: completion)
            case .failure(let error):
                nextOperations.forEach { $0.cancel() }
                completion(.failure(error))
            }
        }
    }

}

//
//  DispatchQueue+Capture.swift
//  Common
//
//  Created by CSH on 18.11.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Foundation

public extension DispatchQueue {
    /// The `captureAsync` function ensures a given closure is executed in the queue asyncronously.
    /// - Parameter closure: The closure that should be executed.
    func captureAsync<R>(_ closure: @escaping (R) -> Void) -> (R) -> Void { { parameter in
            if self.isCurrentQueue {
                closure(parameter)
            } else {
                self.async {
                    closure(parameter)
                }
            }
        }
    }

    /// Returns a bool indicating if this queue is the current queue
    var isCurrentQueue: Bool {
        let key = DispatchSpecificKey<Void>()

        setSpecific(key: key, value: ())
        defer { setSpecific(key: key, value: nil) }

        return DispatchQueue.getSpecific(key: key) != nil
    }

    /// Returns a bool indicating if this queue is the main queue
    var isMainQueue: Bool {
        let key = DispatchSpecificKey<Void>()

        setSpecific(key: key, value: ())
        defer { setSpecific(key: key, value: nil) }

        return DispatchQueue.main.getSpecific(key: key) != nil
    }
}

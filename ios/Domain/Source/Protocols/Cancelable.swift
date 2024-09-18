//
//  Cancelable.swift
//  Interfaces
//
//  Created by CSH on 27.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

/// A cancelable is an object that models something that can be cancelled.
/// A class implementing this protocol should call cancel on deinit as well.
public protocol Cancelable: NSObjectProtocol {
    func cancel()
}

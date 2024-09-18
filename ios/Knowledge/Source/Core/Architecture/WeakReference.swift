//
//  WeakReference.swift
//  Knowledge
//
//  Created by CSH on 21.01.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

final class WeakReference<T: AnyObject> {
    private(set) weak var value: T?

    init(_ value: T) {
        self.value = value
    }
}

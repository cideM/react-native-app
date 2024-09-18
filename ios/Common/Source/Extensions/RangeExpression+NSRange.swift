//
//  RangeExpression+NSRange.swift
//  Common
//
//  Created by Aamir Suhial Mir on 03.07.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public extension RangeExpression where Bound == String.Index {
    func nsRange<S: StringProtocol>(in string: S) -> NSRange { .init(self, in: string) }
}

//
//  Bundle+Tests.swift
//  KnowledgeTests
//
//  Created by CSH on 05.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

/// This class is just there to be used to find this Frameworks Bundle
internal final class EmptyClass { }

extension Bundle {

    static var tests: Bundle {
        Bundle(for: EmptyClass.self)
    }

}

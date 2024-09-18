//
//  DebuggerPlugin.swift
//  Knowledge
//
//  Created by Cornelius Horstmann on 27.01.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import UIKit

protocol DebuggerPlugin {
    var title: String { get }
    var description: String? { get }
    func viewController() -> UIViewController
}

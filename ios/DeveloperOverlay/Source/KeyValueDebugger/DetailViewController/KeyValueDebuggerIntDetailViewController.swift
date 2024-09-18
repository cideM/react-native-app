//
//  KeyValueDebuggerIntDetailViewController.swift
//  DeveloperOverlay
//
//  Created by CSH on 24.06.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit

class KeyValueDebuggerIntDetailViewController: KeyValueDebuggerStringDetailViewController {

    init(key: String, value: Int?, onChange: @escaping (Int) -> Void) {
        super.init(key: key, value: "\(value ?? 0)") { string in
            guard let int = Int(string) else { return }
            onChange(int)
        }
    }

}

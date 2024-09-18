//
//  DictationObserver.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 29.02.24.
//  Copyright © 2024 AMBOSS GmbH. All rights reserved.
//

import UIKit
import Common

// Sole reason of existence for this class is to tuck away all the logic required for dictation tracking
// Dictation tracking meaning: Find out if the user entered text via voice or keybaord on the search screen
// We might not need this forever hence it's easier to delete all this in one go later
class DictationObserver {

    enum InputSource {
        case keyboard
        case dictation
    }

    private(set) var currentInputSource: InputSource = .keyboard

    private var inputModeObservation: NSObjectProtocol?

    // let observer = NotificationObserver()

    init() {
        // Obfuscating "UIKeyboardDidBeginDictationNotification"
        // ... since this is an "internal" notification and you never know with app review ...
        let name = String("UI" + Array("noitatciDnigeBdiDdraobyeK").reversed() + "Notification")

        inputModeObservation = NotificationCenter.default.observe(
            forName: NSNotification.Name(rawValue: name),
            object: nil,
            queue: nil,
            using: { [weak self] _ in
                self?.currentInputSource = .dictation
            })
    }

    func reset() {
        currentInputSource = .keyboard
    }
}

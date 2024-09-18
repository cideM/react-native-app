//
//  MessageAction.swift
//  Common
//
//  Created by Mohamed Abdul-Hameed on 9/11/19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

public struct MessageAction {
    public let title: String
    public let style: Style

    /// Return a bool defining if the error was fully handled.
    /// This can be used to define if a presented error can be removed again.
    ///
    /// For example, if the device is in flight mode we could show an error with two actions:
    /// - "Go to Settings" would not resolve the error, since the user has to resolve it in the setting.
    /// - "Retry" would resolve the error, since the user suggests that with retrying. If the issue still occurs, we are just displaying the same error again.
    private let closure: (() -> Bool)

    /// Initializer for an action that doesn't to anything.
    /// - Parameter title: The title of the Action. This should describe what should happen.
    /// - Parameter style: The style, this action should be displayed.
    /// - Parameter closure: A closure, executing the action and returning a Bool describing if the error was fully handled.
    public init(title: String, style: Style, closure: @escaping () -> Bool) {
        self.title = title
        self.style = style
        self.closure = closure
    }

    /// Initializer for an action that doesn't to anything.
    /// - Parameter title: The title of the Action. This should describe what should happen.
    /// - Parameter style: The style, this action should be displayed.
    /// - Parameter handlesError: A bool, defining if this action handles the error.
    public init(title: String, style: Style, handlesError: Bool) {
        self.title = title
        self.style = style
        self.closure = { handlesError }
    }

    /// Executes the closure of the action and returns a Bool defining if the error was fully handled.
    /// Note: See `closure` for more details.
    @discardableResult
    public func execute() -> Bool {
        closure()
    }
}

public extension MessageAction {
    /// The style of the button.
    ///
    /// - normal: Normal button.
    /// - primary: The primary button we are expecting the user to click.
    /// - link: A button that is styled like a hyperlink.
    enum Style {
        case normal
        case primary
        case link
    }
}

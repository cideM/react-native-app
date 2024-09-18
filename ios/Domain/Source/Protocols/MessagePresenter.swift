//
//  ErrorPresenter.swift
//  Knowledge
//
//  Created by Mohamed Abdul-Hameed on 9/11/19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

/// A type representing an error presenter than can present errors in any specific way.
///
/// Any type that declares conformance to the `ErrorPresenter` protocol can be used to present a `PresentableError`.
///
/// A `PresentableError` can be presented in any way, that way is defiend by the implementing class. You can create a concrete class that implements this protocol and present errors as console logs or maybe as alert view controllers or analytics or whatever you want.
public protocol MessagePresenter: AnyObject {
    /// A method to present an error in a certain way. That way is defined by the implementing class.
    ///
    /// - Parameters:
    ///   - error: The error to display its information.
    ///   - actions: The buttons of to display along with the error's information.
    func present(_ message: PresentableMessageType, actions: [MessageAction])
}

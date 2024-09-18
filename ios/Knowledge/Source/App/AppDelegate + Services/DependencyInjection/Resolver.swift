//
//  Resolver.swift
//  Knowledge
//
//  Created by CSH on 13.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import DIKit

// This function and typealiases remove the strict dependency to DIKit in most places of the application and will enable us to just depend on the functionality of DIKit that it's actual implementation.

func resolve<T>() -> T { DependencyContainer.shared.resolve() }
typealias Inject = DIKit.Inject
typealias LazyInject = DIKit.LazyInject
typealias OptionalInject = DIKit.OptionalInject

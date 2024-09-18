//
//  DependencyContainer+Factory.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 10.12.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import DIKit

extension DependencyContainer {
    static var builder = module {
        single { SupportRequestFactory() as SupportRequestFactory }
        factory { HTMLContentSizeCalculator() as HTMLContentSizeCalculatorType }
    }
}

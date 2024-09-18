//
//  DependencyContainer+DeepLinkService.swift
//  Knowledge
//
//  Created by Vedran Burojevic on 11/09/2020.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import DIKit

extension DependencyContainer {
    static var deepLinkService = module {
        single { DeepLinkService() as DeepLinkServiceType }
    }
}

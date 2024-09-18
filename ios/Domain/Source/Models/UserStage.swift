//
//  UserStage.swift
//  LoginAndSignup
//
//  Created by CSH on 06.02.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Foundation

// sourcery: fixture:
public enum UserStage: String, CaseIterable, Codable {
    case physician
    case clinic
    case preclinic
}

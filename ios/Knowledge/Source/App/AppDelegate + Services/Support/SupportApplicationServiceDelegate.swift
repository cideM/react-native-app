//
//  SupportApplicationServiceDelegate.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 19.04.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

protocol SupportApplicationServiceDelegate: AnyObject {
    func feedbackSubmitted(feedbackText: String)
}

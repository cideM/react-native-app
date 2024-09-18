//
//  FeedbackIntention.swift
//  Interfaces
//
//  Created by Mohamed Abdul Hameed on 17.02.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

// sourcery: fixture:
public enum FeedbackIntention: String, CaseIterable, Codable {
    case languageIssue = "language_issue"
    case incorrectContent = "incorrect_content"
    case missingContent = "missing_content"
    case technicalIssue = "technical_issue"
    case media
    case productFeedback = "product_feedback"
    case praise
}

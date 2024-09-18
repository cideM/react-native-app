//
//  NotificationCenterTests.swift
//  CommonTests
//
//  Created by Cornelius Horstmann on 04.11.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import XCTest
import Domain

class NotificationCenterTests: XCTestCase {

    var notificationCenter: NotificationCenter!

    override func setUp() {
        notificationCenter = NotificationCenter()
    }

    func testObserveNotificationForNameReturnsTheSameObject() {
        let name = NSNotification.Name("spec_notification_name")
        let sentNotification = Notification(name: name, object: nil, userInfo: nil)

        let notificationWasObservedExpectation = expectation(description: "notification was observed")
        let cancelable = notificationCenter.observe(forName: name, object: nil, queue: nil) { notification in
            XCTAssertEqual(sentNotification, notification)
            notificationWasObservedExpectation.fulfill()
        }
        _ = cancelable
        notificationCenter.post(sentNotification)

        waitForExpectations(timeout: 0.1)
    }

    func testObserveNotificationForNameStopsObservingWhenCanceled() {
        let name = NSNotification.Name("spec_notification_name")
        let sentNotification = Notification(name: name, object: nil, userInfo: nil)

        let notificationWasObservedExpectation = expectation(description: "notification was not observed")
        notificationWasObservedExpectation.isInverted = true
        _ = notificationCenter.observe(forName: name, object: nil, queue: nil) { _ in
            notificationWasObservedExpectation.fulfill()
        }
        notificationCenter.post(sentNotification)

        waitForExpectations(timeout: 0.5)
    }

    func testObserveNotificationRepresentableReturnsTheSameObject() {
        let sentNotification = TestNotification()

        let notificationWasObservedExpectation = expectation(description: "notification was observed")
        let cancelable = notificationCenter.observe(for: TestNotification.self, object: nil, queue: nil) { notification in
            XCTAssertIdentical(sentNotification, notification)
            notificationWasObservedExpectation.fulfill()
        }
        _ = cancelable

        notificationCenter.post(sentNotification, sender: nil)
        waitForExpectations(timeout: 0.5)
    }

    func testObserveNotificationRepresentableStopsObservingWhenCanceled() {
        let sentNotification = TestNotification()

        let notificationWasObservedExpectation = expectation(description: "notification was observed")
        notificationWasObservedExpectation.isInverted = true

        _ = notificationCenter.observe(for: TestNotification.self, object: nil, queue: nil) { _ in
            notificationWasObservedExpectation.fulfill()
        }

        notificationCenter.post(sentNotification, sender: nil)
        waitForExpectations(timeout: 0.5)
    }
}

private class TestNotification: AutoNotificationRepresentable {}

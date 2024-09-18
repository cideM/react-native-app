//
//  DeepLinkServiceTests.swift
//  KnowledgeTests
//
//  Created by Vedran Burojevic on 10/09/2020.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import XCTest

class DeepLinkServiceTests: XCTestCase {

    private var deepLinkService: DeepLinkServiceType!
    private var deepLinkServiceDelegate: DeepLinkServiceDelegateMock!
    private var remoteConfigRepository: RemoteConfigRepositoryTypeMock!

    private let webpageURL = URL(string: "https://www.amboss.com/de/library#xid=bH0HKh&anker=Zf974d8cff01b469f038157cfd85da31c")!

    override func setUp() {

        remoteConfigRepository = RemoteConfigRepositoryTypeMock(searchAdConfig: SearchAdConfig(), areMonographsEnabled: false)
        deepLinkService = DeepLinkService(remoteConfigRepository: remoteConfigRepository)
        deepLinkServiceDelegate = DeepLinkServiceDelegateMock()
        deepLinkService.delegate = deepLinkServiceDelegate
    }

    func testDeepLinkServiceDelegateDidReceiveDeepLinkWhenNotDeferring() {
        deepLinkService.deferDeepLinks = false
        deepLinkService.handleWebpageURL(webpageURL)
        XCTAssertEqual(deepLinkServiceDelegate.didReceiveDeepLinkCallCount, 1)
    }

    func testDeepLinkServiceDelegateDidReceiveDeepLinkWhenDeferring() {
        deepLinkService.deferDeepLinks = true
        deepLinkService.handleWebpageURL(webpageURL)
        XCTAssertEqual(deepLinkServiceDelegate.didReceiveDeepLinkCallCount, 0)
    }

    func testDeepLinkServiceDelegateDidReceiveDeferredDeepLink() {
        deepLinkService.deferDeepLinks = true
        deepLinkService.handleWebpageURL(webpageURL)
        XCTAssertEqual(deepLinkServiceDelegate.didReceiveDeepLinkCallCount, 0)

        deepLinkService.deferDeepLinks = false
        XCTAssertEqual(deepLinkServiceDelegate.didReceiveDeepLinkCallCount, 1)
    }

    func testDeeplinkServiceHandlesMonographURLsIfTheFeatureIsEnabled() {
        deepLinkService.deferDeepLinks = false
        remoteConfigRepository.areMonographsEnabled = true
        deepLinkServiceDelegate.didReceiveDeepLinkHandler = { deeplink in
            switch deeplink {
            case .monograph: break
            default: XCTFail()
            }
        }
        let url = URL(string: "https://next.amboss.com/us/pharma/ramipril")!
        XCTAssertTrue(deepLinkService.handleWebpageURL(url))
    }

    func testDeeplinkServiceDoesNotHandleMonographURLsIfTheFeatureIsDisabled() {
        deepLinkService.deferDeepLinks = false
        remoteConfigRepository.areMonographsEnabled = false
        deepLinkServiceDelegate.didReceiveDeepLinkHandler = { deeplink in
            switch deeplink {
            case .unsupported:
                break // "unsupported" allows the user to view the link in an "in app" browser
            default:
                XCTFail()
            }
        }
        let url = URL(string: "https://next.amboss.com/us/pharma/ramipril")!
        XCTAssertTrue(deepLinkService.handleWebpageURL(url))
    }
}

//
//  LearningCardDeeplinkTest.swift
//  KnowledgeTests
//
//  Created by Maksim Tuzhilin on 29.07.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

// swiftlint:disable force_unwrapping

@testable import Domain
import XCTest

class LearningCardDeeplinkTest: XCTestCase {

    func testIncorrectLearningCardDeepLink() {
        let links: [String] = [
            "http://example.com",
            "https://example.com",
            "http://amboss.com",
            "https://www.youtube.com/watch?v=EO33hwzJavA",
            "https://www.annfammed.org/content/16/3/261",
            "https://www.amboss.com/de/home-studientelegramm"
        ]
        for link in links {
            XCTAssertNil(LearningCardDeeplink(url: URL(string: link)!), "Link \(link) should be incorrect.")
        }
    }

    func testThatLegacyLinksAreCorrectlyParsed() {
        let cases: [String: LearningCardDeeplink] = [
            "https://www.amboss.com/de/library#xid=7604mS&anker=Za3d6fb76fc37086f714718190afa4368": LearningCardDeeplink(learningCard: "7604mS", anchor: "Za3d6fb76fc37086f714718190afa4368"),
            "https://amboss.miamed.de/library#xid=kO0msT&anker=Z90b619609cb187c9b358e45ee6ab3a94": LearningCardDeeplink(learningCard: "kO0msT", anchor: "Z90b619609cb187c9b358e45ee6ab3a94"),
            "https://amboss.miamed.de/library#xid=jp0_6S&anker=Za4c9645db1a97ac870e8c9f9c99dc0ee": LearningCardDeeplink(learningCard: "jp0_6S", anchor: "Za4c9645db1a97ac870e8c9f9c99dc0ee"),
            "https://www.amboss.com/de/library#xid=rS0faf": LearningCardDeeplink(learningCard: "rS0faf"),
            "https://www.amboss.com/de/library#xid=rS0faf&anker=T-069i": LearningCardDeeplink(learningCard: "rS0faf", anchor: "T-069i"),
            "https://www.amboss.com/de/library#xid=bH0HKh&anker=Zf974d8cff01b469f038157cfd85da31c": LearningCardDeeplink(learningCard: "bH0HKh", anchor: "Zf974d8cff01b469f038157cfd85da31c"),
            "https://www.amboss.com/de/library#xid=bH0HKh&anker=Ze10c2abac13330b08edb8bfa875e618e": LearningCardDeeplink(learningCard: "bH0HKh", anchor: "Ze10c2abac13330b08edb8bfa875e618e"),
            "https://www.amboss.com/de/library#xid=gG0FAh&anker=Z24ad35d7c2b2b1bef4fc9b9fd7f10875": LearningCardDeeplink(learningCard: "gG0FAh", anchor: "Z24ad35d7c2b2b1bef4fc9b9fd7f10875"),
            "https://www.amboss.com/de/library#xid=DF0143&term=bronchitis": LearningCardDeeplink(learningCard: "DF0143"), // terms are not supported
            "https://www.amboss.com/de/library#xid=rS0faf&anker=T-069i&question=s0athQ": LearningCardDeeplink(learningCard: "rS0faf", anchor: "T-069i", question: "s0athQ"),
            "https://www.amboss.com/us/library#xid=Og0Iv2&anker=Z6deecfc16edc5ff8ed1ad2f586f55305": LearningCardDeeplink(learningCard: "Og0Iv2", anchor: "Z6deecfc16edc5ff8ed1ad2f586f55305")
        ]
        for (url, expected) in cases {
            let deeplink = LearningCardDeeplink(url: URL(string: url)!)
            XCTAssertEqual(deeplink, expected)
        }
    }

    func testThatNextLinksAreCorrectlyParsed() {
        let cases: [String: LearningCardDeeplink] = [
            "https://next.amboss.com/us/article/xo0EVS": LearningCardDeeplink(learningCard: "xo0EVS"),
            "https://next.amboss.com/us/article/xo0EVS#lg1vvT0": LearningCardDeeplink(learningCard: "xo0EVS", anchor: "lg1vvT0"),
            "https://next.amboss.com/de/article/7N04cg#Z2ad72336313c69c3df64280819ca8d74": LearningCardDeeplink(learningCard: "7N04cg", anchor: "Z2ad72336313c69c3df64280819ca8d74"),
            "https://next.amboss.com/us/article/Op0IpS#Zcb1d7e5d84a3ae9bbb461b5d04e9959f": LearningCardDeeplink(learningCard: "Op0IpS", anchor: "Zcb1d7e5d84a3ae9bbb461b5d04e9959f")
        ]
        for (url, expected) in cases {
            let deeplink = LearningCardDeeplink(url: URL(string: url)!)
            XCTAssertEqual(deeplink, expected)
        }
    }

    func testThatAppToWebDeeplinksAreCorrectlyParsed() {
        let cases: [String: LearningCardDeeplink] = [
            "https://www.amboss.com/de/app2web/library/wS0hbf/_6c5nW0/Txa6D5?p=iOS&pv=14.4&an=broccoli&av=v1.6.6b1&token=8331573c8cda199df3cd3cc379df004c": LearningCardDeeplink(learningCard: "wS0hbf", anchor: "_6c5nW0", question: "Txa6D5"),
            "https://amboss.com/us/app2web/library/Op0IpS/Zcb1d7e5d84a3ae9bbb461b5d04e9959f/8C2OFPa": LearningCardDeeplink(learningCard: "Op0IpS", anchor: "Zcb1d7e5d84a3ae9bbb461b5d04e9959f", question: "8C2OFPa")
        ]
        for (url, expected) in cases {
            let deeplink = LearningCardDeeplink(url: URL(string: url)!)
            XCTAssertEqual(deeplink, expected)
        }
    }
}

extension LearningCardDeeplink {
    init(learningCard learningCardString: String, anchor anchorString: String? = nil, sourceAnchor sourceAnchorString: String? = nil, question questionString: String? = nil) {
        let learningCard = LearningCardIdentifier(value: learningCardString)
        let anchor = anchorString.map { LearningCardAnchorIdentifier(value: $0) }
        let sourceAnchor = sourceAnchorString.map { LearningCardAnchorIdentifier(value: $0) }
        let question = questionString.map { QBankQuestionIdentifier(value: $0) }
        self.init(learningCard: learningCard, anchor: anchor, particle: nil, sourceAnchor: sourceAnchor, question: question)
    }
}

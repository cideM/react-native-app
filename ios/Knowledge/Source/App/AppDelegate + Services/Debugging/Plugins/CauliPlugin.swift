//
//  CauliPlugin.swift
//  Knowledge
//
//  Created by Cornelius Horstmann on 27.01.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

#if Debug || QA

 import Cauliframework
 import UIKit

 class CauliPlugin: DebuggerPlugin {
    let title = "Cauli"
    let description: String? = "Network Debugger"

    private let cauli: Cauli

    init() {
        let ambossRecordSelector = RecordSelector { record in
            if record.designatedRequest.url?.host == nil { return false }
            return true // host.contains("medicuja") || host.contains("amboss")
        }

        let configuration = Cauliframework.Configuration(recordSelector: ambossRecordSelector, enableShakeGesture: false, storageCapacity: .records(100))
        let florets: [Floret] = [
            HTTPBodyStreamFloret(),
            InspectorFloret(formatter: CustomInspectorFloretFormatter()),
            CauliPlugin.qaFloret(),
            CauliPlugin.stagingFloret(),
            CauliBranchSelectionFloret(),
            CatifyFloret()
        ]
        self.cauli = Cauli(florets, configuration: configuration)
        self.cauli.run()
    }

    func viewController() -> UIViewController {
        cauli.viewController()
    }
}

fileprivate extension CauliPlugin {

    static let graphQLPattern = "www.amboss.com/(de|us)/api/graphql"
    static let restPattern = "mobile-api-(de|us).amboss.com"

    static func qaFloret() -> Floret {
        let deURLQAREST = "qa.vesikel.de.qa.medicuja.de"
        let usURLQAREST = "qa.vesikel.us.qa.medicuja.de"
        let targetQAREST = AppConfiguration.shared.appVariant == .wissen ? deURLQAREST : usURLQAREST
        let modifierQAREST = urlModifierFor(url: restPattern, target: targetQAREST)

        let deURLQAGraphQL = "master.graphql-gateway.de.qa.medicuja.de/graphql"
        let usURLQAGraphQL = "master.graphql-gateway.us.qa.medicuja.de/graphql"
        let targetQAGraphQL = AppConfiguration.shared.appVariant == .wissen ? deURLQAGraphQL : usURLQAGraphQL
        let modifierQAGraphQL = urlModifierFor(url: graphQLPattern, target: targetQAGraphQL)

        let floret = FindReplaceFloret(willRequestModifiers: [modifierQAREST, modifierQAGraphQL], name: "Use QA servers")
        floret.enabled = false
        return floret
    }

    static func stagingFloret() -> Floret {
        let deURLStagingREST = "mobile-api-de.labamboss.com"
        let usURLStagingREST = "mobile-api-us.labamboss.com"
        let targetStagingREST = AppConfiguration.shared.appVariant == .wissen ? deURLStagingREST : usURLStagingREST
        let modifierStagingREST = urlModifierFor(url: restPattern, target: targetStagingREST)

        let deURLStagingGraphQL = "www.labamboss.com/de/api/graphql"
        let usURLStagingGraphQL = "www.labamboss.com/us/api/graphql"
        let targetStagingGraphQL = AppConfiguration.shared.appVariant == .wissen ? deURLStagingGraphQL : usURLStagingGraphQL
        let modifierStagingGraphQL = urlModifierFor(url: graphQLPattern, target: targetStagingGraphQL)

        let floret = FindReplaceFloret(willRequestModifiers: [modifierStagingREST, modifierStagingGraphQL], name: "Use Staging servers")
        floret.enabled = false
        return floret
    }

    static func urlModifierFor(url regex: String, target template: String) -> RecordModifier {
        let expresssion = try! NSRegularExpression(pattern: regex, options: []) // swiftlint:disable:this force_try
        let modifier = RecordModifier.modifyUrl(expression: expresssion, template: template)
        return modifier
    }
}

class CustomInspectorFloretFormatter: InspectorFloretFormatterType {
    private let fallbackFormatter = InspectorFloretFormatter()
    func listFormattedData(for record: Cauliframework.Record) -> Cauliframework.InspectorFloret.RecordListFormattedData {
        let formattedData = fallbackFormatter.listFormattedData(for: record)
        guard let operation = record.designatedRequest.allHTTPHeaderFields?["X-APOLLO-OPERATION-NAME"] else {
            return formattedData
        }
        return Cauliframework.InspectorFloret.RecordListFormattedData(method: "GRAPHQL", path: operation, time: formattedData.time, status: "", statusColor: formattedData.statusColor)
    }

    func recordMatchesQuery(record: Cauliframework.Record, query: String) -> Bool {
        let matches = fallbackFormatter.recordMatchesQuery(record: record, query: query)
        guard let operation = record.designatedRequest.allHTTPHeaderFields?["X-APOLLO-OPERATION-NAME"] else { return matches }
        return matches || operation.range(of: query, options: String.CompareOptions.caseInsensitive) != nil
    }
}

#endif

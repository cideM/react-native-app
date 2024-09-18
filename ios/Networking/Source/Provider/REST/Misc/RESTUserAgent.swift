//
//  RESTUserAgent.swift
//  Networking
//
//  Created by Vedran Burojevic on 02/09/2020.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

struct RESTUserAgent {
    let platform = "iOS"
    let application: String /// AMBOSS-Knowledge or AMBOSS-Bibliothek
    let buildVersion = RESTUserAgent.buildVersion
    let deviceModel = RESTUserAgent.deviceModel
    let systemName = UIDevice.current.systemName
    let systemVersion = UIDevice.current.systemVersion

    var asString: String {
        "\(platform)/\(application)/\(buildVersion) (\(deviceModel); \(systemName)/\(systemVersion))"
    }

    private static var buildVersion: String {
        Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String // swiftlint:disable:this force_cast force_unwrapping
    }

    private static var deviceModel: String {
        var systemInfo = utsname.init()
        uname(&systemInfo)

        var identifier = ""

        let mirror = Mirror(reflecting: systemInfo.machine)
        for child in mirror.children {
            let currentValue = child.value as! Int8 // swiftlint:disable:this force_cast

            guard currentValue != 0 else { break }

            identifier.append(String(UnicodeScalar(UInt8(currentValue))))
        }

        return identifier
    }
}

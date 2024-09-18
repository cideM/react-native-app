//
//  PriceAndPackage.swift
//  Interfaces
//
//  Created by Silvio Bulla on 10.01.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct PriceAndPackage {
    public let packageSize: PackageSize?
    public let amount: String
    public let unit: String
    public let pharmacyPrice: String?
    public let recommendedRetailPrice: String?

    /// Represents the package size value as a formatted string.
    public var packageSizeDescription: String {

        var packageSizeString: String = ""
        if let packageSize = packageSize {
            switch packageSize {
            case .n1: packageSizeString = "N1"
            case .n2: packageSizeString = "N2"
            case .n3: packageSizeString = "N3"
            case .ktp: packageSizeString = "KTP"
            case .notApplicable: packageSizeString = ""
            }
        }

        let separator = packageSizeString.isEmpty ? "" : " - "
        let packageSizeStringValue = packageSizeString + separator + amount + " \(unit)"
        return packageSizeStringValue
    }

    /// Represents the correct price value.
    public var priceDescription: String {
        let price = pharmacyPrice ?? recommendedRetailPrice ?? ""
        return price
    }

    /// Represents if the price should be displayed with a superscript explanation.
    public var hasSuperscript: Bool {
        guard let price = pharmacyPrice, !price.isEmpty else {
            return !(recommendedRetailPrice?.isEmpty ?? true)
        }
        return false
    }

    /// Represents if the price should be displayed with a superscript explanation.
    public var hasKTP: Bool {
        packageSize == .ktp
    }

    // sourcery: fixture:
    public init(packageSize: PackageSize?, amount: String, unit: String, pharmacyPrice: String?, recommendedRetailPrice: String?) {
        self.packageSize = packageSize
        self.amount = amount
        self.unit = unit
        self.pharmacyPrice = pharmacyPrice
        self.recommendedRetailPrice = recommendedRetailPrice
    }
}

// sourcery: fixture:
public enum PackageSize {
    case n1 // swiftlint:disable:this identifier_name
    case n2 // swiftlint:disable:this identifier_name
    case n3 // swiftlint:disable:this identifier_name
    case ktp
    case notApplicable
}

// sourcery: fixture:
public enum PackageSizeSortingOrder: String {
    case ascending
    case mixed
}

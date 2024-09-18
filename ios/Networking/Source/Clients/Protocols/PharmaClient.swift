//
//  PharmaClient.swift
//  Networking
//
//  Created by Manaf Alabd Alrahim on 01.08.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain

/// @mockable
public protocol PharmaClient {

    /// This method returns information regarding a specific agent and drug IDs.
    /// - Parameters:
    ///   - substanceIdentifier: The agent identifier we are requesting data for.
    ///   - drugIdentifier: The drug  identifier we are requesting data for.
    ///   - completion: A completion handler that will be called with result.
    func getPharmaCard(for substanceIdentifier: SubstanceIdentifier, drugIdentifier: DrugIdentifier, sorting: PackageSizeSortingOrder, timeout: TimeInterval, cachePolicy: URLRequest.CachePolicy, completion: @escaping Completion<PharmaCard, NetworkError<EmptyAPIError>>)

    /// This method return information regarding a specific agent ID.
    /// - Parameters:
    ///   - substanceIdentifier: The agent identifier we are requesting data for.
    ///   - completion: A completion handler that will be called with result.
    func getSubstance(for substanceIdentifier: SubstanceIdentifier, timeout: TimeInterval, cachePolicy: URLRequest.CachePolicy, completion: @escaping Completion<Substance, NetworkError<EmptyAPIError>>)

    /// This method return information regarding a specific drug ID.
    /// - Parameters:
    ///   - drugIdentifier: The drug  identifier we are requesting data for.
    ///   - completion: A completion handler that will be called with result.
    func getDrug(for drugIdentifier: DrugIdentifier, sorting: PackageSizeSortingOrder, timeout: TimeInterval, cachePolicy: URLRequest.CachePolicy, completion: @escaping Completion<Drug, NetworkError<EmptyAPIError>>)

    /// This method return information regarding a specific drug ID.
    /// - Parameters:
    ///   - dosagerIdentifier: The dosage identifier we are requesting data for.
    ///   - completion: A completion handler that will be called with result.
    func getDosage(for dosagerIdentifier: DosageIdentifier, timeout: TimeInterval?, cachePolicy: URLRequest.CachePolicy, completion: @escaping Completion<Dosage, NetworkError<EmptyAPIError>>)

    /// This method returns a list of Pharma offline databases.
    /// - Parameters:
    ///   - majorDBVersion: The current Pharma database major version.
    ///   - completion: A completion handler that will be called with result.
    func getPharmaDatabases(for majorDBVersion: Int, completion: @escaping Completion<[PharmaUpdate], NetworkError<EmptyAPIError>>)

    /// This method returns a list of Pharma offline databases.
    /// - Parameters:
    ///   - monographIdentifier: The monograph identifier we are requesting the data for.
    ///   - completion: A completion handler that will be called with result.
    func getMonograph(for monographIdentifier: MonographIdentifier, completion: @escaping Completion<Monograph, NetworkError<EmptyAPIError>>)
}

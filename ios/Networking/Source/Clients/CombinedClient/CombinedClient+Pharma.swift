//
//  CombinedClient+Pharma.swift
//  Networking
//
//  Created by Manaf Alabd Alrahim on 06.09.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain
import KnowledgeGraphQLEntities

extension CombinedClient: PharmaClient {

    public func getPharmaCard(for substanceIdentifier: SubstanceIdentifier,
                              drugIdentifier: DrugIdentifier,
                              sorting: PackageSizeSortingOrder,
                              timeout: TimeInterval,
                              cachePolicy: URLRequest.CachePolicy,
                              completion: @escaping Completion<PharmaCard, NetworkError<EmptyAPIError>>) {

        graphQlClient.getPharmaCard(for: substanceIdentifier.value,
                                    drugIdentifier: drugIdentifier.value,
                                    sorting: GraphQLEnum(PriceAndPackageSorting(order: sorting)),
                                    timeout: timeout,
                                    cachePolicy: cachePolicy,
                                    completion: postprocess(authorization: self.authorization) { result in
            switch result {
            case .success(let data):
                let substanceData = data.ambossSubstance
                let drugData = data.pharmaDrug
                let drugReferences = data.ambossSubstance.drugs.map { DrugReference(from: $0) }

                let prescriptions: [Prescription] = drugData.prescriptions.compactMap {
                    guard let val = $0.value else { return nil }
                    return Prescription(status: val)
                }

                // This should never happen but there is not type for an "non empty" array ...
                guard let basedOnID: KnowledgeGraphQLEntities.ID = substanceData.drugs.first?.id else {
                    completion(.failure(.other("Subtance must contain at lease one drug", code: .badServerResponse)))
                    return
                }

                let basedOn = DrugIdentifier(value: basedOnID)
                let sections = drugData.sections.compactMap { PharmaSection(from: $0) }
                let substance = Substance(id: SubstanceIdentifier(value: substanceData.id),
                                          name: substanceData.name,
                                          drugReferences: drugReferences,
                                          pocketCard: substanceData.pocketCard(),
                                          basedOn: basedOn)

                let pricesAndPackages = drugData.priceAndPackageInfo.map {
                    PriceAndPackage(packageSize: PackageSize(from: $0.packageSize?.value),
                                    amount: $0.amount,
                                    unit: $0.unit,
                                    pharmacyPrice: $0.pharmacyPrice,
                                    recommendedRetailPrice: $0.recommendedRetailPrice)
                }

                let drug = Drug(eid: DrugIdentifier(value: drugData.id),
                                substanceID: SubstanceIdentifier(value: substanceData.id),
                                name: drugData.name,
                                atcLabel: drugData.atcLabel,
                                vendor: drugData.vendor,
                                prescriptions: prescriptions,
                                dosageForm: drugData.dosageForms,
                                sections: sections,
                                patientPackageInsertUrl: drugData.patientPackageInsertUrl,
                                prescribingInformationUrl: drugData.prescribingInformationUrl,
                                publishedAt: drugData.publishedAt,
                                pricesAndPackages: pricesAndPackages)

                completion(.success(PharmaCard(substance: substance, drug: drug)))
            case .failure(let error): completion(.failure(error))
            }
                                    }
        )
    }

    public func getPharmaDrug(for identifier: DrugIdentifier,
                              timeout: TimeInterval,
                              cachePolicy: URLRequest.CachePolicy,
                              completion: @escaping Completion<Drug, NetworkError<EmptyAPIError>>) {

    }

    public func getSubstance(for substanceIdentifier: SubstanceIdentifier,
                             timeout: TimeInterval,
                             cachePolicy: URLRequest.CachePolicy,
                             completion: @escaping Completion<Substance, NetworkError<EmptyAPIError>>) {

        graphQlClient.getAgent( for: substanceIdentifier.value,
                                timeout: timeout,
                                cachePolicy: cachePolicy,
                                completion: postprocess(authorization: self.authorization) { result in

            switch result {
            case .success(let agentData):
                let drugReferences = agentData.drugs.map {
                    DrugReference(id: DrugIdentifier(value: $0.id),
                                  name: $0.name,
                                  vendor: $0.vendor,
                                  atcLabel: $0.atcLabel,
                                  prescriptions: $0.prescriptions.compactMap {
                        guard let val = $0.value else { return nil }
                        return Prescription(status: val)
                                  },
                                  applicationForms: $0.applicationForms.compactMap {
                        guard let val = $0.value else { return nil }
                        return ApplicationForm(pharmaApplicationForm: val)
                                  }, pricesAndPackages: $0.priceAndPackageInfo.map {

                        PriceAndPackage(packageSize: PackageSize(from: $0.packageSize?.value),
                                        amount: $0.amount,
                                        unit: $0.unit,
                                        pharmacyPrice: $0.pharmacyPrice,
                                        recommendedRetailPrice: $0.recommendedRetailPrice)
                                  })
                }

                // Pocket card is not fetched in the query which is used here and also not required
                // since the pharma screens do an initial fetch via the "pharmaCard" query
                // the "pocketCard" is cached afterwards and reused.
                // TODO: Return error in case `drugs` array is empty
                let basedOn = DrugIdentifier(value: agentData.drugs.first!.id) // swiftlint:disable:this force_unwrapping
                let agent = Substance(id: SubstanceIdentifier(value: agentData.id),
                                      name: agentData.name,
                                      drugReferences: drugReferences,
                                      pocketCard: nil,
                                      basedOn: basedOn)

                completion(.success(agent))

            case .failure(let error): completion(.failure(error))
            }
                                })
    }

    public func getDrug(for drugIdentifier: DrugIdentifier,
                        sorting: PackageSizeSortingOrder,
                        timeout: TimeInterval,
                        cachePolicy: URLRequest.CachePolicy,
                        completion: @escaping Completion<Drug, NetworkError<EmptyAPIError>>) {

        graphQlClient.getDrug(for: drugIdentifier.value,
                              sorting: GraphQLEnum(PriceAndPackageSorting(order: sorting)),
                              timeout: timeout,
                              cachePolicy: cachePolicy,
                              completion: postprocess(authorization: self.authorization) { result in
            switch result {
            case .success(let drugData):
                let prescriptions: [Prescription] = drugData.prescriptions.compactMap {
                    guard let val = $0.value else { return nil }
                    return Prescription(status: val)
                }
                let dosageForm = drugData.dosageForms

                let sections = drugData.sections.compactMap {
                    PharmaSection(title: $0.title,
                                  text: $0.text,
                                  position: $0.position)
                }

                let pricesAndPackages = drugData.priceAndPackageInfo.map {
                    PriceAndPackage(packageSize: PackageSize(from: $0.packageSize?.value),
                                    amount: $0.amount,
                                    unit: $0.unit,
                                    pharmacyPrice: $0.pharmacyPrice,
                                    recommendedRetailPrice: $0.recommendedRetailPrice)
                }

                let drug = Drug(eid: DrugIdentifier(value: drugData.id),
                                substanceID: SubstanceIdentifier(value: drugData.agentId),
                                name: drugData.name,
                                atcLabel: drugData.atcLabel,
                                vendor: drugData.vendor,
                                prescriptions: prescriptions,
                                dosageForm: dosageForm,
                                sections: sections,
                                patientPackageInsertUrl: drugData.patientPackageInsertUrl,
                                prescribingInformationUrl: drugData.prescribingInformationUrl,
                                publishedAt: drugData.publishedAt,
                                pricesAndPackages: pricesAndPackages)

                completion(.success(drug))
            case .failure(let error): completion(.failure(error))
            }
                              })
    }

    public func getDosage(for dosagerIdentifier: DosageIdentifier,
                          timeout: TimeInterval?,
                          cachePolicy: URLRequest.CachePolicy,
                          completion: @escaping Completion<Dosage, NetworkError<EmptyAPIError>>) {

        graphQlClient.getDosage(for: dosagerIdentifier.value,
                                timeout: timeout,
                                cachePolicy: cachePolicy,
                                completion: postprocess(authorization: self.authorization) { result in
            switch result {
            case .success(let dosageData):
                let dosageId = DosageIdentifier(value: dosageData.id)
                var ambossSubstanceLink: AmbossSubstanceLink?

                if let substanceLink = dosageData.ambossSubstanceLink {
                    let substanceName = substanceLink.ambossSubstance.name
                    if let monograph = substanceLink.monograph?.id {
                        let monographId = MonographIdentifier(value: monograph)
                        let monographDeeplink = MonographDeeplink(monograph: monographId, anchor: nil)
                        ambossSubstanceLink = AmbossSubstanceLink(id: substanceLink.ambossSubstance.id,
                                                                  name: substanceName,
                                                                  deeplink: .monograph(monographDeeplink))
                    } else {
                        let agent = SubstanceIdentifier(value: substanceLink.ambossSubstance.id)
                        let drug = DrugIdentifier(value: substanceLink.drug.id)
                        let pharmaDeeplink = PharmaCardDeeplink(substance: agent, drug: drug, document: nil)
                        ambossSubstanceLink = AmbossSubstanceLink(id: substanceLink.ambossSubstance.id,
                                                                  name: substanceName,
                                                                  deeplink: .pharmaCard(pharmaDeeplink))
                    }
                }

                let dosage = Dosage(id: dosageId,
                                    html: dosageData.content.html,
                                    ambossSubstanceLink: ambossSubstanceLink)

                completion(.success(dosage))

            case .failure(let error):
                completion(.failure(error))
            }
                                })
    }

    public func getPharmaDatabases(for majorDBVersion: Int,
                                   completion: @escaping Completion<[PharmaUpdate], NetworkError<EmptyAPIError>>) {

        graphQlClient.getPharmaDatabases(for: majorDBVersion,
                                         completion: postprocess(authorization: self.authorization) { result in
            switch result {
            case .success(let databases):

                let pharmaDatabases = databases.compactMap {

                    PharmaUpdate(version: Version(major: $0.major,
                                                  minor: $0.minor,
                                                  patch: $0.patch),
                                 size: $0.size,
                                 zippedSize: $0.zippedSize,
                                 url: $0.url,
                                 dateCreated: $0.dateCreated)
                }
                completion(.success(pharmaDatabases))

            case .failure(let error): completion(.failure(error))
            }
                                         })
    }

    public func getMonograph(for monographIdentifier: MonographIdentifier,
                             completion: @escaping Completion<Monograph, NetworkError<EmptyAPIError>>) {

        graphQlClient.getMonograph(for: monographIdentifier.value,
                                   completion: postprocess(authorization: self.authorization) { result in
            switch result {
            case .success(let monographData):

                let classification = MonographClassification(ahfsCode: monographData.classification.ahfsCode,
                                                             ahfsTitle: monographData.classification.ahfsTitle,
                                                             atcCode: monographData.classification.atcCode,
                                                             atcTitle: monographData.classification.atcTitle)

                let monograph = Monograph(id: MonographIdentifier(value: monographData.id),
                                          title: monographData.title,
                                          classification: classification,
                                          generic: monographData.generic,
                                          publishedAt: monographData.publishedAt,
                                          html: monographData.html)

                completion(.success(monograph))

            case .failure(let error): completion(.failure(error))
            }
                                   })
    }
}

fileprivate extension PharmaCardQuery.Data.AmbossSubstance {

    func pocketCard() -> Domain.PocketCard? {
        let groups = (self.pocketCard?.groups ?? []).map { group in
            let sections = group.sections.map { section in
                Domain.PocketCard.Section(title: section.title,
                                          anchor: section.anchor,
                                          content: section.content)
            }
            return Domain.PocketCard.Group(title: group.title,
                                           anchor: group.anchor,
                                           sections: sections)
        }
        let pocketCard = groups.isEmpty ? nil : Domain.PocketCard(groups: groups)
        return pocketCard
    }
}

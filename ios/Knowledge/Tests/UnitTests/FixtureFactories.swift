// Generated using Sourcery 2.0.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable
import Foundation
import FixtureFactory
@testable import Domain
@testable import Knowledge_DE

extension AmbossSubscriptionState: Fixture {
    public static func fixture() -> AmbossSubscriptionState {
        fixture(canPurchaseInAppSubscription: .fixture(), hasActiveInAppSubscription: .fixture())
    }
    public static func fixture(canPurchaseInAppSubscription: Bool = .fixture(), hasActiveInAppSubscription: Bool = .fixture()) -> AmbossSubscriptionState {
        AmbossSubscriptionState(canPurchaseInAppSubscription: canPurchaseInAppSubscription, hasActiveInAppSubscription: hasActiveInAppSubscription)
    }
}

extension AmbossSubstanceLink: Fixture {
    public static func fixture() -> AmbossSubstanceLink {
        fixture(id: .fixture(), name: .fixture(), deeplink: .fixture())
    }
    public static func fixture(id: String = .fixture(), name: String? = .fixture(), deeplink: Deeplink? = .fixture()) -> AmbossSubstanceLink {
        AmbossSubstanceLink(id: id, name: name, deeplink: deeplink)
    }
}

extension ArticleSearchItem: Fixture {
    public static func fixture() -> ArticleSearchItem {
        fixture(title: .fixture(), body: .fixture(), deepLink: .fixture(), children: .fixture(), resultUUID: .fixture(), targetUUID: .fixture())
    }
    public static func fixture(title: String = .fixture(), body: String? = .fixture(), deepLink: LearningCardDeeplink = .fixture(), children: [ArticleSearchItem] = .fixture(), resultUUID: String = .fixture(), targetUUID: String = .fixture()) -> ArticleSearchItem {
        ArticleSearchItem(title: title, body: body, deepLink: deepLink, children: children, resultUUID: resultUUID, targetUUID: targetUUID)
    }
}

extension ArticleSearchViewItem: Fixture {
    public static func fixture() -> ArticleSearchViewItem {
        fixture(title: .fixture(), body: .fixture(), deeplink: .fixture(), resultIndex: .fixture(), children: .fixture(), targetUuid: .fixture())
    }
    public static func fixture(title: String = .fixture(), body: String? = .fixture(), deeplink: LearningCardDeeplink = .fixture(), resultIndex: Int = .fixture(), children: [ChildSearchResultViewItem] = .fixture(), targetUuid: String = .fixture()) -> ArticleSearchViewItem {
        ArticleSearchViewItem(title: title, body: body, deeplink: deeplink, resultIndex: resultIndex, children: children, targetUuid: targetUuid)
    }
}

extension Authorization: Fixture {
    public static func fixture() -> Authorization {
        fixture(token: .fixture(), user: .fixture())
    }
    public static func fixture(token: String = .fixture(), user: User = .fixture()) -> Authorization {
        Authorization(token: token, user: user)
    }
}

extension AutocompleteViewItem: Fixture {
    public static func fixture() -> AutocompleteViewItem {
        fixture(text: .fixture(), value: .fixture(), trackingData: .fixture())
    }
    public static func fixture(text: NSAttributedString? = .fixture(), value: String? = .fixture(), trackingData: SearchSuggestionItem = .fixture()) -> AutocompleteViewItem {
        AutocompleteViewItem(text: text, value: value, trackingData: trackingData)
    }
}

extension Autolink: Fixture {
    public static func fixture() -> Autolink {
        fixture(phrase: .fixture(), xid: .fixture(), score: .fixture(), anchor: .fixture())
    }
    public static func fixture(phrase: String = .fixture(), xid: LearningCardIdentifier = .fixture(), score: Int = .fixture(), anchor: LearningCardAnchorIdentifier = .fixture()) -> Autolink {
        Autolink(phrase: phrase, xid: xid, score: score, anchor: anchor)
    }
}

extension ChildSearchResultViewItem: Fixture {
    public static func fixture() -> ChildSearchResultViewItem {
        fixture(title: .fixture(), body: .fixture(), deeplink: .fixture(), level: .fixture(), sectionIndex: .fixture(), targetUuid: .fixture())
    }
    public static func fixture(title: String = .fixture(), body: String? = .fixture(), deeplink: Deeplink = .fixture(), level: Int = .fixture(), sectionIndex: Int = .fixture(), targetUuid: String = .fixture()) -> ChildSearchResultViewItem {
        ChildSearchResultViewItem(title: title, body: body, deeplink: deeplink, level: level, sectionIndex: sectionIndex, targetUuid: targetUuid)
    }
}

extension DeprecationItem: Fixture {
    public static func fixture() -> DeprecationItem {
        fixture(minVersion: .fixture(), maxVersion: .fixture(), type: .fixture(), platform: .fixture(), identifier: .fixture(), url: .fixture())
    }
    public static func fixture(minVersion: String = .fixture(), maxVersion: String = .fixture(), type: DeprecationType = .fixture(), platform: Platform = .fixture(), identifier: String = .fixture(), url: URL? = .fixture()) -> DeprecationItem {
        DeprecationItem(minVersion: minVersion, maxVersion: maxVersion, type: type, platform: platform, identifier: identifier, url: url)
    }
}

extension DiscoverAmbossConfig: Fixture {
    public static func fixture() -> DiscoverAmbossConfig {
        fixture(drugReferences: .fixture(), articleReferences: .fixture(), calculators: .fixture(), algorithms: .fixture())
    }
    public static func fixture(drugReferences: [Item] = .fixture(), articleReferences: [Item] = .fixture(), calculators: Item = .fixture(), algorithms: Item = .fixture()) -> DiscoverAmbossConfig {
        DiscoverAmbossConfig(drugReferences: drugReferences, articleReferences: articleReferences, calculators: calculators, algorithms: algorithms)
    }
}

extension DiscoverAmbossConfig.Item: Fixture {
    public static func fixture() -> DiscoverAmbossConfig.Item {
        fixture(title: .fixture(), deepLink: .fixture(), url: .fixture())
    }
    public static func fixture(title: String = .fixture(), deepLink: Deeplink = .fixture(), url: URL = .fixture()) -> DiscoverAmbossConfig.Item {
        DiscoverAmbossConfig.Item(title: title, deepLink: deepLink, url: url)
    }
}

extension Drug: Fixture {
    public static func fixture() -> Drug {
        fixture(eid: .fixture(), substanceID: .fixture(), name: .fixture(), atcLabel: .fixture(), vendor: .fixture(), prescriptions: .fixture(), dosageForm: .fixture(), sections: .fixture(), patientPackageInsertUrl: .fixture(), prescribingInformationUrl: .fixture(), publishedAt: .fixture(), pricesAndPackages: .fixture())
    }
    public static func fixture(eid: DrugIdentifier = .fixture(), substanceID: SubstanceIdentifier = .fixture(), name: String = .fixture(), atcLabel: String = .fixture(), vendor: String? = .fixture(), prescriptions: [Prescription] = .fixture(), dosageForm: [String] = .fixture(), sections: [PharmaSection] = .fixture(), patientPackageInsertUrl: String? = .fixture(), prescribingInformationUrl: String? = .fixture(), publishedAt: String? = .fixture(), pricesAndPackages: [PriceAndPackage] = .fixture()) -> Drug {
        Drug(eid: eid, substanceID: substanceID, name: name, atcLabel: atcLabel, vendor: vendor, prescriptions: prescriptions, dosageForm: dosageForm, sections: sections, patientPackageInsertUrl: patientPackageInsertUrl, prescribingInformationUrl: prescribingInformationUrl, publishedAt: publishedAt, pricesAndPackages: pricesAndPackages)
    }
}

extension DrugReference: Fixture {
    public static func fixture() -> DrugReference {
        fixture(id: .fixture(), name: .fixture(), vendor: .fixture(), atcLabel: .fixture(), prescriptions: .fixture(), applicationForms: .fixture(), pricesAndPackages: .fixture())
    }
    public static func fixture(id: DrugIdentifier = .fixture(), name: String = .fixture(), vendor: String? = .fixture(), atcLabel: String = .fixture(), prescriptions: [Prescription] = .fixture(), applicationForms: [ApplicationForm] = .fixture(), pricesAndPackages: [PriceAndPackage] = .fixture()) -> DrugReference {
        DrugReference(id: id, name: name, vendor: vendor, atcLabel: atcLabel, prescriptions: prescriptions, applicationForms: applicationForms, pricesAndPackages: pricesAndPackages)
    }
}

extension Extension: Fixture {
    public static func fixture() -> Extension {
        fixture(learningCard: .fixture(), section: .fixture(), updatedAt: .fixture(), previousUpdatedAt: .fixture(), note: .fixture())
    }
    public static func fixture(learningCard: LearningCardIdentifier = .fixture(), section: LearningCardSectionIdentifier = .fixture(), updatedAt: Date = .fixture(), previousUpdatedAt: Date? = .fixture(), note: String = .fixture()) -> Extension {
        Extension(learningCard: learningCard, section: section, updatedAt: updatedAt, previousUpdatedAt: previousUpdatedAt, note: note)
    }
}

extension ExtensionMetadata: Fixture {
    public static func fixture() -> ExtensionMetadata {
        fixture(ext: .fixture())
    }
    public static func fixture(ext: Extension = .fixture()) -> ExtensionMetadata {
        ExtensionMetadata(ext)
    }
}

extension ExternalAddition: Fixture {
    public static func fixture() -> ExternalAddition {
        fixture(identifier: .fixture(), type: .fixture(), isFree: .fixture(), url: .fixture())
    }
    public static func fixture(identifier: ExternalAdditionIdentifier = .fixture(), type: ExternalAddition.Types = .fixture(), isFree: Bool = .fixture(), url: URL? = .fixture()) -> ExternalAddition {
        ExternalAddition(identifier: identifier, type: type, isFree: isFree, url: url)
    }
}

extension FeedbackDeeplink: Fixture {
    public static func fixture() -> FeedbackDeeplink {
        fixture(anchor: .fixture(), version: .fixture(), archiveVersion: .fixture())
    }
    public static func fixture(anchor: LearningCardAnchorIdentifier? = .fixture(), version: Int? = .fixture(), archiveVersion: Int = .fixture()) -> FeedbackDeeplink {
        FeedbackDeeplink(anchor: anchor, version: version, archiveVersion: archiveVersion)
    }
}

extension Gallery: Fixture {
    public static func fixture() -> Gallery {
        fixture(id: .fixture(), sortableImages: .fixture())
    }
    public static func fixture(id: GalleryIdentifier = .fixture(), sortableImages: [SortableImageReference] = .fixture()) -> Gallery {
        Gallery(id: id, sortableImages: sortableImages)
    }
}

extension GalleryDeeplink: Fixture {
    public static func fixture() -> GalleryDeeplink {
        fixture(gallery: .fixture(), imageOffset: .fixture())
    }
    public static func fixture(gallery: GalleryIdentifier = .fixture(), imageOffset: Int = .fixture()) -> GalleryDeeplink {
        GalleryDeeplink(gallery: gallery, imageOffset: imageOffset)
    }
}

extension GuidelineSearchItem: Fixture {
    public static func fixture() -> GuidelineSearchItem {
        fixture(tags: .fixture(), title: .fixture(), details: .fixture(), externalURL: .fixture(), resultUUID: .fixture(), targetUUID: .fixture())
    }
    public static func fixture(tags: [String]? = .fixture(), title: String = .fixture(), details: [String]? = .fixture(), externalURL: String? = .fixture(), resultUUID: String = .fixture(), targetUUID: String = .fixture()) -> GuidelineSearchItem {
        GuidelineSearchItem(tags: tags, title: title, details: details, externalURL: externalURL, resultUUID: resultUUID, targetUUID: targetUUID)
    }
}

extension GuidelineSearchViewItem: Fixture {
    public static func fixture() -> GuidelineSearchViewItem {
        fixture(tag: .fixture(), title: .fixture(), details: .fixture(), externalURL: .fixture(), indexInfo: .fixture(), targetUUid: .fixture())
    }
    public static func fixture(tag: String? = .fixture(), title: String = .fixture(), details: String? = .fixture(), externalURL: URL? = .fixture(), indexInfo: IndexInfo = .fixture(), targetUUid: String = .fixture()) -> GuidelineSearchViewItem {
        GuidelineSearchViewItem(tag: tag, title: title, details: details, externalURL: externalURL, indexInfo: indexInfo, targetUUid: targetUUid)
    }
}

extension GuidelineSearchViewItem.IndexInfo: Fixture {
    public static func fixture() -> GuidelineSearchViewItem.IndexInfo {
        fixture(index: .fixture(), subIndex: .fixture())
    }
    public static func fixture(index: Int = .fixture(), subIndex: Int? = .fixture()) -> GuidelineSearchViewItem.IndexInfo {
        GuidelineSearchViewItem.IndexInfo(index: index, subIndex: subIndex)
    }
}

extension ImageReference: Fixture {
    public static func fixture() -> ImageReference {
        fixture(source: .fixture(), width: .fixture(), height: .fixture(), filesize: .fixture(), mimeType: .fixture())
    }
    public static func fixture(source: URL = .fixture(), width: Int = .fixture(), height: Int = .fixture(), filesize: Int = .fixture(), mimeType: String = .fixture()) -> ImageReference {
        ImageReference(source: source, width: width, height: height, filesize: filesize, mimeType: mimeType)
    }
}

extension ImageResourceType: Fixture {
    public static func fixture() -> ImageResourceType {
        fixture(title: .fixture(), description: .fixture(), copyright: .fixture(), thumbnailImages: .fixture(), standardImages: .fixture(), overlayImages: .fixture(), externalAdditions: .fixture(), imageResourceIdentifier: .fixture())
    }
    public static func fixture(title: String? = .fixture(), description: String = .fixture(), copyright: String = .fixture(), thumbnailImages: [ImageReference] = .fixture(), standardImages: [ImageReference] = .fixture(), overlayImages: [ImageReference] = .fixture(), externalAdditions: [ExternalAddition] = .fixture(), imageResourceIdentifier: ImageResourceIdentifier = .fixture()) -> ImageResourceType {
        ImageResourceType(title: title, description: description, copyright: copyright, thumbnailImages: thumbnailImages, standardImages: standardImages, overlayImages: overlayImages, externalAdditions: externalAdditions, imageResourceIdentifier: imageResourceIdentifier)
    }
}

extension InAppPurchaseInfo: Fixture {
    public static func fixture() -> InAppPurchaseInfo {
        fixture(subscriptionState: .fixture(), canPurchase: .fixture(), hasActiveIAPSubcription: .fixture(), hasProductMetadata: .fixture(), productIdentifier: .fixture(), localizedPriceValue: .fixture(), localizedPriceCurrency: .fixture(), hasTrialAccess: .fixture())
    }
    public static func fixture(subscriptionState: InAppPurchaseSubscriptionState = .fixture(), canPurchase: Bool = .fixture(), hasActiveIAPSubcription: Bool = .fixture(), hasProductMetadata: Bool = .fixture(), productIdentifier: String? = .fixture(), localizedPriceValue: Float? = .fixture(), localizedPriceCurrency: String? = .fixture(), hasTrialAccess: Bool = .fixture()) -> InAppPurchaseInfo {
        InAppPurchaseInfo(subscriptionState: subscriptionState, canPurchase: canPurchase, hasActiveIAPSubcription: hasActiveIAPSubcription, hasProductMetadata: hasProductMetadata, productIdentifier: productIdentifier, localizedPriceValue: localizedPriceValue, localizedPriceCurrency: localizedPriceCurrency, hasTrialAccess: hasTrialAccess)
    }
}

extension InArticleResultIndentifier: Fixture {
    public static func fixture() -> InArticleResultIndentifier {
        fixture(id: .fixture())
    }
    public static func fixture(id: String = .fixture()) -> InArticleResultIndentifier {
        InArticleResultIndentifier(id: id)
    }
}

extension InArticleSearchResponse: Fixture {
    public static func fixture() -> InArticleSearchResponse {
        fixture(identifier: .fixture(), results: .fixture())
    }
    public static func fixture(identifier: InArticleSearchResponseIdentifier = .fixture(), results: [InArticleResultIndentifier] = .fixture()) -> InArticleSearchResponse {
        InArticleSearchResponse(identifier: identifier, results: results)
    }
}

extension InArticleSearchResponseIdentifier: Fixture {
    public static func fixture() -> InArticleSearchResponseIdentifier {
        fixture(id: .fixture())
    }
    public static func fixture(id: String = .fixture()) -> InArticleSearchResponseIdentifier {
        InArticleSearchResponseIdentifier(id: id)
    }
}

extension LearningCardDeeplink: Fixture {
    public static func fixture() -> LearningCardDeeplink {
        fixture(learningCard: .fixture(), anchor: .fixture(), particle: .fixture(), sourceAnchor: .fixture(), question: .fixture(), searchSessionID: .fixture())
    }
    public static func fixture(learningCard: LearningCardIdentifier = .fixture(), anchor: LearningCardAnchorIdentifier? = .fixture(), particle: LearningCardAnchorIdentifier? = .fixture(), sourceAnchor: LearningCardAnchorIdentifier? = .fixture(), question: QBankQuestionIdentifier? = .fixture(), searchSessionID: String? = .fixture()) -> LearningCardDeeplink {
        LearningCardDeeplink(learningCard: learningCard, anchor: anchor, particle: particle, sourceAnchor: sourceAnchor, question: question, searchSessionID: searchSessionID)
    }
}

extension LearningCardMetaItem: Fixture {
    public static func fixture() -> LearningCardMetaItem {
        fixture(title: .fixture(), urlPath: .fixture(), preclinicFocusAvailable: .fixture(), alwaysFree: .fixture(), minimapNodes: .fixture(), learningCardIdentifier: .fixture(), galleries: .fixture(), questions: .fixture())
    }
    public static func fixture(title: String = .fixture(), urlPath: String = .fixture(), preclinicFocusAvailable: Bool = .fixture(), alwaysFree: Bool = .fixture(), minimapNodes: [MinimapNodeMeta] = .fixture(), learningCardIdentifier: LearningCardIdentifier = .fixture(), galleries: [Gallery] = .fixture(), questions: [QBankQuestionIdentifier] = .fixture()) -> LearningCardMetaItem {
        LearningCardMetaItem(title: title, urlPath: urlPath, preclinicFocusAvailable: preclinicFocusAvailable, alwaysFree: alwaysFree, minimapNodes: minimapNodes, learningCardIdentifier: learningCardIdentifier, galleries: galleries, questions: questions)
    }
}

extension LearningCardOptions: Fixture {
    public static func fixture() -> LearningCardOptions {
        fixture(isHighYieldModeOn: .fixture(), isHighlightingModeOn: .fixture(), isPhysikumFokusModeOn: .fixture(), isOnLearningRadarOn: .fixture())
    }
    public static func fixture(isHighYieldModeOn: Bool = .fixture(), isHighlightingModeOn: Bool = .fixture(), isPhysikumFokusModeOn: Bool = .fixture(), isOnLearningRadarOn: Bool = .fixture()) -> LearningCardOptions {
        LearningCardOptions(isHighYieldModeOn: isHighYieldModeOn, isHighlightingModeOn: isHighlightingModeOn, isPhysikumFokusModeOn: isPhysikumFokusModeOn, isOnLearningRadarOn: isOnLearningRadarOn)
    }
}

extension LearningCardReading: Fixture {
    public static func fixture() -> LearningCardReading {
        fixture(learningCard: .fixture(), openedAt: .fixture(), closedAt: .fixture())
    }
    public static func fixture(learningCard: LearningCardIdentifier = .fixture(), openedAt: Date = .fixture(), closedAt: Date? = .fixture()) -> LearningCardReading {
        LearningCardReading(learningCard: learningCard, openedAt: openedAt, closedAt: closedAt)
    }
}

extension LearningCardShareItem: Fixture {
    public static func fixture() -> LearningCardShareItem {
        fixture(title: .fixture(), message: .fixture(), remoteURL: .fixture())
    }
    public static func fixture(title: String = .fixture(), message: String = .fixture(), remoteURL: URL = .fixture()) -> LearningCardShareItem {
        LearningCardShareItem(title: title, message: message, remoteURL: remoteURL)
    }
}

extension LearningCardTreeItem: Fixture {
    public static func fixture() -> LearningCardTreeItem {
        fixture(id: .fixture(), parent: .fixture(), title: .fixture(), learningCardIdentifier: .fixture(), childrenCount: .fixture())
    }
    public static func fixture(id: Int = .fixture(), parent: Int? = .fixture(), title: String = .fixture(), learningCardIdentifier: LearningCardIdentifier? = .fixture(), childrenCount: Int? = .fixture()) -> LearningCardTreeItem {
        LearningCardTreeItem(id: id, parent: parent, title: title, learningCardIdentifier: learningCardIdentifier, childrenCount: childrenCount)
    }
}

extension LibraryMetadata: Fixture {
    public static func fixture() -> LibraryMetadata {
        fixture(versionId: 0 , containsLearningCardContent: .fixture(), createdAt: .fixture(), isDarkModeSupported: .fixture())
    }
    public static func fixture(versionId: Int = 0 , containsLearningCardContent: Bool = .fixture(), createdAt: Date? = .fixture(), isDarkModeSupported: Bool = .fixture()) -> LibraryMetadata {
        LibraryMetadata(versionId: versionId, containsLearningCardContent: containsLearningCardContent, createdAt: createdAt, isDarkModeSupported: isDarkModeSupported)
    }
}

extension LibraryUpdate: Fixture {
    public static func fixture() -> LibraryUpdate {
        fixture(version: .fixture(), url: .fixture(), updateMode: .fixture(), size: .fixture(), createdAt: .fixture())
    }
    public static func fixture(version: Int = .fixture(), url: URL = .fixture(), updateMode: LibraryUpdateMode = .fixture(), size: Int = .fixture(), createdAt: Date = .fixture()) -> LibraryUpdate {
        LibraryUpdate(version: version, url: url, updateMode: updateMode, size: size, createdAt: createdAt)
    }
}

extension LoginDeeplink: Fixture {
    public static func fixture() -> LoginDeeplink {
        LoginDeeplink()
    }
}

extension MediaFiltersResult: Fixture {
    public static func fixture() -> MediaFiltersResult {
        fixture(filters: .fixture())
    }
    public static func fixture(filters: [MediaFilter] = .fixture()) -> MediaFiltersResult {
        MediaFiltersResult(filters: filters)
    }
}

extension MediaSearchItem: Fixture {
    public static func fixture() -> MediaSearchItem {
        fixture(mediaId: .fixture(), title: .fixture(), url: .fixture(), externalAddition: .fixture(), category: .fixture(), typeName: .fixture(), resultUUID: .fixture(), targetUUID: .fixture())
    }
    public static func fixture(mediaId: String = .fixture(), title: String = .fixture(), url: URL = .fixture(), externalAddition: ExternalAddition? = .fixture(), category: MediaSearchItem.Category = .fixture(), typeName: String = .fixture(), resultUUID: String = .fixture(), targetUUID: String = .fixture()) -> MediaSearchItem {
        MediaSearchItem(mediaId: mediaId, title: title, url: url, externalAddition: externalAddition, category: category, typeName: typeName, resultUUID: resultUUID, targetUUID: targetUUID)
    }
}

extension MediaSearchItem.ExternalAddition: Fixture {
    public static func fixture() -> MediaSearchItem.ExternalAddition {
        fixture(type: .fixture(), url: .fixture())
    }
    public static func fixture(type: Domain.ExternalAddition.Types = .fixture(), url: URL = .fixture()) -> MediaSearchItem.ExternalAddition {
        MediaSearchItem.ExternalAddition(type: type, url: url)
    }
}

extension MinimapNodeMeta: Fixture {
    public static func fixture() -> MinimapNodeMeta {
        fixture(title: .fixture(), anchor: .fixture(), childNodes: .fixture(), requiredModes: .fixture())
    }
    public static func fixture(title: String = .fixture(), anchor: LearningCardSectionIdentifier = .fixture(), childNodes: [MinimapNodeMeta] = .fixture(), requiredModes: [String] = .fixture()) -> MinimapNodeMeta {
        MinimapNodeMeta(title: title, anchor: anchor, childNodes: childNodes, requiredModes: requiredModes)
    }
}

extension Monograph: Fixture {
    public static func fixture() -> Monograph {
        fixture(id: .fixture(), title: .fixture(), classification: .fixture(), generic: .fixture(), publishedAt: .fixture(), html: .fixture())
    }
    public static func fixture(id: MonographIdentifier = .fixture(), title: String = .fixture(), classification: MonographClassification = .fixture(), generic: Bool = .fixture(), publishedAt: String = .fixture(), html: String = .fixture()) -> Monograph {
        Monograph(id: id, title: title, classification: classification, generic: generic, publishedAt: publishedAt, html: html)
    }
}

extension MonographClassification: Fixture {
    public static func fixture() -> MonographClassification {
        fixture(ahfsCode: .fixture(), ahfsTitle: .fixture(), atcCode: .fixture(), atcTitle: .fixture())
    }
    public static func fixture(ahfsCode: String = .fixture(), ahfsTitle: String = .fixture(), atcCode: String = .fixture(), atcTitle: String = .fixture()) -> MonographClassification {
        MonographClassification(ahfsCode: ahfsCode, ahfsTitle: ahfsTitle, atcCode: atcCode, atcTitle: atcTitle)
    }
}

extension MonographDeeplink: Fixture {
    public static func fixture() -> MonographDeeplink {
        fixture(monograph: .fixture(), anchor: .fixture())
    }
    public static func fixture(monograph: MonographIdentifier = .fixture(), anchor: MonographAnchorIdentifier? = .fixture()) -> MonographDeeplink {
        MonographDeeplink(monograph: monograph, anchor: anchor)
    }
}

extension MonographSearchItem: Fixture {
    public static func fixture() -> MonographSearchItem {
        fixture(id: .fixture(), anchor: .fixture(), title: .fixture(), details: .fixture(), children: .fixture(), resultUUID: .fixture(), targetUUID: .fixture())
    }
    public static func fixture(id: MonographIdentifier = .fixture(), anchor: MonographAnchorIdentifier? = .fixture(), title: String = .fixture(), details: [String]? = .fixture(), children: [MonographSearchItem] = .fixture(), resultUUID: String = .fixture(), targetUUID: String = .fixture()) -> MonographSearchItem {
        MonographSearchItem(id: id, anchor: anchor, title: title, details: details, children: children, resultUUID: resultUUID, targetUUID: targetUUID)
    }
}

extension MonographSearchViewItem: Fixture {
    public static func fixture() -> MonographSearchViewItem {
        fixture(title: .fixture(), details: .fixture(), deeplink: .fixture(), resultIndex: .fixture(), children: .fixture(), targetUuid: .fixture())
    }
    public static func fixture(title: String = .fixture(), details: [String]? = .fixture(), deeplink: MonographDeeplink = .fixture(), resultIndex: Int = .fixture(), children: [ChildSearchResultViewItem] = .fixture(), targetUuid: String = .fixture()) -> MonographSearchViewItem {
        MonographSearchViewItem(title: title, details: details, deeplink: deeplink, resultIndex: resultIndex, children: children, targetUuid: targetUuid)
    }
}

extension OneTimeToken: Fixture {
    public static func fixture() -> OneTimeToken {
        fixture(token: .fixture())
    }
    public static func fixture(token: String = .fixture()) -> OneTimeToken {
        OneTimeToken(token: token)
    }
}

extension PharmaCard: Fixture {
    public static func fixture() -> PharmaCard {
        fixture(substance: .fixture(), drug: .fixture())
    }
    public static func fixture(substance: Substance = .fixture(), drug: Drug = .fixture()) -> PharmaCard {
        PharmaCard(substance: substance, drug: drug)
    }
}

extension PharmaCardDeeplink: Fixture {
    public static func fixture() -> PharmaCardDeeplink {
        fixture(substance: .fixture(), drug: .fixture())
    }
    public static func fixture(substance: SubstanceIdentifier = .fixture(), drug: DrugIdentifier? = .fixture()) -> PharmaCardDeeplink {
        PharmaCardDeeplink(substance: substance, drug: drug)
    }
}

extension PharmaSearchItem: Fixture {
    public static func fixture() -> PharmaSearchItem {
        fixture(title: .fixture(), details: .fixture(), substanceID: .fixture(), drugid: .fixture(), resultUUID: .fixture(), targetUUID: .fixture())
    }
    public static func fixture(title: String = .fixture(), details: [String]? = .fixture(), substanceID: SubstanceIdentifier = .fixture(), drugid: DrugIdentifier? = .fixture(), resultUUID: String = .fixture(), targetUUID: String = .fixture()) -> PharmaSearchItem {
        PharmaSearchItem(title: title, details: details, substanceID: substanceID, drugid: drugid, resultUUID: resultUUID, targetUUID: targetUUID)
    }
}

extension PharmaSearchViewItem: Fixture {
    public static func fixture() -> PharmaSearchViewItem {
        fixture(title: .fixture(), details: .fixture(), substanceID: .fixture(), drugId: .fixture(), targetUuid: .fixture())
    }
    public static func fixture(title: String = .fixture(), details: String? = .fixture(), substanceID: SubstanceIdentifier = .fixture(), drugId: DrugIdentifier? = .fixture(), targetUuid: String = .fixture()) -> PharmaSearchViewItem {
        PharmaSearchViewItem(title: title, details: details, substanceID: substanceID, drugId: drugId, targetUuid: targetUuid)
    }
}

extension PharmaUpdate: Fixture {
    public static func fixture() -> PharmaUpdate {
        fixture(version: .fixture(), size: .fixture(), zippedSize: .fixture(), url: .fixture(), date: .fixture())
    }
    public static func fixture(version: Version = .fixture(), size: Int = .fixture(), zippedSize: Int = .fixture(), url: URL = .fixture(), date: Date = .fixture()) -> PharmaUpdate {
        PharmaUpdate(version: version, size: size, zippedSize: zippedSize, url: url, date: date)
    }
}

extension PhrasionaryItem: Fixture {
    public static func fixture() -> PhrasionaryItem {
        fixture(title: .fixture(), body: .fixture(), synonyms: .fixture(), etymology: .fixture(), targets: .fixture(), resultUUID: .fixture())
    }
    public static func fixture(title: String = .fixture(), body: String? = .fixture(), synonyms: [String] = .fixture(), etymology: String? = .fixture(), targets: [SearchResultItem] = .fixture(), resultUUID: String = .fixture()) -> PhrasionaryItem {
        PhrasionaryItem(title: title, body: body, synonyms: synonyms, etymology: etymology, targets: targets, resultUUID: resultUUID)
    }
}

extension PlannedExam: Fixture {
    public static func fixture() -> PlannedExam {
        fixture(eid: .fixture(), name: .fixture())
    }
    public static func fixture(eid: String = .fixture(), name: String = .fixture()) -> PlannedExam {
        PlannedExam(eid: eid, name: name)
    }
}

extension PocketCard: Fixture {
    public static func fixture() -> PocketCard {
        fixture(groups: .fixture())
    }
    public static func fixture(groups: [PocketCard.Group] = .fixture()) -> PocketCard {
        PocketCard(groups: groups)
    }
}

extension PocketCard.Group: Fixture {
    public static func fixture() -> PocketCard.Group {
        fixture(title: .fixture(), anchor: .fixture(), sections: .fixture())
    }
    public static func fixture(title: String = .fixture(), anchor: String = .fixture(), sections: [PocketCard.Section] = .fixture()) -> PocketCard.Group {
        PocketCard.Group(title: title, anchor: anchor, sections: sections)
    }
}

extension PocketCard.Section: Fixture {
    public static func fixture() -> PocketCard.Section {
        fixture(title: .fixture(), anchor: .fixture(), content: .fixture())
    }
    public static func fixture(title: String = .fixture(), anchor: String = .fixture(), content: String = .fixture()) -> PocketCard.Section {
        PocketCard.Section(title: title, anchor: anchor, content: content)
    }
}

extension PocketGuidesDeeplink: Fixture {
    public static func fixture() -> PocketGuidesDeeplink {
        PocketGuidesDeeplink()
    }
}

extension PriceAndPackage: Fixture {
    public static func fixture() -> PriceAndPackage {
        fixture(packageSize: .fixture(), amount: .fixture(), unit: .fixture(), pharmacyPrice: .fixture(), recommendedRetailPrice: .fixture())
    }
    public static func fixture(packageSize: PackageSize? = .fixture(), amount: String = .fixture(), unit: String = .fixture(), pharmacyPrice: String? = .fixture(), recommendedRetailPrice: String? = .fixture()) -> PriceAndPackage {
        PriceAndPackage(packageSize: packageSize, amount: amount, unit: unit, pharmacyPrice: pharmacyPrice, recommendedRetailPrice: recommendedRetailPrice)
    }
}

extension ProductKeyDeeplink: Fixture {
    public static func fixture() -> ProductKeyDeeplink {
        fixture(code: .fixture())
    }
    public static func fixture(code: String = .fixture()) -> ProductKeyDeeplink {
        ProductKeyDeeplink(code: code)
    }
}

extension QBankAnswer: Fixture {
    public static func fixture() -> QBankAnswer {
        fixture(questionId: .fixture(), status: .fixture())
    }
    public static func fixture(questionId: QBankQuestionIdentifier = .fixture(), status: Status = .fixture()) -> QBankAnswer {
        QBankAnswer(questionId: questionId, status: status)
    }
}

extension SearchDeeplink: Fixture {
    public static func fixture() -> SearchDeeplink {
        fixture(type: .fixture(), query: .fixture(), filter: .fixture())
    }
    public static func fixture(type: SearchType = .fixture(), query: String = .fixture(), filter: String? = .fixture()) -> SearchDeeplink {
        SearchDeeplink(type: type, query: query, filter: filter)
    }
}

extension SearchOverviewResult: Fixture {
    public static func fixture() -> SearchOverviewResult {
        fixture(phrasionary: .fixture(), articleItems: .fixture(), articleItemsTotalCount: .fixture(), articlePageInfo: .fixture(), pharmaInfo: .fixture(), guidelineItems: .fixture(), guidelineItemsTotalCount: .fixture(), guidelinePageInfo: .fixture(), mediaItems: .fixture(), mediaFiltersResult: .fixture(), mediaItemsTotalCount: .fixture(), mediaPageInfo: .fixture(), correctedSearchTerm: .fixture(), overviewSectionOrder: .fixture(), targetScope: .fixture())
    }
    public static func fixture(phrasionary: PhrasionaryItem? = .fixture(), articleItems: [ArticleSearchItem] = .fixture(), articleItemsTotalCount: Int = .fixture(), articlePageInfo: PageInfo? = .fixture(), pharmaInfo: PharmaInfo? = .fixture(), guidelineItems: [GuidelineSearchItem] = .fixture(), guidelineItemsTotalCount: Int = .fixture(), guidelinePageInfo: PageInfo? = .fixture(), mediaItems: [MediaSearchItem] = .fixture(), mediaFiltersResult: MediaFiltersResult = .fixture(), mediaItemsTotalCount: Int = .fixture(), mediaPageInfo: PageInfo? = .fixture(), correctedSearchTerm: String? = .fixture(), overviewSectionOrder: [SearchResultContentType]? = .fixture(), targetScope: SearchResultsTargetScope? = .fixture()) -> SearchOverviewResult {
        SearchOverviewResult(phrasionary: phrasionary, articleItems: articleItems, articleItemsTotalCount: articleItemsTotalCount, articlePageInfo: articlePageInfo, pharmaInfo: pharmaInfo, guidelineItems: guidelineItems, guidelineItemsTotalCount: guidelineItemsTotalCount, guidelinePageInfo: guidelinePageInfo, mediaItems: mediaItems, mediaFiltersResult: mediaFiltersResult, mediaItemsTotalCount: mediaItemsTotalCount, mediaPageInfo: mediaPageInfo, correctedSearchTerm: correctedSearchTerm, overviewSectionOrder: overviewSectionOrder, targetScope: targetScope)
    }
}

extension SearchOverviewResult.PageInfo: Fixture {
    public static func fixture() -> SearchOverviewResult.PageInfo {
        fixture(endCursor: .fixture(), hasNextPage: .fixture())
    }
    public static func fixture(endCursor: String? = .fixture(), hasNextPage: Bool = .fixture()) -> SearchOverviewResult.PageInfo {
        SearchOverviewResult.PageInfo(endCursor: endCursor, hasNextPage: hasNextPage)
    }
}

extension SearchResult: Fixture {
    public static func fixture() -> SearchResult {
        fixture(resultType: .fixture(), searchOverviewResult: .fixture())
    }
    public static func fixture(resultType: SearchResultType = .fixture(), searchOverviewResult: SearchOverviewResult = .fixture()) -> SearchResult {
        SearchResult(resultType: resultType, searchOverviewResult: searchOverviewResult)
    }
}

extension SearchSuggestionResult: Fixture {
    public static func fixture() -> SearchSuggestionResult {
        fixture(resultType: .fixture(), suggestions: .fixture())
    }
    public static func fixture(resultType: SuggestionResultType = .fixture(), suggestions: [SearchSuggestionItem] = .fixture()) -> SearchSuggestionResult {
        SearchSuggestionResult(resultType: resultType, suggestions: suggestions)
    }
}

extension SectionFeedback: Fixture {
    public static func fixture() -> SectionFeedback {
        fixture(message: .fixture(), intention: .fixture(), source: .fixture(), mobileInfo: .fixture())
    }
    public static func fixture(message: String = .fixture(), intention: FeedbackIntention = .fixture(), source: Source = .fixture(), mobileInfo: MobileInfo = .fixture()) -> SectionFeedback {
        SectionFeedback(message: message, intention: intention, source: source, mobileInfo: mobileInfo)
    }
}

extension SectionFeedback.MobileInfo: Fixture {
    public static func fixture() -> SectionFeedback.MobileInfo {
        fixture(appPlatform: .fixture(), appName: .fixture(), appVersion: .fixture(), archiveVersion: .fixture())
    }
    public static func fixture(appPlatform: AppPlatform = .fixture(), appName: AppName = .fixture(), appVersion: String = .fixture(), archiveVersion: Int = .fixture()) -> SectionFeedback.MobileInfo {
        SectionFeedback.MobileInfo(appPlatform: appPlatform, appName: appName, appVersion: appVersion, archiveVersion: archiveVersion)
    }
}

extension SectionFeedback.Source: Fixture {
    public static func fixture() -> SectionFeedback.Source {
        fixture(type: .fixture(), id: .fixture(), version: .fixture())
    }
    public static func fixture(type: SourceType = .fixture(), id: String? = .fixture(), version: Int? = .fixture()) -> SectionFeedback.Source {
        SectionFeedback.Source(type: type, id: id, version: version)
    }
}

extension SettingsDeeplink: Fixture {
    public static func fixture() -> SettingsDeeplink {
        fixture(screen: .fixture())
    }
    public static func fixture(screen: SettingsDeeplink.Screen = .fixture()) -> SettingsDeeplink {
        SettingsDeeplink(screen: screen)
    }
}

extension SharedExtension: Fixture {
    public static func fixture() -> SharedExtension {
        fixture(user: .fixture(), ext: .fixture())
    }
    public static func fixture(user: User = .fixture(), ext: Extension = .fixture()) -> SharedExtension {
        SharedExtension(user: user, ext: ext)
    }
}

extension SharedExtensionMetadata: Fixture {
    public static func fixture() -> SharedExtensionMetadata {
        fixture(user: .fixture(), ext: .fixture())
    }
    public static func fixture(user: User = .fixture(), ext: ExtensionMetadata = .fixture()) -> SharedExtensionMetadata {
        SharedExtensionMetadata(user: user, ext: ext)
    }
}

extension Snippet: Fixture {
    public static func fixture() -> Snippet {
        fixture(synonyms: .fixture(), title: .fixture(), etymology: .fixture(), description: .fixture(), destinations: .fixture(), identifier: .fixture())
    }
    public static func fixture(synonyms: [String] = .fixture(), title: String? = .fixture(), etymology: String? = .fixture(), description: String? = .fixture(), destinations: [SnippetDestination] = .fixture(), identifier: SnippetIdentifier = .fixture()) -> Snippet {
        Snippet(synonyms: synonyms, title: title, etymology: etymology, description: description, destinations: destinations, identifier: identifier)
    }
}

extension StudyObjective: Fixture {
    public static func fixture() -> StudyObjective {
        fixture(eid: .fixture(), name: .fixture(), superset: .fixture())
    }
    public static func fixture(eid: String = .fixture(), name: String = .fixture(), superset: String? = .fixture()) -> StudyObjective {
        StudyObjective(eid: eid, name: name, superset: superset)
    }
}

extension Substance: Fixture {
    public static func fixture() -> Substance {
        fixture(id: .fixture(), name: .fixture(), drugReferences: .fixture(), pocketCard: .fixture(), basedOn: .fixture())
    }
    public static func fixture(id: SubstanceIdentifier = .fixture(), name: String = .fixture(), drugReferences: [DrugReference] = .fixture(), pocketCard: PocketCard? = .fixture(), basedOn: DrugIdentifier = .fixture()) -> Substance {
        Substance(id: id, name: name, drugReferences: drugReferences, pocketCard: pocketCard, basedOn: basedOn)
    }
}

extension Tagging: Fixture {
    public static func fixture() -> Tagging {
        fixture(type: .fixture(), active: .fixture(), updatedAt: .fixture(), learningCard: .fixture())
    }
    public static func fixture(type: Tag = .fixture(), active: Bool = .fixture(), updatedAt: Date = .fixture(), learningCard: LearningCardIdentifier = .fixture()) -> Tagging {
        Tagging(type: type, active: active, updatedAt: updatedAt, learningCard: learningCard)
    }
}

extension TargetAccess: Fixture {
    public static func fixture() -> TargetAccess {
        fixture(target: .fixture(), access: .fixture())
    }
    public static func fixture(target: AccessTarget = .fixture(), access: Access = .fixture()) -> TargetAccess {
        TargetAccess(target: target, access: access)
    }
}

extension UncommitedSearchDeeplink: Fixture {
    public static func fixture() -> UncommitedSearchDeeplink {
        fixture(type: .fixture(), initialQuery: .fixture(), initialFilter: .fixture())
    }
    public static func fixture(type: SearchType? = .fixture(), initialQuery: String = .fixture(), initialFilter: String? = .fixture()) -> UncommitedSearchDeeplink {
        UncommitedSearchDeeplink(type: type, initialQuery: initialQuery, initialFilter: initialFilter)
    }
}

extension User: Fixture {
    public static func fixture() -> User {
        fixture(userIdentifier: .fixture(), firstName: .fixture(), lastName: .fixture(), email: .fixture())
    }
    public static func fixture(userIdentifier: UserIdentifier = .fixture(), firstName: String? = .fixture(), lastName: String? = .fixture(), email: String? = .fixture()) -> User {
        User(userIdentifier: userIdentifier, firstName: firstName, lastName: lastName, email: email)
    }
}

extension UserData: Fixture {
    public static func fixture() -> UserData {
        fixture(featureFlags: .fixture(), stage: .fixture(), studyObjective: .fixture(), shouldUpdateTermsAndConditions: .fixture())
    }
    public static func fixture(featureFlags: [String] = .fixture(), stage: UserStage? = .fixture(), studyObjective: StudyObjective? = .fixture(), shouldUpdateTermsAndConditions: Bool = .fixture()) -> UserData {
        UserData(featureFlags: featureFlags, stage: stage, studyObjective: studyObjective, shouldUpdateTermsAndConditions: shouldUpdateTermsAndConditions)
    }
}

extension Version: Fixture {
    public static func fixture() -> Version {
        fixture(major: .fixture(), minor: .fixture(), patch: .fixture())
    }
    public static func fixture(major: Int = .fixture(), minor: Int = .fixture(), patch: Int = .fixture()) -> Version {
        Version(major: major, minor: minor, patch: patch)
    }
}


// MARK: - Enums


extension Access {
    static let fixtureCaseGenerators: [() -> Access] = [
        { .granted(.fixture()) }, 
        { .denied(.fixture()) }, 
    ]
    public static func fixture() -> Access {
        fixtureCaseGenerators.randomElement()!()
    }
}

extension AccessError {
    static let fixtureCaseGenerators: [() -> AccessError] = [
        { .offlineAccessExpired }, 
        { .accessRequired }, 
        { .accessExpired }, 
        { .accessConsumed }, 
        { .campusLicenseUserAccessExpired }, 
        { .unknown(.fixture()) }, 
    ]
    public static func fixture() -> AccessError {
        fixtureCaseGenerators.randomElement()!()
    }
}

extension AmbossSubstanceLink.Deeplink {
    static let fixtureCaseGenerators: [() -> AmbossSubstanceLink.Deeplink] = [
        { .pharmaCard(.fixture()) }, 
        { .monograph(.fixture()) }, 
    ]
    public static func fixture() -> AmbossSubstanceLink.Deeplink {
        fixtureCaseGenerators.randomElement()!()
    }
}

extension AppVariant {
    static let fixtureCaseGenerators: [() -> AppVariant] = [
        { .knowledge }, 
        { .wissen }, 
    ]
    public static func fixture() -> AppVariant {
        fixtureCaseGenerators.randomElement()!()
    }
}

extension ApplicationForm {
    static let fixtureCaseGenerators: [() -> ApplicationForm] = [
        { .all }, 
        { .enteral }, 
        { .parenteral }, 
        { .topical }, 
        { .ophthalmic }, 
        { .inhalation }, 
        { .rectal }, 
        { .nasalSpray }, 
        { .urogenital }, 
        { .bronchial }, 
        { .other }, 
    ]
    public static func fixture() -> ApplicationForm {
        fixtureCaseGenerators.randomElement()!()
    }
}

extension ClinicalTool {
    static let fixtureCaseGenerators: [() -> ClinicalTool] = [
        { .pocketGuides }, 
        { .drugDatabase }, 
        { .flowcharts }, 
        { .calculators }, 
        { .guidelines }, 
    ]
    public static func fixture() -> ClinicalTool {
        fixtureCaseGenerators.randomElement()!()
    }
}

extension Deeplink {
    static let fixtureCaseGenerators: [() -> Deeplink] = [
        { .login(.fixture()) }, 
        { .learningCard(.fixture()) }, 
        { .pharmaCard(.fixture()) }, 
        { .search(.fixture(), source: .fixture()) }, 
        { .uncommitedSearch(.fixture()) }, 
        { .monograph(.fixture()) }, 
        { .settings(.fixture()) }, 
        { .pocketGuides(.fixture()) }, 
        { .productKey(.fixture()) }, 
        { .unsupported(.fixture()) }, 
    ]
    public static func fixture() -> Deeplink {
        fixtureCaseGenerators.randomElement()!()
    }
}

extension Deeplink.Source {
    static let fixtureCaseGenerators: [() -> Deeplink.Source] = [
        { .standard }, 
        { .siri }, 
    ]
    public static func fixture() -> Deeplink.Source {
        fixtureCaseGenerators.randomElement()!()
    }
}

extension DeprecationItem.DeprecationType {
    static let fixtureCaseGenerators: [() -> DeprecationItem.DeprecationType] = [
        { .unsupported }, 
        { .unknown }, 
    ]
    public static func fixture() -> DeprecationItem.DeprecationType {
        fixtureCaseGenerators.randomElement()!()
    }
}

extension DeprecationItem.Platform {
    static let fixtureCaseGenerators: [() -> DeprecationItem.Platform] = [
        { .ios }, 
        { .android }, 
        { .unknown }, 
    ]
    public static func fixture() -> DeprecationItem.Platform {
        fixtureCaseGenerators.randomElement()!()
    }
}

extension ExternalAddition.Types {
    static let fixtureCaseGenerators: [() -> ExternalAddition.Types] = [
        { .smartzoom }, 
        { .meditricks }, 
        { .meditricksNeuroanatomy }, 
        { .miamedCalculator }, 
        { .miamedWebContent }, 
        { .miamedAuditor }, 
        { .miamedPatientInformation }, 
        { .miamed3dModel }, 
        { .video }, 
        { .easyradiology }, 
        { .other(.fixture()) }, 
    ]
    public static func fixture() -> ExternalAddition.Types {
        fixtureCaseGenerators.randomElement()!()
    }
}

extension FeedbackIntention {
    static let fixtureCaseGenerators: [() -> FeedbackIntention] = [
        { .languageIssue }, 
        { .incorrectContent }, 
        { .missingContent }, 
        { .technicalIssue }, 
        { .media }, 
        { .productFeedback }, 
        { .praise }, 
    ]
    public static func fixture() -> FeedbackIntention {
        fixtureCaseGenerators.randomElement()!()
    }
}

extension InAppPurchaseSubscriptionState {
    static let fixtureCaseGenerators: [() -> InAppPurchaseSubscriptionState] = [
        { .unknown }, 
        { .subscribed }, 
        { .unsubscribed }, 
    ]
    public static func fixture() -> InAppPurchaseSubscriptionState {
        fixtureCaseGenerators.randomElement()!()
    }
}

extension LibraryUpdateMode {
    static let fixtureCaseGenerators: [() -> LibraryUpdateMode] = [
        { .should }, 
        { .must }, 
        { .can }, 
    ]
    public static func fixture() -> LibraryUpdateMode {
        fixtureCaseGenerators.randomElement()!()
    }
}

extension MediaSearchItem.Category {
    static let fixtureCaseGenerators: [() -> MediaSearchItem.Category] = [
        { .flowchart }, 
        { .illustration }, 
        { .photo }, 
        { .imaging }, 
        { .chart }, 
        { .microscopy }, 
        { .audio }, 
        { .auditor }, 
        { .video }, 
        { .calculator }, 
        { .webContent }, 
        { .meditricks }, 
        { .smartzoom }, 
        { .effigos }, 
        { .other(.fixture()) }, 
    ]
    public static func fixture() -> MediaSearchItem.Category {
        fixtureCaseGenerators.randomElement()!()
    }
}

extension PackageSize {
    static let fixtureCaseGenerators: [() -> PackageSize] = [
        { .n1 }, 
        { .n2 }, 
        { .n3 }, 
        { .ktp }, 
        { .notApplicable }, 
    ]
    public static func fixture() -> PackageSize {
        fixtureCaseGenerators.randomElement()!()
    }
}

extension PackageSizeSortingOrder {
    static let fixtureCaseGenerators: [() -> PackageSizeSortingOrder] = [
        { .ascending }, 
        { .mixed }, 
    ]
    public static func fixture() -> PackageSizeSortingOrder {
        fixtureCaseGenerators.randomElement()!()
    }
}

extension PharmaDatabaseUpdateType {
    static let fixtureCaseGenerators: [() -> PharmaDatabaseUpdateType] = [
        { .manual }, 
        { .automatic }, 
    ]
    public static func fixture() -> PharmaDatabaseUpdateType {
        fixtureCaseGenerators.randomElement()!()
    }
}

extension Prescription {
    static let fixtureCaseGenerators: [() -> Prescription] = [
        { .overTheCounter }, 
        { .pharmacyOnly }, 
        { .prescriptionOnly }, 
        { .narcotic }, 
    ]
    public static func fixture() -> Prescription {
        fixtureCaseGenerators.randomElement()!()
    }
}

extension QBankAnswer.Status {
    static let fixtureCaseGenerators: [() -> QBankAnswer.Status] = [
        { .correct }, 
        { .incorrect }, 
    ]
    public static func fixture() -> QBankAnswer.Status {
        fixtureCaseGenerators.randomElement()!()
    }
}

extension SearchOverviewResult.PharmaInfo {
    static let fixtureCaseGenerators: [() -> SearchOverviewResult.PharmaInfo] = [
        { .pharmaCard(pharmaItems: .fixture(), pharmaItemsTotalCount: .fixture(), pageInfo: .fixture()) }, 
        { .monograph(monographItems: .fixture(), monographItemsTotalCount: .fixture(), pageInfo: .fixture()) }, 
    ]
    public static func fixture() -> SearchOverviewResult.PharmaInfo {
        fixtureCaseGenerators.randomElement()!()
    }
}

extension SearchResult.SearchResultType {
    static let fixtureCaseGenerators: [() -> SearchResult.SearchResultType] = [
        { .offline(duration: .fixture()) }, 
        { .online(duration: .fixture()) }, 
    ]
    public static func fixture() -> SearchResult.SearchResultType {
        fixtureCaseGenerators.randomElement()!()
    }
}

extension SearchResultsTargetScope {
    static let fixtureCaseGenerators: [() -> SearchResultsTargetScope] = [
        { .overview }, 
        { .article }, 
        { .media }, 
        { .pharma }, 
        { .guideline }, 
    ]
    public static func fixture() -> SearchResultsTargetScope {
        fixtureCaseGenerators.randomElement()!()
    }
}

extension SearchSuggestionItem {
    static let fixtureCaseGenerators: [() -> SearchSuggestionItem] = [
        { .autocomplete(text: .fixture(), value: .fixture(), metadata: .fixture()) }, 
        { .instantResult(.fixture()) }, 
    ]
    public static func fixture() -> SearchSuggestionItem {
        fixtureCaseGenerators.randomElement()!()
    }
}

extension SearchSuggestionItem.InstantResult {
    static let fixtureCaseGenerators: [() -> SearchSuggestionItem.InstantResult] = [
        { .article(text: .fixture(), value: .fixture(), deepLink: .fixture(), metadata: .fixture()) }, 
        { .pharmaCard(text: .fixture(), value: .fixture(), deepLink: .fixture(), metadata: .fixture()) }, 
        { .monograph(text: .fixture(), value: .fixture(), deepLink: .fixture(), metadata: .fixture()) }, 
    ]
    public static func fixture() -> SearchSuggestionItem.InstantResult {
        fixtureCaseGenerators.randomElement()!()
    }
}

extension SearchSuggestionResult.SuggestionResultType {
    static let fixtureCaseGenerators: [() -> SearchSuggestionResult.SuggestionResultType] = [
        { .offline }, 
        { .online }, 
    ]
    public static func fixture() -> SearchSuggestionResult.SuggestionResultType {
        fixtureCaseGenerators.randomElement()!()
    }
}

extension SearchType {
    static let fixtureCaseGenerators: [() -> SearchType] = [
        { .all }, 
        { .article }, 
        { .pharma }, 
        { .guideline }, 
        { .media }, 
    ]
    public static func fixture() -> SearchType {
        fixtureCaseGenerators.randomElement()!()
    }
}

extension SectionFeedback.MobileInfo.AppName {
    static let fixtureCaseGenerators: [() -> SectionFeedback.MobileInfo.AppName] = [
        { .knowledge }, 
        { .wissen }, 
    ]
    public static func fixture() -> SectionFeedback.MobileInfo.AppName {
        fixtureCaseGenerators.randomElement()!()
    }
}

extension SectionFeedback.MobileInfo.AppPlatform {
    static let fixtureCaseGenerators: [() -> SectionFeedback.MobileInfo.AppPlatform] = [
        { .ios }, 
    ]
    public static func fixture() -> SectionFeedback.MobileInfo.AppPlatform {
        fixtureCaseGenerators.randomElement()!()
    }
}

extension SectionFeedback.Source.SourceType {
    static let fixtureCaseGenerators: [() -> SectionFeedback.Source.SourceType] = [
        { .particle }, 
    ]
    public static func fixture() -> SectionFeedback.Source.SourceType {
        fixtureCaseGenerators.randomElement()!()
    }
}

extension SettingsDeeplink.Screen {
    static let fixtureCaseGenerators: [() -> SettingsDeeplink.Screen] = [
        { .appearance }, 
        { .productKey(.fixture()) }, 
    ]
    public static func fixture() -> SettingsDeeplink.Screen {
        fixtureCaseGenerators.randomElement()!()
    }
}

extension Tag {
    static let fixtureCaseGenerators: [() -> Tag] = [
        { .learned }, 
        { .favorite }, 
        { .opened }, 
    ]
    public static func fixture() -> Tag {
        fixtureCaseGenerators.randomElement()!()
    }
}

extension UserStage {
    static let fixtureCaseGenerators: [() -> UserStage] = [
        { .physician }, 
        { .clinic }, 
        { .preclinic }, 
    ]
    public static func fixture() -> UserStage {
        fixtureCaseGenerators.randomElement()!()
    }
}

extension Video {
    static let fixtureCaseGenerators: [() -> Video] = [
        { .youtube("kfVsfOSbJY0") },
        { .vimeo("342949798") },
    ]
    public static func fixture() -> Video {
        fixtureCaseGenerators.randomElement()!()
    }
}

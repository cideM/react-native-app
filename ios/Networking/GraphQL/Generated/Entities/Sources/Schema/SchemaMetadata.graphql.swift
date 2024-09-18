// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public typealias ID = String

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == KnowledgeGraphQLEntities.SchemaMetadata {}

public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == KnowledgeGraphQLEntities.SchemaMetadata {}

public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == KnowledgeGraphQLEntities.SchemaMetadata {}

public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == KnowledgeGraphQLEntities.SchemaMetadata {}

public enum SchemaMetadata: ApolloAPI.SchemaMetadata {
  public static let configuration: ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

  public static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
    switch typename {
    case "Query": return KnowledgeGraphQLEntities.Objects.Query
    case "AmbossSubstance": return KnowledgeGraphQLEntities.Objects.AmbossSubstance
    case "PharmaMonograph": return KnowledgeGraphQLEntities.Objects.PharmaMonograph
    case "PharmaMGClassification": return KnowledgeGraphQLEntities.Objects.PharmaMGClassification
    case "ParticleExtensionConnection": return KnowledgeGraphQLEntities.Objects.ParticleExtensionConnection
    case "AnswerStatusConnection": return KnowledgeGraphQLEntities.Objects.AnswerStatusConnection
    case "ArticleConnection": return KnowledgeGraphQLEntities.Objects.ArticleConnection
    case "ArticleInteractionConnection": return KnowledgeGraphQLEntities.Objects.ArticleInteractionConnection
    case "PharmaSearchResultConnection": return KnowledgeGraphQLEntities.Objects.PharmaSearchResultConnection
    case "QuestionSessionConnection": return KnowledgeGraphQLEntities.Objects.QuestionSessionConnection
    case "SearchResultConnection": return KnowledgeGraphQLEntities.Objects.SearchResultConnection
    case "TutorSessionConnection": return KnowledgeGraphQLEntities.Objects.TutorSessionConnection
    case "UserArticleConnection": return KnowledgeGraphQLEntities.Objects.UserArticleConnection
    case "UserConnection": return KnowledgeGraphQLEntities.Objects.UserConnection
    case "UserRecentArticleConnection": return KnowledgeGraphQLEntities.Objects.UserRecentArticleConnection
    case "ParticleExtensionEdge": return KnowledgeGraphQLEntities.Objects.ParticleExtensionEdge
    case "AnswerStatusEdge": return KnowledgeGraphQLEntities.Objects.AnswerStatusEdge
    case "ArticleEdge": return KnowledgeGraphQLEntities.Objects.ArticleEdge
    case "ArticleInteractionEdge": return KnowledgeGraphQLEntities.Objects.ArticleInteractionEdge
    case "PharmaSearchResultEdge": return KnowledgeGraphQLEntities.Objects.PharmaSearchResultEdge
    case "QuestionSessionEdge": return KnowledgeGraphQLEntities.Objects.QuestionSessionEdge
    case "SearchResultEdge": return KnowledgeGraphQLEntities.Objects.SearchResultEdge
    case "TutorSessionEdge": return KnowledgeGraphQLEntities.Objects.TutorSessionEdge
    case "UserArticleEdge": return KnowledgeGraphQLEntities.Objects.UserArticleEdge
    case "UserEdge": return KnowledgeGraphQLEntities.Objects.UserEdge
    case "UserRecentArticleEdge": return KnowledgeGraphQLEntities.Objects.UserRecentArticleEdge
    case "ParticleExtension": return KnowledgeGraphQLEntities.Objects.ParticleExtension
    case "Particle": return KnowledgeGraphQLEntities.Objects.Particle
    case "Article": return KnowledgeGraphQLEntities.Objects.Article
    case "PhraseGroup": return KnowledgeGraphQLEntities.Objects.PhraseGroup
    case "PageInfo": return KnowledgeGraphQLEntities.Objects.PageInfo
    case "SearchResultPharmaAgentsConnection": return KnowledgeGraphQLEntities.Objects.SearchResultPharmaAgentsConnection
    case "SearchPageInfo": return KnowledgeGraphQLEntities.Objects.SearchPageInfo
    case "SearchResultPharmaAgentsEdge": return KnowledgeGraphQLEntities.Objects.SearchResultPharmaAgentsEdge
    case "SearchResultPharmaAgent": return KnowledgeGraphQLEntities.Objects.SearchResultPharmaAgent
    case "SearchResultArticle": return KnowledgeGraphQLEntities.Objects.SearchResultArticle
    case "SearchResultGuideline": return KnowledgeGraphQLEntities.Objects.SearchResultGuideline
    case "SearchResultMedia": return KnowledgeGraphQLEntities.Objects.SearchResultMedia
    case "SearchResultPharmaMonograph": return KnowledgeGraphQLEntities.Objects.SearchResultPharmaMonograph
    case "SearchTargetPharmaAgent": return KnowledgeGraphQLEntities.Objects.SearchTargetPharmaAgent
    case "UserConfig": return KnowledgeGraphQLEntities.Objects.UserConfig
    case "SememeDestination": return KnowledgeGraphQLEntities.Objects.SememeDestination
    case "User": return KnowledgeGraphQLEntities.Objects.User
    case "Answer": return KnowledgeGraphQLEntities.Objects.Answer
    case "Copyright": return KnowledgeGraphQLEntities.Objects.Copyright
    case "LabValuesSheet": return KnowledgeGraphQLEntities.Objects.LabValuesSheet
    case "LibraryArticle": return KnowledgeGraphQLEntities.Objects.LibraryArticle
    case "List": return KnowledgeGraphQLEntities.Objects.List
    case "MediaAsset": return KnowledgeGraphQLEntities.Objects.MediaAsset
    case "QuestionCase": return KnowledgeGraphQLEntities.Objects.QuestionCase
    case "QuestionSession": return KnowledgeGraphQLEntities.Objects.QuestionSession
    case "Tray": return KnowledgeGraphQLEntities.Objects.Tray
    case "StudyObjective": return KnowledgeGraphQLEntities.Objects.StudyObjective
    case "MobileAccess": return KnowledgeGraphQLEntities.Objects.MobileAccess
    case "MobileAccessError": return KnowledgeGraphQLEntities.Objects.MobileAccessError
    case "TrialInfo": return KnowledgeGraphQLEntities.Objects.TrialInfo
    case "IosSubscription": return KnowledgeGraphQLEntities.Objects.IosSubscription
    case "Authorization": return KnowledgeGraphQLEntities.Objects.Authorization
    case "AuthToken": return KnowledgeGraphQLEntities.Objects.AuthToken
    case "PharmaDatabase": return KnowledgeGraphQLEntities.Objects.PharmaDatabase
    case "Mutation": return KnowledgeGraphQLEntities.Objects.Mutation
    case "ArticleInteraction": return KnowledgeGraphQLEntities.Objects.ArticleInteraction
    case "MobileDeprecation": return KnowledgeGraphQLEntities.Objects.MobileDeprecation
    case "SearchSuggestionInstantResult": return KnowledgeGraphQLEntities.Objects.SearchSuggestionInstantResult
    case "SearchSuggestionInstantResultGroup": return KnowledgeGraphQLEntities.Objects.SearchSuggestionInstantResultGroup
    case "SearchSuggestionQuery": return KnowledgeGraphQLEntities.Objects.SearchSuggestionQuery
    case "SearchSuggestionQueryFilters": return KnowledgeGraphQLEntities.Objects.SearchSuggestionQueryFilters
    case "SearchTargetArticle": return KnowledgeGraphQLEntities.Objects.SearchTargetArticle
    case "SearchTargetPharmaMonograph": return KnowledgeGraphQLEntities.Objects.SearchTargetPharmaMonograph
    case "SearchTargetMedia": return KnowledgeGraphQLEntities.Objects.SearchTargetMedia
    case "SearchTargetExternalUrl": return KnowledgeGraphQLEntities.Objects.SearchTargetExternalUrl
    case "SearchTargetLibraryList": return KnowledgeGraphQLEntities.Objects.SearchTargetLibraryList
    case "SearchPhrasionary": return KnowledgeGraphQLEntities.Objects.SearchPhrasionary
    case "SecondaryTarget": return KnowledgeGraphQLEntities.Objects.SecondaryTarget
    case "SearchResultArticleNodeConnection": return KnowledgeGraphQLEntities.Objects.SearchResultArticleNodeConnection
    case "SearchResultArticleNodeEdge": return KnowledgeGraphQLEntities.Objects.SearchResultArticleNodeEdge
    case "SearchResultArticleNode": return KnowledgeGraphQLEntities.Objects.SearchResultArticleNode
    case "SearchTargetArticleNode": return KnowledgeGraphQLEntities.Objects.SearchTargetArticleNode
    case "SearchResultAmbossSubstanceNodeConnection": return KnowledgeGraphQLEntities.Objects.SearchResultAmbossSubstanceNodeConnection
    case "SearchResultAmbossSubstanceNodeEdge": return KnowledgeGraphQLEntities.Objects.SearchResultAmbossSubstanceNodeEdge
    case "SearchResultAmbossSubstanceNode": return KnowledgeGraphQLEntities.Objects.SearchResultAmbossSubstanceNode
    case "SearchTargetAmbossSubstanceNode": return KnowledgeGraphQLEntities.Objects.SearchTargetAmbossSubstanceNode
    case "SearchResultGuidelinesConnection": return KnowledgeGraphQLEntities.Objects.SearchResultGuidelinesConnection
    case "SearchResultGuidelinesEdge": return KnowledgeGraphQLEntities.Objects.SearchResultGuidelinesEdge
    case "SearchResultMediaConnection": return KnowledgeGraphQLEntities.Objects.SearchResultMediaConnection
    case "SearchResultMediaEdge": return KnowledgeGraphQLEntities.Objects.SearchResultMediaEdge
    case "SearchResultMediaType": return KnowledgeGraphQLEntities.Objects.SearchResultMediaType
    case "SearchFiltersMedia": return KnowledgeGraphQLEntities.Objects.SearchFiltersMedia
    case "SearchFilterValue": return KnowledgeGraphQLEntities.Objects.SearchFilterValue
    case "SearchInfo": return KnowledgeGraphQLEntities.Objects.SearchInfo
    case "SearchInfoResultData": return KnowledgeGraphQLEntities.Objects.SearchInfoResultData
    case "SearchInfoQueryData": return KnowledgeGraphQLEntities.Objects.SearchInfoQueryData
    case "UserProfileValidationError": return KnowledgeGraphQLEntities.Objects.UserProfileValidationError
    case "QuestionSetPerformance": return KnowledgeGraphQLEntities.Objects.QuestionSetPerformance
    case "CustomStudyPlanPerformance": return KnowledgeGraphQLEntities.Objects.CustomStudyPlanPerformance
    case "TermsAndConditions": return KnowledgeGraphQLEntities.Objects.TermsAndConditions
    case "OneTimeToken": return KnowledgeGraphQLEntities.Objects.OneTimeToken
    case "LibraryArchive": return KnowledgeGraphQLEntities.Objects.LibraryArchive
    case "FeedbackSubmissionResult": return KnowledgeGraphQLEntities.Objects.FeedbackSubmissionResult
    case "IosSubscriptionError": return KnowledgeGraphQLEntities.Objects.IosSubscriptionError
    case "ExternalAddition": return KnowledgeGraphQLEntities.Objects.ExternalAddition
    case "BlockedExternalAddition": return KnowledgeGraphQLEntities.Objects.BlockedExternalAddition
    case "BeforeResetStatsError": return KnowledgeGraphQLEntities.Objects.BeforeResetStatsError
    case "AnswerStatus": return KnowledgeGraphQLEntities.Objects.AnswerStatus
    case "ApplyProductKeyResult": return KnowledgeGraphQLEntities.Objects.ApplyProductKeyResult
    case "ProductKeyError": return KnowledgeGraphQLEntities.Objects.ProductKeyError
    case "AdyenPaymentError": return KnowledgeGraphQLEntities.Objects.AdyenPaymentError
    case "AdyenPaymentMethodError": return KnowledgeGraphQLEntities.Objects.AdyenPaymentMethodError
    case "ConfirmedInstitutionalLicenseDeletionError": return KnowledgeGraphQLEntities.Objects.ConfirmedInstitutionalLicenseDeletionError
    case "CreateSubscriptionError": return KnowledgeGraphQLEntities.Objects.CreateSubscriptionError
    case "CreateUpgradeError": return KnowledgeGraphQLEntities.Objects.CreateUpgradeError
    case "CreateUserAlreadyExistsError": return KnowledgeGraphQLEntities.Objects.CreateUserAlreadyExistsError
    case "CreateUserInputValidationError": return KnowledgeGraphQLEntities.Objects.CreateUserInputValidationError
    case "CreateUserSendConfirmEmailGuzzleExceptionError": return KnowledgeGraphQLEntities.Objects.CreateUserSendConfirmEmailGuzzleExceptionError
    case "DestinationAddressError": return KnowledgeGraphQLEntities.Objects.DestinationAddressError
    case "ExternalIdentityProviderFetchingError": return KnowledgeGraphQLEntities.Objects.ExternalIdentityProviderFetchingError
    case "InstitutionalLicenseNotFoundError": return KnowledgeGraphQLEntities.Objects.InstitutionalLicenseNotFoundError
    case "InstitutionalLicenseNotReverifiedError": return KnowledgeGraphQLEntities.Objects.InstitutionalLicenseNotReverifiedError
    case "InvoiceNotFoundError": return KnowledgeGraphQLEntities.Objects.InvoiceNotFoundError
    case "LectureSessionNotAccessibleError": return KnowledgeGraphQLEntities.Objects.LectureSessionNotAccessibleError
    case "LectureSessionUniversityMissmatchError": return KnowledgeGraphQLEntities.Objects.LectureSessionUniversityMissmatchError
    case "MissingBillingAddressError": return KnowledgeGraphQLEntities.Objects.MissingBillingAddressError
    case "PaypalPaymentError": return KnowledgeGraphQLEntities.Objects.PaypalPaymentError
    case "SecondaryEmailInputValidationError": return KnowledgeGraphQLEntities.Objects.SecondaryEmailInputValidationError
    case "SecondaryEmailTakenError": return KnowledgeGraphQLEntities.Objects.SecondaryEmailTakenError
    case "SetPasswordIdentifierError": return KnowledgeGraphQLEntities.Objects.SetPasswordIdentifierError
    case "SetPasswordInputError": return KnowledgeGraphQLEntities.Objects.SetPasswordInputError
    case "StripePaymentError": return KnowledgeGraphQLEntities.Objects.StripePaymentError
    case "UserExternalIdentityFetchingError": return KnowledgeGraphQLEntities.Objects.UserExternalIdentityFetchingError
    case "UserExternalIdentityNotFoundError": return KnowledgeGraphQLEntities.Objects.UserExternalIdentityNotFoundError
    case "LibraryArchiveArticle": return KnowledgeGraphQLEntities.Objects.LibraryArchiveArticle
    case "PharmaDrug": return KnowledgeGraphQLEntities.Objects.PharmaDrug
    case "PriceAndPackage": return KnowledgeGraphQLEntities.Objects.PriceAndPackage
    case "Dosage": return KnowledgeGraphQLEntities.Objects.Dosage
    case "AmbossSubstanceLink": return KnowledgeGraphQLEntities.Objects.AmbossSubstanceLink
    case "DosageContent": return KnowledgeGraphQLEntities.Objects.DosageContent
    case "PharmaText": return KnowledgeGraphQLEntities.Objects.PharmaText
    case "PocketCard": return KnowledgeGraphQLEntities.Objects.PocketCard
    case "PocketCardGroup": return KnowledgeGraphQLEntities.Objects.PocketCardGroup
    case "PocketCardSection": return KnowledgeGraphQLEntities.Objects.PocketCardSection
    default: return nil
    }
  }
}

public enum Objects {}
public enum Interfaces {}
public enum Unions {}

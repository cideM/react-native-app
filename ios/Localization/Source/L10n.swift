// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {

  public enum FeedbackView {
    /// Feedback
    public static var title: String { return L10n.tr("Localizable", "FeedbackView.title") }
  }

  public enum AboutSettings {
    public enum ConsentManagement {
      /// Privacy settings
      public static var title: String { return L10n.tr("Localizable", "about_settings.consent_management.title") }
    }
    public enum LegalNotice {
      /// Legal notice
      public static var title: String { return L10n.tr("Localizable", "about_settings.legal_notice.title") }
    }
    public enum Libraries {
      /// Open-source libraries
      public static var title: String { return L10n.tr("Localizable", "about_settings.libraries.title") }
    }
    public enum Privacy {
      /// Privacy policy
      public static var title: String { return L10n.tr("Localizable", "about_settings.privacy.title") }
    }
  }

  public enum AccountSettings {
    /// Account
    public static var title: String { return L10n.tr("Localizable", "account_settings.title") }
    public enum Account {
      /// Account
      public static var title: String { return L10n.tr("Localizable", "account_settings.account.title") }
    }
    public enum Alert {
      /// Do you really want to log out?
      public static var message: String { return L10n.tr("Localizable", "account_settings.alert.message") }
      /// Want to log out?
      public static var title: String { return L10n.tr("Localizable", "account_settings.alert.title") }
    }
    public enum DeleteAccountAlert {
      /// The deletion will affect all accounts of our platform. Please be aware that you need to unsubscribe separately through the AppStore.
      public static var message: String { return L10n.tr("Localizable", "account_settings.deleteAccountAlert.message") }
      /// You will be logged out after the account deletion
      public static var title: String { return L10n.tr("Localizable", "account_settings.deleteAccountAlert.title") }
    }
    public enum DeleteAccountButton {
      /// Delete account
      public static var title: String { return L10n.tr("Localizable", "account_settings.delete_account_button.title") }
    }
    public enum LogoutButton {
      /// LOG OUT
      public static var title: String { return L10n.tr("Localizable", "account_settings.logout_button.title") }
    }
  }

  public enum AppearanceSettings {
    /// Appearance
    public static var title: String { return L10n.tr("Localizable", "appearance_settings.title") }
    public enum KeepScreenOn {
      /// Keep screen on while reading articles
      public static var description: String { return L10n.tr("Localizable", "appearance_settings.keep_screen_on.description") }
      /// Keep screen active
      public static var title: String { return L10n.tr("Localizable", "appearance_settings.keep_screen_on.title") }
    }
    public enum Option {
      public enum Dark {
        /// Dark
        public static var title: String { return L10n.tr("Localizable", "appearance_settings.option.dark.title") }
      }
      public enum Light {
        /// Light
        public static var title: String { return L10n.tr("Localizable", "appearance_settings.option.light.title") }
      }
      public enum System {
        /// System
        public static var title: String { return L10n.tr("Localizable", "appearance_settings.option.system.title") }
      }
    }
  }

  public enum ContentList {
    public enum State {
      public enum Empty {
        /// Check the spelling or try another keyword.
        public static var subtitle: String { return L10n.tr("Localizable", "content_list.state.empty.subtitle") }
        /// No results
        public static var title: String { return L10n.tr("Localizable", "content_list.state.empty.title") }
      }
      public enum Error {
        /// Check your internet connection and try again.
        public static var subtitle: String { return L10n.tr("Localizable", "content_list.state.error.subtitle") }
        /// You’re currently offline
        public static var title: String { return L10n.tr("Localizable", "content_list.state.error.title") }
        public enum Button {
          /// Retry
          public static var title: String { return L10n.tr("Localizable", "content_list.state.error.button.title") }
        }
      }
    }
  }

  public enum Dashboard {
    /// Home
    public static var title: String { return L10n.tr("Localizable", "dashboard.title") }
    public enum HeaderView {
      /// Search diseases, drugs, calculators ...
      public static var searchPlaceholder: String { return L10n.tr("Localizable", "dashboard.headerView.searchPlaceholder") }
    }
    public enum IapBanner {
      /// Tap here for another free month.
      public static var subTitle: String { return L10n.tr("Localizable", "dashboard.iap_banner.sub_title") }
      /// Tap here for a free month
      public static var subTitleVariant: String { return L10n.tr("Localizable", "dashboard.iap_banner.sub_title_variant") }
      /// You are still in your 5 day free trial
      public static var title: String { return L10n.tr("Localizable", "dashboard.iap_banner.title") }
      /// Try unlimited AMBOSS access for free!
      public static var titleVariant: String { return L10n.tr("Localizable", "dashboard.iap_banner.title_variant") }
    }
    public enum Section {
      public enum Cme {
        /// Mit unseren Online-Fortbildungen den klinischen Horizont erweitern und CME-Punkte sammeln.
        public static var text: String { return L10n.tr("Localizable", "dashboard.section.cme.text") }
        /// CME-Kurse
        public static var title: String { return L10n.tr("Localizable", "dashboard.section.cme.title") }
      }
    }
    public enum Sections {
      public enum ClinicalTools {
        /// Clinical Resources
        public static var title: String { return L10n.tr("Localizable", "dashboard.sections.clinicalTools.title") }
        public enum Calculators {
          /// Search for calculators
          public static var searchPlaceholder: String { return L10n.tr("Localizable", "dashboard.sections.clinicalTools.calculators.searchPlaceholder") }
          /// Calculators
          public static var title: String { return L10n.tr("Localizable", "dashboard.sections.clinicalTools.calculators.title") }
        }
        public enum DrugDatabase {
          /// Search for drugs
          public static var searchPlaceholder: String { return L10n.tr("Localizable", "dashboard.sections.clinicalTools.drugDatabase.searchPlaceholder") }
          /// In partnership with
          public static var subtitle: String { return L10n.tr("Localizable", "dashboard.sections.clinicalTools.drugDatabase.subtitle") }
          /// Drugs
          public static var title: String { return L10n.tr("Localizable", "dashboard.sections.clinicalTools.drugDatabase.title") }
        }
        public enum Flowcharts {
          /// Search for flowcharts
          public static var searchPlaceholder: String { return L10n.tr("Localizable", "dashboard.sections.clinicalTools.flowcharts.searchPlaceholder") }
          /// Flowcharts
          public static var title: String { return L10n.tr("Localizable", "dashboard.sections.clinicalTools.flowcharts.title") }
        }
        public enum Guidelines {
          /// Search for clinical guidelines
          public static var searchPlaceholder: String { return L10n.tr("Localizable", "dashboard.sections.clinicalTools.guidelines.searchPlaceholder") }
          /// Clinical guidelines
          public static var title: String { return L10n.tr("Localizable", "dashboard.sections.clinicalTools.guidelines.title") }
        }
        public enum PocketGuides {
          /// BETA
          public static var badge: String { return L10n.tr("Localizable", "dashboard.sections.clinicalTools.pocketGuides.badge") }
          /// Pocket Guides
          public static var title: String { return L10n.tr("Localizable", "dashboard.sections.clinicalTools.pocketGuides.title") }
        }
      }
      public enum DiscoverAmboss {
        /// Discover Amboss
        public static var title: String { return L10n.tr("Localizable", "dashboard.sections.discoverAmboss.title") }
        public enum Sections {
          public enum ClinicalReference {
            /// Clinical reference
            public static var title: String { return L10n.tr("Localizable", "dashboard.sections.discoverAmboss.sections.clinicalReference.title") }
            public enum Articles {
              /// Article
              public static var title: String { return L10n.tr("Localizable", "dashboard.sections.discoverAmboss.sections.clinicalReference.articles.title") }
            }
            public enum DrugDatabase {
              /// Drug database
              public static var title: String { return L10n.tr("Localizable", "dashboard.sections.discoverAmboss.sections.clinicalReference.drugDatabase.title") }
            }
          }
          public enum ClinicalTools {
            /// Clinical tools
            public static var title: String { return L10n.tr("Localizable", "dashboard.sections.discoverAmboss.sections.clinicalTools.title") }
            public enum Algorithms {
              /// Algorithms
              public static var title: String { return L10n.tr("Localizable", "dashboard.sections.discoverAmboss.sections.clinicalTools.algorithms.title") }
            }
            public enum Calculators {
              /// Cl. Calculators
              public static var title: String { return L10n.tr("Localizable", "dashboard.sections.discoverAmboss.sections.clinicalTools.calculators.title") }
            }
          }
        }
      }
      public enum News {
        /// AMBOSS NEWS
        public static var title: String { return L10n.tr("Localizable", "dashboard.sections.news.title") }
      }
      public enum RecentlyRead {
        /// Recently read
        public static var title: String { return L10n.tr("Localizable", "dashboard.sections.recentlyRead.title") }
      }
      public enum SectionHeader {
        /// All
        public static var all: String { return L10n.tr("Localizable", "dashboard.sections.sectionHeader.all") }
      }
    }
  }

  public enum Dosage {
    public enum Error {
      public enum Offline {
        /// 
        public static var message: String { return L10n.tr("Localizable", "dosage.error.offline.message") }
      }
    }
    public enum Popover {
      /// Dosage
      public static var title: String { return L10n.tr("Localizable", "dosage.popover.title") }
    }
  }

  public enum Drug {
    /// HANDELSPRÄPARAT
    public static var activeIngredientLabel: String { return L10n.tr("Localizable", "drug.activeIngredientLabel") }
    /// Information from the IFAP drug database
    public static var ifapInformationNote: String { return L10n.tr("Localizable", "drug.iFAPInformationNote") }
    public enum CommercialDrugsButton {
      /// ANDERE HANDELSPRÄPARATE
      public static var title: String { return L10n.tr("Localizable", "drug.commercialDrugsButton.title") }
    }
    public enum Search {
      /// Andere Handelspräparate finden
      public static var firstTitle: String { return L10n.tr("Localizable", "drug.search.first_title") }
      /// APPLIKATIONSWEGE
      public static var tagsTitle: String { return L10n.tr("Localizable", "drug.search.tags_title") }
    }
    public enum SearchBar {
      public enum Placeholder {
        /// Handelspräparate filtern
        public static var text: String { return L10n.tr("Localizable", "drug.search_bar.placeholder.text") }
      }
    }
    public enum SectionHeader {
      public enum EmptyLabel {
        /// Keine Information verfügbar
        public static var text: String { return L10n.tr("Localizable", "drug.sectionHeader.emptyLabel.text") }
      }
    }
  }

  public enum EmailSendingError {
    public enum ClientNotConfigured {
      /// Your device isn't configured to send emails. Add an email account in your settings to start sending.
      public static var message: String { return L10n.tr("Localizable", "email_sending_error.client_not_configured.message") }
      /// Can't send emails
      public static var title: String { return L10n.tr("Localizable", "email_sending_error.client_not_configured.title") }
    }
  }

  public enum Error {
    public enum Deeplink {
      /// Couldn't find this content. Try updating your library. Want to open it in your browser instead?
      public static var message: String { return L10n.tr("Localizable", "error.deeplink.message") }
      /// Oops!
      public static var title: String { return L10n.tr("Localizable", "error.deeplink.title") }
      public enum Article {
        /// This link didn't work. Want to try again using your web browser?
        public static var message: String { return L10n.tr("Localizable", "error.deeplink.article.message") }
      }
    }
    public enum Generic {
      /// An unexpected error occurred. Please try again later.
      public static var message: String { return L10n.tr("Localizable", "error.generic.message") }
      /// That shouldn't have happened
      public static var title: String { return L10n.tr("Localizable", "error.generic.title") }
    }
    public enum Internet {
      public enum Message {
        /// Check your internet connection and try again.
        public static var title: String { return L10n.tr("Localizable", "error.internet.message.title") }
      }
    }
    public enum Offline {
      /// Please connect to the internet to keep using the app.
      public static var message: String { return L10n.tr("Localizable", "error.offline.message") }
      /// No connection
      public static var title: String { return L10n.tr("Localizable", "error.offline.title") }
      public enum Library {
        /// No internet connection. Reconnect to check for library updates.
        public static var message: String { return L10n.tr("Localizable", "error.offline.library.message") }
      }
    }
  }

  public enum ExtensionCellView {
    public enum Button {
      /// Show in article
      public static var title: String { return L10n.tr("Localizable", "extension_cell_view.button.title") }
    }
  }

  public enum ExtensionView {
    /// Your notes
    public static var title: String { return L10n.tr("Localizable", "extension_view.title") }
  }

  public enum Feedback {
    /// Feedback
    public static var title: String { return L10n.tr("Localizable", "feedback.title") }
    public enum Header {
      /// What is the nature of your feedback?
      public static var title: String { return L10n.tr("Localizable", "feedback.header.title") }
    }
    public enum Intention {
      /// Select
      public static var placeholder: String { return L10n.tr("Localizable", "feedback.intention.placeholder") }
    }
    public enum IntentionsMenu {
      /// Cancel
      public static var cancelButton: String { return L10n.tr("Localizable", "feedback.intentionsMenu.cancelButton") }
      public enum Intentions {
        /// Incorrect content
        public static var incorrectContent: String { return L10n.tr("Localizable", "feedback.intentionsMenu.intentions.incorrectContent") }
        /// Language issue
        public static var languageIssue: String { return L10n.tr("Localizable", "feedback.intentionsMenu.intentions.languageIssue") }
        /// Media feedback
        public static var mediaFeedback: String { return L10n.tr("Localizable", "feedback.intentionsMenu.intentions.mediaFeedback") }
        /// Missing content
        public static var missingContent: String { return L10n.tr("Localizable", "feedback.intentionsMenu.intentions.missingContent") }
        /// Praise
        public static var praise: String { return L10n.tr("Localizable", "feedback.intentionsMenu.intentions.praise") }
        /// General feedback
        public static var productFeedback: String { return L10n.tr("Localizable", "feedback.intentionsMenu.intentions.productFeedback") }
        /// Technical issue
        public static var technicalIssue: String { return L10n.tr("Localizable", "feedback.intentionsMenu.intentions.technicalIssue") }
      }
    }
    public enum Message {
      /// Write to us
      public static var placeholder: String { return L10n.tr("Localizable", "feedback.message.placeholder") }
    }
    public enum SendFeedbackButton {
      /// Send feedback
      public static var title: String { return L10n.tr("Localizable", "feedback.sendFeedbackButton.title") }
    }
  }

  public enum FirstLaunch {
    public enum InfoAlert {
      /// Library updates and offline access
      public static var title: String { return L10n.tr("Localizable", "first_launch.info_alert.title") }
    }
  }

  public enum ForceLibraryUpdate {
    public enum Downloading {
      /// Downloading...
      public static var status: String { return L10n.tr("Localizable", "force_library_update.downloading.status") }
    }
    public enum Installing {
      /// Installing...
      public static var status: String { return L10n.tr("Localizable", "force_library_update.installing.status") }
    }
    public enum Updating {
      /// The latest content is about to be released onto your phone.
      public static var message: String { return L10n.tr("Localizable", "force_library_update.updating.message") }
      /// Writing the discharge note
      public static var title: String { return L10n.tr("Localizable", "force_library_update.updating.title") }
    }
  }

  public enum Gallery {
    public enum Pill {
      public enum Feature {
        public enum Title {
          /// Radio-
          /// logy
          public static var easyradiology: String { return L10n.tr("Localizable", "gallery.pill.feature.title.easyradiology") }
          /// Medi
          /// Tricks
          public static var meditricks: String { return L10n.tr("Localizable", "gallery.pill.feature.title.meditricks") }
          /// Neuro
          /// anatomy
          public static var meditricksNeuroanatomy: String { return L10n.tr("Localizable", "gallery.pill.feature.title.meditricksNeuroanatomy") }
          /// 3D
          public static var miamed3dModel: String { return L10n.tr("Localizable", "gallery.pill.feature.title.miamed3dModel") }
          /// Auditor
          public static var miamedAuditor: String { return L10n.tr("Localizable", "gallery.pill.feature.title.miamedAuditor") }
          /// Calculator
          public static var miamedCalculator: String { return L10n.tr("Localizable", "gallery.pill.feature.title.miamedCalculator") }
          /// Patient
          /// Info
          public static var miamedPatientInformation: String { return L10n.tr("Localizable", "gallery.pill.feature.title.miamedPatientInformation") }
          /// Web
          public static var miamedWebContent: String { return L10n.tr("Localizable", "gallery.pill.feature.title.miamedWebContent") }
          /// More
          public static var other: String { return L10n.tr("Localizable", "gallery.pill.feature.title.other") }
          /// Overlay
          public static var overlay: String { return L10n.tr("Localizable", "gallery.pill.feature.title.overlay") }
          /// Smart
          /// Zoom
          public static var smartzoom: String { return L10n.tr("Localizable", "gallery.pill.feature.title.smartzoom") }
          /// Video
          public static var video: String { return L10n.tr("Localizable", "gallery.pill.feature.title.video") }
        }
      }
    }
  }

  public enum Generic {
    /// Continue
    public static var alertDefaultButton: String { return L10n.tr("Localizable", "generic.alert_default_button") }
    /// Next
    public static var next: String { return L10n.tr("Localizable", "generic.next") }
    /// No
    public static var no: String { return L10n.tr("Localizable", "generic.no") }
    /// Try again
    public static var retry: String { return L10n.tr("Localizable", "generic.retry") }
    /// Save
    public static var save: String { return L10n.tr("Localizable", "generic.save") }
    /// Yes
    public static var yes: String { return L10n.tr("Localizable", "generic.yes") }
  }

  public enum Healthcare {
    public enum Disclaimer {
      /// Bestätigen
      public static var accept: String { return L10n.tr("Localizable", "healthcare.disclaimer.accept") }
      /// Ich bestätige, dass ich Angehörige:r eines Heilberufes im Bereich der Medizin, Zahnmedizin, Pflege, Psychologie oder Pharmazie bin bzw. mich in der Ausbildung zu diesem befinde. Gleichzeitig versichere ich, der AMBOSS GmbH einen schriftlichen Nachweis (z.B. Approbation, Immatrikulationsbescheinigung, Ausbildungsbescheinigung oder Abschlusszeugnis) hierüber an die Emailadresse nachweis@amboss.com zukommen zu lassen. Ich nehme zur Kenntnis, dass sich sämtliche Angaben in AMBOSS auf den medizinischen Standard in Deutschland beziehen und, dass diagnostische und/oder therapeutischen Vorgehensweisen sowie der arzneimittelrechtliche Zulassungsstatus genannter Handelspräparate in anderen Ländern abweichend geregelt sein können.
      public static var content: String { return L10n.tr("Localizable", "healthcare.disclaimer.content") }
      /// Nicht bestätigen
      public static var reject: String { return L10n.tr("Localizable", "healthcare.disclaimer.reject") }
      /// Medikamentenhandelsnamen einblenden
      public static var title: String { return L10n.tr("Localizable", "healthcare.disclaimer.title") }
    }
  }

  public enum HtmlDialogue {
    /// Accept
    public static var acceptButtonTitle: String { return L10n.tr("Localizable", "html_dialogue.accept_button_title") }
    /// Don't accept
    public static var denyButtonTitle: String { return L10n.tr("Localizable", "html_dialogue.deny_button_title") }
  }

  public enum Iap {
    public enum Paywall {
      /// Become an AMBOSS member now
      public static var subTitle: String { return L10n.tr("Localizable", "iap.paywall.sub_title") }
      /// Enjoy AMBOSS uninterrupted
      public static var title: String { return L10n.tr("Localizable", "iap.paywall.title") }
      public enum Info1 {
        /// Optimized for quick reference.
        /// Get clinical answers in just 5 seconds.
        public static var subTitle: String { return L10n.tr("Localizable", "iap.paywall.info1.sub_title") }
        /// Smart content made for medical practice
        public static var title: String { return L10n.tr("Localizable", "iap.paywall.info1.title") }
      }
      public enum Info2 {
        /// Flowcharts, checklists, drug dosing, and more
        public static var subTitle: String { return L10n.tr("Localizable", "iap.paywall.info2.sub_title") }
        /// Decision support tools for better outcomes
        public static var title: String { return L10n.tr("Localizable", "iap.paywall.info2.title") }
      }
      public enum Info3 {
        /// Bad WiFi in your hospital?
        /// Never lose access even when offline.
        public static var subTitle: String { return L10n.tr("Localizable", "iap.paywall.info3.sub_title") }
        /// Our mobile app for on-the-go reference
        public static var title: String { return L10n.tr("Localizable", "iap.paywall.info3.title") }
      }
      public enum Payment {
        public enum Info {
          /// Payment will be charged to your Apple ID account at the confirmation of purchase. Your subscription will automatically renew unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions by going to your account settings on the App Store after purchase.
          public static var title: String { return L10n.tr("Localizable", "iap.paywall.payment.info.title") }
        }
      }
    }
    public enum Settings {
      public enum Store {
        /// Shop
        public static var title: String { return L10n.tr("Localizable", "iap.settings.store.title") }
      }
    }
    public enum Store {
      /// Purchase an AMBOSS iOS subscription
      public static var title: String { return L10n.tr("Localizable", "iap.store.title") }
      public enum Error {
        /// Payments aren't authorized on this device.
        public static var paymentNotAllowed: String { return L10n.tr("Localizable", "iap.store.error.payment_not_allowed") }
        /// You haven’t accepted Apple Music's privacy policy.
        public static var privacyAcknowledgementRequired: String { return L10n.tr("Localizable", "iap.store.error.privacy_acknowledgement_required") }
      }
      public enum Errormessage {
        /// Couldn't connect your purchase to your AMBOSS account.
        public static var linking: String { return L10n.tr("Localizable", "iap.store.errormessage.linking") }
        /// Your payment did not go through successfully.
        public static var purchasing: String { return L10n.tr("Localizable", "iap.store.errormessage.purchasing") }
        /// Your purchase recovery was unsuccessful.
        public static var restoring: String { return L10n.tr("Localizable", "iap.store.errormessage.restoring") }
      }
      public enum ExternalSubscription {
        /// You're already subscribed to AMBOSS.
        public static var headline: String { return L10n.tr("Localizable", "iap.store.external_subscription.headline") }
      }
      public enum IdleInapppurchase {
        /// Sign up to start your trial
        public static var buyButton: String { return L10n.tr("Localizable", "iap.store.idle_inapppurchase.buy_button") }
        /// Start with a %@ free trial.
        public static func headline(_ p1: Any) -> String {
          return L10n.tr("Localizable", "iap.store.idle_inapppurchase.headline", String(describing: p1))
        }
        /// Re-activate subscription
        public static var restoreButton: String { return L10n.tr("Localizable", "iap.store.idle_inapppurchase.restore_button") }
        public enum Subheadline {
          /// Subscribe to AMBOSS for %@ / month
          public static func withFreeOffer(_ p1: Any) -> String {
            return L10n.tr("Localizable", "iap.store.idle_inapppurchase.subheadline.with_free_offer", String(describing: p1))
          }
          /// Subscribe to AMBOSS for %@ / month
          public static func withoutFreeOffer(_ p1: Any) -> String {
            return L10n.tr("Localizable", "iap.store.idle_inapppurchase.subheadline.without_free_offer", String(describing: p1))
          }
        }
      }
      public enum Inapppurchase {
        /// Payment will be charged to your Apple ID account at the confirmation of purchase. Your subscription will automatically renew unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions by going to your account settings on the App Store after purchase.
        public static var disclaimer: String { return L10n.tr("Localizable", "iap.store.inapppurchase.disclaimer") }
      }
      public enum Introductory {
        /// Day
        public static var day: String { return L10n.tr("Localizable", "iap.store.introductory.day") }
        /// Days
        public static var days: String { return L10n.tr("Localizable", "iap.store.introductory.days") }
        /// Month
        public static var month: String { return L10n.tr("Localizable", "iap.store.introductory.month") }
        /// Months
        public static var months: String { return L10n.tr("Localizable", "iap.store.introductory.months") }
        /// Week
        public static var week: String { return L10n.tr("Localizable", "iap.store.introductory.week") }
        /// Weeks
        public static var weeks: String { return L10n.tr("Localizable", "iap.store.introductory.weeks") }
        /// Year
        public static var year: String { return L10n.tr("Localizable", "iap.store.introductory.year") }
        /// Years
        public static var years: String { return L10n.tr("Localizable", "iap.store.introductory.years") }
      }
      public enum PerksPage {
        public enum FifthPerk {
          /// Master medical information with the help of smart study tools
          public static var title: String { return L10n.tr("Localizable", "iap.store.perks_page.fifth_perk.title") }
        }
        public enum FirstPerk {
          /// Smart content made for medical practice. Get clinical answers in just 5 seconds
          public static var title: String { return L10n.tr("Localizable", "iap.store.perks_page.first_perk.title") }
        }
        public enum FourthPerk {
          /// Use AMBOSS on just about any device
          public static var title: String { return L10n.tr("Localizable", "iap.store.perks_page.fourth_perk.title") }
        }
        public enum SecondPerk {
          /// Bad WiFi in your hospital? Never lose access, even when offline
          public static var title: String { return L10n.tr("Localizable", "iap.store.perks_page.second_perk.title") }
        }
        public enum SixthPerk {
          /// Practice diagnoses with medical images that highlight affected areas 
          public static var title: String { return L10n.tr("Localizable", "iap.store.perks_page.sixth_perk.title") }
        }
        public enum ThirdPerk {
          /// Go through thousands of high-yield exam-style questions
          public static var title: String { return L10n.tr("Localizable", "iap.store.perks_page.third_perk.title") }
        }
      }
      public enum UnlinkedInapppurchase {
        /// Cancel subscription
        public static var cancelButton: String { return L10n.tr("Localizable", "iap.store.unlinked_inapppurchase.cancel_button") }
        /// You have an active AMBOSS iOS subscription
        public static var headline: String { return L10n.tr("Localizable", "iap.store.unlinked_inapppurchase.headline") }
        /// Link to your account
        public static var linkButton: String { return L10n.tr("Localizable", "iap.store.unlinked_inapppurchase.link_button") }
      }
    }
  }

  public enum ImageGallery {
    public enum Image {
      public enum CopyrightButton {
        /// © Copyright
        public static var title: String { return L10n.tr("Localizable", "image_gallery.image.copyright_button.title") }
      }
    }
  }

  public enum InAppPurchase {
    public enum Paywall {
      /// Buy license
      public static var buyLicense: String { return L10n.tr("Localizable", "in_app_purchase.paywall.buy_license") }
      public enum AccessRequired {
        /// Looks like you don't have an active membership. But we can fix that. Head to the store now to purchase one.
        public static var message: String { return L10n.tr("Localizable", "in_app_purchase.paywall.access_required.message") }
        /// This content is only available for members
        public static var title: String { return L10n.tr("Localizable", "in_app_purchase.paywall.access_required.title") }
      }
      public enum CampusLicenseExpired {
        /// This is to check if you're still a student or if the license is still active. No longer have access? You can purchase your own subcription in the shop
        public static var message: String { return L10n.tr("Localizable", "in_app_purchase.paywall.campus_license_expired.message") }
        /// Verify your campus license by connecting to your university network
        public static var title: String { return L10n.tr("Localizable", "in_app_purchase.paywall.campus_license_expired.title") }
      }
      public enum OfflineAccessExpired {
        /// Your offline access to AMBOSS has expired. Please reconnect to your network.
        public static var message: String { return L10n.tr("Localizable", "in_app_purchase.paywall.offline_access_expired.message") }
        /// Offline access expired
        public static var title: String { return L10n.tr("Localizable", "in_app_purchase.paywall.offline_access_expired.title") }
      }
      public enum UnknownAccessError {
        /// Seems like an error on our side. Try again in a bit.
        public static var message: String { return L10n.tr("Localizable", "in_app_purchase.paywall.unknown_access_error.message") }
        /// Oh no, you can't access this now.
        public static var title: String { return L10n.tr("Localizable", "in_app_purchase.paywall.unknown_access_error.title") }
      }
    }
  }

  public enum Initialization {
    /// Give us a couple seconds, we’re setting up the app for you...
    public static var label: String { return L10n.tr("Localizable", "initialization.label") }
  }

  public enum LearningCard {
    public enum Error {
      public enum LearningCardMetadataNotFound {
        /// An error occurred while trying to access the article. Please update your library and try again.
        public static var message: String { return L10n.tr("Localizable", "learning_card.error.learning_card_metadata_not_found.message") }
      }
      public enum LearningCardNotFound {
        /// An error occurred while trying to access the article. Please check your connection and try again.
        public static var message: String { return L10n.tr("Localizable", "learning_card.error.learning_card_not_found.message") }
      }
    }
  }

  public enum LearningCardOptionsView {
    /// Article options
    public static var title: String { return L10n.tr("Localizable", "learning_card_options_view.title") }
    public enum Callout {
      /// Student features, such as High-yield, have been removed from Clinician mode.
      public static var text: String { return L10n.tr("Localizable", "learning_card_options_view.callout.text") }
      /// Switch to Student mode
      public static var underlinedText: String { return L10n.tr("Localizable", "learning_card_options_view.callout.underlinedText") }
    }
    public enum CreateQuestions {
      /// Start Qbank session
      public static var title: String { return L10n.tr("Localizable", "learning_card_options_view.create_questions.title") }
    }
    public enum Learned {
      /// Learned
      public static var title: String { return L10n.tr("Localizable", "learning_card_options_view.learned.title") }
    }
    public enum Modes {
      /// Article preferences
      public static var subheading: String { return L10n.tr("Localizable", "learning_card_options_view.modes.subheading") }
      public enum HighYield {
        /// View only information relevant to your study objective
        public static var subtitle: String { return L10n.tr("Localizable", "learning_card_options_view.modes.high_yield.subtitle") }
        /// High-Yield
        public static var title: String { return L10n.tr("Localizable", "learning_card_options_view.modes.high_yield.title") }
      }
      public enum Highlighting {
        /// Highlights the most relevant content for your chosen exam
        public static var subtitle: String { return L10n.tr("Localizable", "learning_card_options_view.modes.highlighting.subtitle") }
        /// Key exam info
        public static var title: String { return L10n.tr("Localizable", "learning_card_options_view.modes.highlighting.title") }
      }
      public enum LearningRadar {
        /// Highlight facts from incorrectly answered questions in red
        public static var subtitle: String { return L10n.tr("Localizable", "learning_card_options_view.modes.learning_radar.subtitle") }
        /// Learning Radar
        public static var title: String { return L10n.tr("Localizable", "learning_card_options_view.modes.learning_radar.title") }
      }
      public enum PhysikumFokus {
        /// Nur Prüfungsinhalte anzeigen
        public static var subtitle: String { return L10n.tr("Localizable", "learning_card_options_view.modes.physikum_fokus.subtitle") }
        /// Physikum-Fokus
        public static var title: String { return L10n.tr("Localizable", "learning_card_options_view.modes.physikum_fokus.title") }
      }
    }
    public enum Share {
      /// Share
      public static var title: String { return L10n.tr("Localizable", "learning_card_options_view.share.title") }
    }
    public enum TextSizeCell {
      /// Text size
      public static var title: String { return L10n.tr("Localizable", "learning_card_options_view.text_size_cell.title") }
    }
  }

  public enum LearningCardToolbar {
    public enum Button {
      public enum Title {
        /// Back
        public static var back: String { return L10n.tr("Localizable", "learning_card_toolbar.button.title.back") }
        /// Find text
        public static var find: String { return L10n.tr("Localizable", "learning_card_toolbar.button.title.find") }
        /// Collapse
        public static var fold: String { return L10n.tr("Localizable", "learning_card_toolbar.button.title.fold") }
        /// Outline
        public static var index: String { return L10n.tr("Localizable", "learning_card_toolbar.button.title.index") }
        /// Forward
        public static var next: String { return L10n.tr("Localizable", "learning_card_toolbar.button.title.next") }
        /// Expand
        public static var unfold: String { return L10n.tr("Localizable", "learning_card_toolbar.button.title.unfold") }
      }
    }
  }

  public enum Library {
    /// Library
    public static var title: String { return L10n.tr("Localizable", "library.title") }
    public enum LearningCard {
      public enum TableDetailView {
        /// Table
        public static var title: String { return L10n.tr("Localizable", "library.learning_card.table_detail_view.title") }
      }
    }
  }

  public enum LibrarySettings {
    /// Checking for updates...
    public static var checkingForUpdateMessage: String { return L10n.tr("Localizable", "librarySettings.checkingForUpdateMessage") }
    /// Installing update...
    public static var installingUpdateMessage: String { return L10n.tr("Localizable", "librarySettings.installingUpdateMessage") }
    /// Update
    public static var update: String { return L10n.tr("Localizable", "librarySettings.update") }
    /// Update available
    public static var updateAvailableMessage: String { return L10n.tr("Localizable", "librarySettings.updateAvailableMessage") }
    /// Updated
    public static var updated: String { return L10n.tr("Localizable", "librarySettings.updated") }
    /// Update failed
    public static var updateFailed: String { return L10n.tr("Localizable", "librarySettings.updateFailed") }
    /// Updating...
    public static var updatingMessage: String { return L10n.tr("Localizable", "librarySettings.UpdatingMessage") }
    /// Updated
    public static var upToDateMessage: String { return L10n.tr("Localizable", "librarySettings.upToDateMessage") }
    public enum AutomaticUpdates {
      /// Updates will be downloaded automatically in WiFi
      public static var subtitle: String { return L10n.tr("Localizable", "librarySettings.automaticUpdates.subtitle") }
      /// Automatic Updates
      public static var title: String { return L10n.tr("Localizable", "librarySettings.automaticUpdates.title") }
    }
    public enum CancelButton {
      /// Cancel
      public static var title: String { return L10n.tr("Localizable", "librarySettings.cancelButton.title") }
    }
    public enum InstallButton {
      /// Install
      public static var title: String { return L10n.tr("Localizable", "librarySettings.installButton.title") }
    }
    public enum LastUpdate {
      /// Last update: %@
      public static func format(_ p1: Any) -> String {
        return L10n.tr("Localizable", "librarySettings.lastUpdate.format", String(describing: p1))
      }
    }
    public enum Library {
      /// Library
      public static var title: String { return L10n.tr("Localizable", "librarySettings.library.title") }
      public enum Subtitle {
        /// Update is being downloaded %@
        public static func downloading(_ p1: Any) -> String {
          return L10n.tr("Localizable", "librarySettings.library.subtitle.downloading", String(describing: p1))
        }
        /// Library is being installed
        public static var installing: String { return L10n.tr("Localizable", "librarySettings.library.subtitle.installing") }
      }
    }
    public enum LibraryUpdate {
      /// Update my Library automatically
      public static var title: String { return L10n.tr("Localizable", "librarySettings.libraryUpdate.title") }
    }
    public enum Pharma {
      /// Arzneimitteldatenbank
      public static var title: String { return L10n.tr("Localizable", "librarySettings.pharma.title") }
      public enum DeleteConfirmationAlert {
        /// The drug information will not be shown in the offline search results.
        /// You can re-install it any time.
        public static var message: String { return L10n.tr("Localizable", "librarySettings.pharma.deleteConfirmationAlert.message") }
        /// Are you sure to delete the pharma library?
        public static var title: String { return L10n.tr("Localizable", "librarySettings.pharma.deleteConfirmationAlert.title") }
        public enum CancelAction {
          /// Cancel
          public static var title: String { return L10n.tr("Localizable", "librarySettings.pharma.deleteConfirmationAlert.cancelAction.title") }
        }
        public enum ConfirmAction {
          /// Confirm
          public static var title: String { return L10n.tr("Localizable", "librarySettings.pharma.deleteConfirmationAlert.confirmAction.title") }
        }
      }
      public enum DeleteDisclaimer {
        /// Swipe left to save space
        public static var title: String { return L10n.tr("Localizable", "librarySettings.pharma.deleteDisclaimer.title") }
      }
      public enum UpdateFailed {
        public enum SomethingWentWrong {
          /// Something went wrong while trying to update the pharma database.
          /// Please try updating again.
          public static var description: String { return L10n.tr("Localizable", "librarySettings.pharma.updateFailed.somethingWentWrong.description") }
        }
      }
    }
    public enum PharmaUpdate {
      /// Keep the pharma library  up to date
      public static var title: String { return L10n.tr("Localizable", "librarySettings.pharmaUpdate.title") }
    }
    public enum UpdateButton {
      /// Update
      public static var title: String { return L10n.tr("Localizable", "librarySettings.updateButton.title") }
    }
    public enum UpdateFailed {
      /// Couldn't update
      public static var title: String { return L10n.tr("Localizable", "librarySettings.updateFailed.title") }
      public enum LackOfStorage {
        /// Not enough storage to update. Free some up so you can update your library to the latest content.
        public static var description: String { return L10n.tr("Localizable", "librarySettings.updateFailed.lackOfStorage.description") }
      }
      public enum SomethingWentWrong {
        /// Something went wrong while trying to update the library.
        /// Please try updating again.
        public static var description: String { return L10n.tr("Localizable", "librarySettings.updateFailed.somethingWentWrong.description") }
      }
    }
  }

  public enum Licenses {
    /// Licences
    public static var title: String { return L10n.tr("Localizable", "licenses.title") }
  }

  public enum Lists {
    /// Lists
    public static var title: String { return L10n.tr("Localizable", "lists.title") }
    public enum Favorites {
      /// Favorites
      public static var title: String { return L10n.tr("Localizable", "lists.favorites.title") }
    }
    public enum Learned {
      /// Studied
      public static var title: String { return L10n.tr("Localizable", "lists.learned.title") }
    }
    public enum Recents {
      /// History
      public static var title: String { return L10n.tr("Localizable", "lists.recents.title") }
      public enum EmptyState {
        /// As you search and read through our content, this area will display your most recently viewed articles.
        public static var text: String { return L10n.tr("Localizable", "lists.recents.emptyState.text") }
      }
    }
  }

  public enum Login {
    /// Email address
    public static var emailPlaceholder: String { return L10n.tr("Localizable", "login.email_placeholder") }
    /// Forgot password?
    public static var forgotPasswordButtonTitle: String { return L10n.tr("Localizable", "login.forgot_password_button_title") }
    /// Password
    public static var passwordPlaceholder: String { return L10n.tr("Localizable", "login.password_placeholder") }
    /// Login
    public static var title: String { return L10n.tr("Localizable", "login.title") }
    public enum Error {
      /// Login failed
      public static var title: String { return L10n.tr("Localizable", "login.error.title") }
      public enum InvalidCredentials {
        /// Username and password do not match.
        public static var message: String { return L10n.tr("Localizable", "login.error.invalid_credentials.message") }
      }
    }
    public enum SsoHint {
      /// Signed up using Google, Facebook or your Institution?
      public static var firstLine: String { return L10n.tr("Localizable", "login.sso_hint.first_line") }
      /// You’ll need to set a password first
      public static var secondLine: String { return L10n.tr("Localizable", "login.sso_hint.second_line") }
    }
  }

  public enum News {
    /// News
    public static var title: String { return L10n.tr("Localizable", "news.title") }
  }

  public enum Note {
    /// Edit your personal note
    public static var placeholder: String { return L10n.tr("Localizable", "note.placeholder") }
    /// Note
    public static var title: String { return L10n.tr("Localizable", "note.title") }
    public enum Alert {
      /// This note contains unsaved changes. Are you sure that you want to leave without saving?
      public static var leavePageConfirmationMessage: String { return L10n.tr("Localizable", "note.alert.leave_page_confirmation_message") }
      /// Leave the page?
      public static var leavePageConfirmationTitle: String { return L10n.tr("Localizable", "note.alert.leave_page_confirmation_title") }
    }
  }

  public enum Password {
    /// This email is already registered.
    public static var errorEmailAlreadyRegistered: String { return L10n.tr("Localizable", "password.error_email_already_registered") }
  }

  public enum PricesAndPackageSizes {
    public enum AvpLabel {
      /// Preisangaben entsprechen Apothekenverkaufspreis (AVP)
      public static var title: String { return L10n.tr("Localizable", "prices_and_package_sizes.avp_label.title") }
    }
    public enum KtpLabel {
      /// KTP = keine therapiegerechte Packungsgröße
      public static var title: String { return L10n.tr("Localizable", "prices_and_package_sizes.ktp_label.title") }
    }
    public enum TableView {
      /// Preise und Packungsgrößen
      public static var title: String { return L10n.tr("Localizable", "prices_and_package_sizes.table_view.title") }
    }
    public enum UvpLabel {
      /// 1 Aufgrund fehlendem AVP, hier unverbindliche Preisempfehlung (UVP)
      public static var title: String { return L10n.tr("Localizable", "prices_and_package_sizes.uvp_label.title") }
    }
  }

  public enum RecommendUpdate {
    public enum Alert {
      /// Download
      public static var downloadAction: String { return L10n.tr("Localizable", "recommend_update.alert.download_action") }
      /// Later
      public static var laterAction: String { return L10n.tr("Localizable", "recommend_update.alert.later_action") }
      /// Update to the latest version of the library for the most current medical information.
      public static var message: String { return L10n.tr("Localizable", "recommend_update.alert.message") }
      /// Update the library
      public static var title: String { return L10n.tr("Localizable", "recommend_update.alert.title") }
    }
  }

  public enum RedeemCode {
    /// Redeem access code
    public static var title: String { return L10n.tr("Localizable", "redeem_code.title") }
    public enum Button {
      public enum Title {
        /// Done
        public static var done: String { return L10n.tr("Localizable", "redeem_code.button.title.done") }
        /// Processing...
        public static var loading: String { return L10n.tr("Localizable", "redeem_code.button.title.loading") }
        /// Redeem Code
        public static var normal: String { return L10n.tr("Localizable", "redeem_code.button.title.normal") }
      }
    }
    public enum Callout {
      public enum Title {
        /// Access codes can only be redeemed once
        public static var info: String { return L10n.tr("Localizable", "redeem_code.callout.title.info") }
        /// You've successfully redeemed your access code, and your account is now activated.
        public static var success: String { return L10n.tr("Localizable", "redeem_code.callout.title.success") }
      }
    }
    public enum Error {
      /// You're already subscribed to AMBOSS.
      public static var alreadySubscribed: String { return L10n.tr("Localizable", "redeem_code.error.alreadySubscribed") }
      /// The access code you entered is not valid.
      public static var keyNotValid: String { return L10n.tr("Localizable", "redeem_code.error.keyNotValid") }
      /// Something went wrong. Please check the access code and re-enter it.
      public static var unknown: String { return L10n.tr("Localizable", "redeem_code.error.unknown") }
    }
    public enum SupportButton {
      /// NEED SUPPORT? CONTACT US
      public static var title: String { return L10n.tr("Localizable", "redeem_code.support_button.title") }
    }
    public enum TextField {
      /// Enter access code
      public static var placeholder: String { return L10n.tr("Localizable", "redeem_code.text_field.placeholder") }
    }
  }

  public enum ReferencesCalloutGroup {
    /// References
    public static var title: String { return L10n.tr("Localizable", "references_callout_group.title") }
  }

  public enum Search {
    /// Search in AMBOSS
    public static var placeholder: String { return L10n.tr("Localizable", "search.placeholder") }
    /// Search for '%@'
    public static func searchForTextAsIs(_ p1: Any) -> String {
      return L10n.tr("Localizable", "search.search_for_text_as_is", String(describing: p1))
    }
    public enum Didyoumean {
      /// Search instead exactly for
      public static var subtitle: String { return L10n.tr("Localizable", "search.didyoumean.subtitle") }
      /// Search results for
      public static var title: String { return L10n.tr("Localizable", "search.didyoumean.title") }
    }
    public enum HistorySection {
      /// History
      public static var title: String { return L10n.tr("Localizable", "search.history_section.title") }
    }
    public enum Media {
      public enum MediaTypes {
        /// CHALK TALK
        public static var auditor: String { return L10n.tr("Localizable", "search.media.media_types.auditor") }
        /// CALCULATOR
        public static var calculator: String { return L10n.tr("Localizable", "search.media.media_types.calculator") }
        /// EASY RADIOLOGY
        public static var easyRadiology: String { return L10n.tr("Localizable", "search.media.media_types.easy_radiology") }
        /// IMAGE
        public static var image: String { return L10n.tr("Localizable", "search.media.media_types.image") }
        /// MEDITRICKS
        public static var meditricks: String { return L10n.tr("Localizable", "search.media.media_types.meditricks") }
        /// 3D MODEL
        public static var model3d: String { return L10n.tr("Localizable", "search.media.media_types.model_3d") }
        /// PATIENT INFO
        public static var patienteninfo: String { return L10n.tr("Localizable", "search.media.media_types.patienteninfo") }
        /// PODCAST
        public static var podcast: String { return L10n.tr("Localizable", "search.media.media_types.podcast") }
        /// SMART ZOOM
        public static var smartZoom: String { return L10n.tr("Localizable", "search.media.media_types.smart_zoom") }
        /// VIDEO
        public static var video: String { return L10n.tr("Localizable", "search.media.media_types.video") }
      }
    }
    public enum OnlineSearchFailure {
      /// You are offline - Limited search results
      public static var firstMessage: String { return L10n.tr("Localizable", "search.online_search_failure.first_message") }
      /// Reload page?
      public static var secondMessage: String { return L10n.tr("Localizable", "search.online_search_failure.second_message") }
    }
    public enum OverviewHeader {
      public enum Title {
        /// All
        public static var all: String { return L10n.tr("Localizable", "search.overview_header.title.all") }
      }
    }
    public enum Pharma {
      public enum Offline {
        public enum Confirmation {
          public enum Alert {
            public enum Action {
              /// OK
              public static var ok: String { return L10n.tr("Localizable", "search.pharma.offline.confirmation.alert.action.ok") }
            }
          }
        }
        public enum ConfirmationError {
          public enum Alert {
            public enum Action {
              /// OK
              public static var ok: String { return L10n.tr("Localizable", "search.pharma.offline.confirmationError.alert.action.ok") }
            }
          }
        }
        public enum Optin {
          public enum Alert {
            /// \rFor better access download the approximately 80 MB large pharma database to your device. This way drugs can be searched event without internet access.\r\rThe database can always be deleted via settings.
            public static var description: String { return L10n.tr("Localizable", "search.pharma.offline.optin.alert.description") }
            /// Drug data\raccessible offline
            public static var title: String { return L10n.tr("Localizable", "search.pharma.offline.optin.alert.title") }
            public enum Action {
              /// Don't ask again
              public static var dontaskagain: String { return L10n.tr("Localizable", "search.pharma.offline.optin.alert.action.dontaskagain") }
              /// Download drug database
              public static var download: String { return L10n.tr("Localizable", "search.pharma.offline.optin.alert.action.download") }
              /// Not now
              public static var notnow: String { return L10n.tr("Localizable", "search.pharma.offline.optin.alert.action.notnow") }
            }
          }
          public enum Confirmation {
            public enum Alert {
              /// More information subject to the download in the settings.
              public static var description: String { return L10n.tr("Localizable", "search.pharma.offline.optin.confirmation.alert.description") }
              /// Drug database is being downloaded
              public static var title: String { return L10n.tr("Localizable", "search.pharma.offline.optin.confirmation.alert.title") }
            }
          }
          public enum ConfirmationError {
            public enum Alert {
              /// Drug database could not be downloaded.
              public static var title: String { return L10n.tr("Localizable", "search.pharma.offline.optin.confirmationError.alert.title") }
            }
          }
        }
      }
    }
    public enum SearchNoResults {
      public enum Section {
        /// No search results for '%@'
        public static func title(_ p1: Any) -> String {
          return L10n.tr("Localizable", "search.search_no_results.section.title", String(describing: p1))
        }
      }
    }
    public enum SearchScope {
      public enum Guideline {
        /// Guidelines
        public static var title: String { return L10n.tr("Localizable", "search.search_scope.guideline.title") }
      }
      public enum Library {
        /// Articles
        public static var title: String { return L10n.tr("Localizable", "search.search_scope.library.title") }
      }
      public enum Media {
        /// Media
        public static var title: String { return L10n.tr("Localizable", "search.search_scope.media.title") }
      }
      public enum Overview {
        /// Overview
        public static var title: String { return L10n.tr("Localizable", "search.search_scope.overview.title") }
        public enum NoResultsView {
          /// Is something missing?
          /// Let us know what important content to add.
          public static var subtitle: String { return L10n.tr("Localizable", "search.search_scope.overview.no_results_view.subtitle") }
          /// No Results Found.
          /// Please try again.
          public static var title: String { return L10n.tr("Localizable", "search.search_scope.overview.no_results_view.title") }
          public enum Button {
            /// WRITE TO US
            public static var title: String { return L10n.tr("Localizable", "search.search_scope.overview.no_results_view.button.title") }
          }
        }
        public enum ViewMore {
          /// VIEW MORE
          public static var title: String { return L10n.tr("Localizable", "search.search_scope.overview.view_more.title") }
        }
      }
      public enum Pharma {
        /// Drugs
        public static var title: String { return L10n.tr("Localizable", "search.search_scope.pharma.title") }
        public enum Beta {
          /// The Drug-Search is in testing phase!
          public static var text: String { return L10n.tr("Localizable", "search.search_scope.pharma.beta.text") }
        }
      }
    }
    public enum SuggestionSection {
      /// Suggestions
      public static var title: String { return L10n.tr("Localizable", "search.suggestion_section.title") }
    }
    public enum Suggestions {
      public enum Section {
        public enum Title {
          /// Search for
          public static var autocomplete: String { return L10n.tr("Localizable", "search.suggestions.section.title.autocomplete") }
          /// Go to
          public static var instantResults: String { return L10n.tr("Localizable", "search.suggestions.section.title.instantResults") }
        }
      }
    }
  }

  public enum Settings {
    /// Settings
    public static var title: String { return L10n.tr("Localizable", "settings.title") }
    public enum AppSettingsSection {
      /// App settings
      public static var title: String { return L10n.tr("Localizable", "settings.app_settings_section.title") }
    }
    public enum More {
      /// More
      public static var title: String { return L10n.tr("Localizable", "settings.more.title") }
      public enum About {
        /// About
        public static var title: String { return L10n.tr("Localizable", "settings.more.about.title") }
      }
      public enum Qbank {
        /// Try the AMBOSS Qbank app!
        public static var title: String { return L10n.tr("Localizable", "settings.more.qbank.title") }
      }
      public enum Terms {
        /// Terms of service
        public static var title: String { return L10n.tr("Localizable", "settings.more.terms.title") }
      }
    }
    public enum Support {
      /// Support
      public static var title: String { return L10n.tr("Localizable", "settings.support.title") }
      public enum HelpCenter {
        /// Help Center
        public static var title: String { return L10n.tr("Localizable", "settings.support.helpCenter.title") }
      }
    }
    public enum Update {
      public enum LibraryAndPharma {
        /// Library and Pharma
        public static var title: String { return L10n.tr("Localizable", "settings.update.libraryAndPharma.title") }
      }
    }
  }

  public enum SettingsFooter {
    public enum Version {
      /// Version: %@ (%@)
      public static func format(_ p1: Any, _ p2: Any) -> String {
        return L10n.tr("Localizable", "settings_footer.version.format", String(describing: p1), String(describing: p2))
      }
    }
  }

  public enum ShareLearningCard {
    /// Hey there,
    /// 
    /// I found some helpful information about %@ over at AMBOSS, a medical knowledge app and clinical companion. You can check it out here: %@ 
    /// 
    /// All the best,
    /// 
    ///  %@
    public static func message(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
      return L10n.tr("Localizable", "share_learning_card.message", String(describing: p1), String(describing: p2), String(describing: p3))
    }
    /// %@ shared medical knowledge from AMBOSS with you
    public static func title(_ p1: Any) -> String {
      return L10n.tr("Localizable", "share_learning_card.title", String(describing: p1))
    }
  }

  public enum Shortcuts {
    public enum Search {
      /// Search AMBOSS
      public static var suggestedInvocationPhrase: String { return L10n.tr("Localizable", "shortcuts.search.suggestedInvocationPhrase") }
      public enum AddToSiriAlert {
        /// Add to Siri
        public static var addToSiriButtonTitle: String { return L10n.tr("Localizable", "shortcuts.search.addToSiriAlert.addToSiriButtonTitle") }
        /// Quickly access AMBOSS Search using a custom voice shortcut like "%@"
        public static func body(_ p1: Any) -> String {
          return L10n.tr("Localizable", "shortcuts.search.addToSiriAlert.body", String(describing: p1))
        }
        /// Not now
        public static var no: String { return L10n.tr("Localizable", "shortcuts.search.addToSiriAlert.no") }
        /// Add "Search AMBOSS" to Siri
        public static var title: String { return L10n.tr("Localizable", "shortcuts.search.addToSiriAlert.title") }
      }
      public enum Notification {
        /// Find answers to all your clinical questions
        public static var body: String { return L10n.tr("Localizable", "shortcuts.search.notification.body") }
        /// Search AMBOSS
        public static var title: String { return L10n.tr("Localizable", "shortcuts.search.notification.title") }
      }
    }
  }

  public enum SignUp {
    /// Already registered? Login here
    public static var labelAlreadyRegisteredText: String { return L10n.tr("Localizable", "sign_up.label_already_registered_text") }
    /// Create your account
    public static var labelCreateYourAccountText: String { return L10n.tr("Localizable", "sign_up.label_create_your_account_text") }
    /// Email already exists. Please login.
    public static var labelEmailInformationText: String { return L10n.tr("Localizable", "sign_up.label_email_information_text") }
    /// Please enter a valid email address.
    public static var labelInvalidEmailAdressText: String { return L10n.tr("Localizable", "sign_up.label_invalid_email_adress_text") }
    /// Password must contain at least 8 characters.
    public static var labelPasswordInformationText: String { return L10n.tr("Localizable", "sign_up.label_password_information_text") }
    /// Start AMBOSS 5 day free trial
    public static var startButtonTitle: String { return L10n.tr("Localizable", "sign_up.start_button_title") }
    /// Create AMBOSS account
    public static var startButtonTitleVariant: String { return L10n.tr("Localizable", "sign_up.start_button_title_variant") }
    /// Email adress
    public static var textFieldEmailPlaceholder: String { return L10n.tr("Localizable", "sign_up.text_field_email_placeholder") }
    /// Password
    public static var textFieldPasswordPlaceholder: String { return L10n.tr("Localizable", "sign_up.text_field_password_placeholder") }
    /// Sign up
    public static var title: String { return L10n.tr("Localizable", "sign_up.title") }
  }

  public enum Signup {
    public enum Verification {
      /// Click the link in your email to verify your account. Didn't receive one? Reach out at at hello@amboss.com.
      public static var sucesss: String { return L10n.tr("Localizable", "signup.verification.sucesss") }
      public enum Sucesss {
        /// Activate your account
        public static var title: String { return L10n.tr("Localizable", "signup.verification.sucesss.title") }
      }
    }
  }

  public enum StudyObjective {
    /// Select your current objective
    public static var header: String { return L10n.tr("Localizable", "study_objective.header") }
    /// Gives you detailed statistics and peer group comparisons for your current objective in the Qbank app and web platform. You can always change this after you take your exam or are finished studying.
    public static var info: String { return L10n.tr("Localizable", "study_objective.info") }
    /// Current objective
    public static var title: String { return L10n.tr("Localizable", "study_objective.title") }
  }

  public enum Substance {
    /// WirkstoffGRUPPE
    public static var activeIngredientGroupLabel: String { return L10n.tr("Localizable", "substance.activeIngredientGroupLabel") }
    /// Wirkstoff
    public static var activeIngredientLabel: String { return L10n.tr("Localizable", "substance.activeIngredientLabel") }
    /// Application Forms
    public static var applicationFormsLabel: String { return L10n.tr("Localizable", "substance.applicationFormsLabel") }
    /// DARREICHUNGSFORM
    public static var dosageFormsLabel: String { return L10n.tr("Localizable", "substance.dosageFormsLabel") }
    /// FURTHER INFORMATION
    public static var furtherInformationLabel: String { return L10n.tr("Localizable", "substance.further_information_label") }
    /// Information on “%@” from ifap GmbH
    public static func ifapInformationNote(_ p1: Any) -> String {
      return L10n.tr("Localizable", "substance.iFAPInformationNote", String(describing: p1))
    }
    /// Letztes Update: %@
    public static func lastUpdateLabel(_ p1: Any) -> String {
      return L10n.tr("Localizable", "substance.lastUpdateLabel.", String(describing: p1))
    }
    /// n/v
    public static var notAvailableLabel: String { return L10n.tr("Localizable", "substance.notAvailableLabel") }
    /// Preis
    public static var packagePriceTitle: String { return L10n.tr("Localizable", "substance.packagePriceTitle") }
    /// Packungsgrösse
    public static var packageSizeTitle: String { return L10n.tr("Localizable", "substance.packageSizeTitle") }
    /// Beipackzettel
    public static var patientPackageLabel: String { return L10n.tr("Localizable", "substance.patientPackageLabel") }
    /// Germany
    public static var patientPackageSubtitleLabel: String { return L10n.tr("Localizable", "substance.patientPackageSubtitleLabel") }
    /// Fachinformationen
    public static var prescribingInformationLabel: String { return L10n.tr("Localizable", "substance.prescribingInformationLabel") }
    /// Fachinformationen
    public static var prescribingInformationSectionLabel: String { return L10n.tr("Localizable", "substance.prescribingInformationSectionLabel") }
    /// Germany
    public static var prescribingInformationSubtitleLabel: String { return L10n.tr("Localizable", "substance.prescribingInformationSubtitleLabel") }
    /// Oder
    public static var prescriptionSeparator: String { return L10n.tr("Localizable", "substance.prescription_separator") }
    /// VERSCHREIBUNGSPFLICHT
    public static var prescriptionsLabel: String { return L10n.tr("Localizable", "substance.prescriptionsLabel") }
    public enum ApplicationForms {
      public enum All {
        /// All
        public static var title: String { return L10n.tr("Localizable", "substance.application_forms.all.title") }
      }
      public enum Bronchial {
        /// Bronchial
        public static var title: String { return L10n.tr("Localizable", "substance.application_forms.bronchial.title") }
      }
      public enum Enteral {
        /// Enteral
        public static var title: String { return L10n.tr("Localizable", "substance.application_forms.enteral.title") }
      }
      public enum Inhalation {
        /// Inhalation
        public static var title: String { return L10n.tr("Localizable", "substance.application_forms.inhalation.title") }
      }
      public enum NasalSpray {
        /// Nasal Spray
        public static var title: String { return L10n.tr("Localizable", "substance.application_forms.nasal_spray.title") }
      }
      public enum Ophthalmic {
        /// Ophthalmic
        public static var title: String { return L10n.tr("Localizable", "substance.application_forms.ophthalmic.title") }
      }
      public enum Other {
        /// Other
        public static var title: String { return L10n.tr("Localizable", "substance.application_forms.other.title") }
      }
      public enum Parenteral {
        /// Parenteral
        public static var title: String { return L10n.tr("Localizable", "substance.application_forms.parenteral.title") }
      }
      public enum Rectal {
        /// Rectal
        public static var title: String { return L10n.tr("Localizable", "substance.application_forms.rectal.title") }
      }
      public enum Topical {
        /// Topical
        public static var title: String { return L10n.tr("Localizable", "substance.application_forms.topical.title") }
      }
      public enum Urogenital {
        /// Urogenital
        public static var title: String { return L10n.tr("Localizable", "substance.application_forms.urogenital.title") }
      }
    }
    public enum CommercialDrugsButton {
      /// Andere Handelspräparate finden
      public static var title: String { return L10n.tr("Localizable", "substance.commercialDrugsButton.title") }
    }
    public enum FeedbackButton {
      /// FEEDBACK
      public static var title: String { return L10n.tr("Localizable", "substance.feedbackButton.title") }
    }
    public enum NetworkError {
      /// Cancel
      public static var cancel: String { return L10n.tr("Localizable", "substance.network_error.cancel") }
      /// Retry
      public static var retry: String { return L10n.tr("Localizable", "substance.network_error.retry") }
    }
    public enum PrescribingInformationButton {
      /// PDF
      public static var title: String { return L10n.tr("Localizable", "substance.prescribingInformationButton.title") }
    }
    public enum Prescription {
      /// Betäubungsmittel
      public static var narcotic: String { return L10n.tr("Localizable", "substance.prescription.narcotic") }
      /// Freiverkäuflich
      public static var overTheCounter: String { return L10n.tr("Localizable", "substance.prescription.over_the_counter") }
      /// Apothekenpflichtig
      public static var pharmacyOnly: String { return L10n.tr("Localizable", "substance.prescription.pharmacy_only") }
      /// Rezeptpflichtig
      public static var prescriptionOnly: String { return L10n.tr("Localizable", "substance.prescription.prescription_only") }
    }
    public enum ShowAllButton {
      /// Alle anzeigen
      public static var title: String { return L10n.tr("Localizable", "substance.showAllButton.title") }
    }
    public enum TabTitle {
      /// Faktenblatt
      public static var factSheet: String { return L10n.tr("Localizable", "substance.tab_title.fact_sheet") }
      /// Handelspräparate (ifap)
      public static var ifap: String { return L10n.tr("Localizable", "substance.tab_title.ifap") }
    }
  }

  public enum Support {
    /// Support
    public static var title: String { return L10n.tr("Localizable", "support.title") }
  }

  public enum Terms {
    public enum AcceptButton {
      /// Understood
      public static var title: String { return L10n.tr("Localizable", "terms.accept_button.title") }
    }
  }

  public enum UsagePurpose {
    /// Clinical practice
    public static var clinicalPractice: String { return L10n.tr("Localizable", "usage_purpose.clinical_practice") }
    /// Preparing for a medical exam
    public static var examPreparation: String { return L10n.tr("Localizable", "usage_purpose.exam_preparation") }
    /// AMBOSS mode
    public static var title: String { return L10n.tr("Localizable", "usage_purpose.title") }
  }

  public enum UserStage {
    /// I accept the Liability Notice, Legal Notice, Terms and Conditions and Privacy Policy. I acknowledge that all information in AMBOSS refers to the medical standard in the US and that diagnostic and/or therapeutic procedures as well as the regulatory status of named commercial products may differ in other countries.
    public static var footerAgreementClinician: String { return L10n.tr("Localizable", "user_stage.footer_agreement_clinician") }
    /// Legal Notice
    public static var footerAgreementLegalNoticeText: String { return L10n.tr("Localizable", "user_stage.footer_agreement_legal_notice_text") }
    /// Liability Notice
    public static var footerAgreementLiabilityNoticeText: String { return L10n.tr("Localizable", "user_stage.footer_agreement_liability_notice_text") }
    /// I accept the Legal Notice, Terms and Conditions and Privacy Policy. I acknowledge that all information in AMBOSS refers to the medical standard in the US and that diagnostic and/or therapeutic procedures as well as the regulatory status of named commercial products may differ in other countries.
    public static var footerAgreementNonClinician: String { return L10n.tr("Localizable", "user_stage.footer_agreement_non_clinician") }
    /// Privacy Policy
    public static var footerAgreementPrivacyPolicyText: String { return L10n.tr("Localizable", "user_stage.footer_agreement_privacy_policy_text") }
    /// Terms and Conditions
    public static var footerAgreementTermsAndConditionsText: String { return L10n.tr("Localizable", "user_stage.footer_agreement_terms_and_conditions_text") }
    /// Select your mode
    public static var header: String { return L10n.tr("Localizable", "user_stage.header") }
    /// AMBOSS mode
    public static var title: String { return L10n.tr("Localizable", "user_stage.title") }
    public enum Savenotification {
      /// Amboss mode saved
      public static var title: String { return L10n.tr("Localizable", "user_stage.savenotification.title") }
    }
    public enum UserStageClinic {
      /// Search results prominently feature relevant educational topics. Articles focus on must-know information for exams and general studies.
      public static var description: String { return L10n.tr("Localizable", "user_stage.user_stage_clinic.description") }
      /// Student
      public static var title: String { return L10n.tr("Localizable", "user_stage.user_stage_clinic.title") }
    }
    public enum UserStagePhysician {
      /// Search results prominently feature clinically relevant material. Articles include drug dosages, diagnostic and treatment algorithms, and admission checklists.
      public static var description: String { return L10n.tr("Localizable", "user_stage.user_stage_physician.description") }
      /// Clinician
      public static var title: String { return L10n.tr("Localizable", "user_stage.user_stage_physician.title") }
    }
    public enum UserStagePreclinic {
      /// Preclinical
      public static var description: String { return L10n.tr("Localizable", "user_stage.user_stage_preclinic.description") }
      /// Preclinical
      public static var title: String { return L10n.tr("Localizable", "user_stage.user_stage_preclinic.title") }
    }
    public enum UserStagePreclinicShort {
      /// Preclinical
      public static var title: String { return L10n.tr("Localizable", "user_stage.user_stage_preclinic_short.title") }
    }
  }

  public enum Welcome {
    /// By creating an account, you agree to the terms and conditions. For more information see our privacy policy.
    public static var legalMessage: String { return L10n.tr("Localizable", "welcome.legal_message") }
    /// Privacy policy
    public static var legalMessagePrivacyLinkText: String { return L10n.tr("Localizable", "welcome.legal_message_privacy_link_text") }
    /// Terms and conditions
    public static var legalMessageTOSLinkText: String { return L10n.tr("Localizable", "welcome.legal_message_t_o_s_link_text") }
    /// Already have an account?
    public static var loginLabel: String { return L10n.tr("Localizable", "welcome.loginLabel") }
    /// Sign up
    public static var signUpButtonTitle: String { return L10n.tr("Localizable", "welcome.signUpButtonTitle") }
    ///  
    public static var subtitle: String { return L10n.tr("Localizable", "welcome.subtitle") }
    /// Medical knowledge for on the go.
    public static var title: String { return L10n.tr("Localizable", "welcome.title") }
    public enum AccountWasDeletedAlert {
      /// The deletion affected all accounts of our platform. Please be aware that you need to unsubscribe separately through the AppStore.
      public static var message: String { return L10n.tr("Localizable", "welcome.accountWasDeletedAlert.message") }
      /// You were logged out based on your account deletion
      public static var title: String { return L10n.tr("Localizable", "welcome.accountWasDeletedAlert.title") }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = Localization.lookupTranslation(forKey:inTable:)(key, table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

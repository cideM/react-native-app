// Generated using Sourcery 2.0.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable
import Foundation
import FixtureFactory
@testable import Domain
@testable import PharmaDatabase

extension PharmaDatabase.Row.AmbossSubstance: Fixture {
    public static func fixture() -> PharmaDatabase.Row.AmbossSubstance {
        fixture(id: .fixture(), name: .fixture(), based_on_drug_id: .fixture(), prescriptions: .fixture(), dosage_forms: .fixture(), published_at_ts: .fixture(), search_terms: .fixture(), suggest_terms: .fixture(), published: .fixture())
    }
    public static func fixture(id: String = .fixture(), name: String? = .fixture(), based_on_drug_id: String? = .fixture(), prescriptions: String? = .fixture(), dosage_forms: String? = .fixture(), published_at_ts: Int64? = .fixture(), search_terms: String? = .fixture(), suggest_terms: String? = .fixture(), published: Bool = .fixture()) -> PharmaDatabase.Row.AmbossSubstance {
        PharmaDatabase.Row.AmbossSubstance(id: id, name: name, based_on_drug_id: based_on_drug_id, prescriptions: prescriptions, dosage_forms: dosage_forms, published_at_ts: published_at_ts, search_terms: search_terms, suggest_terms: suggest_terms, published: published)
    }
}

extension PharmaDatabase.Row.Dosage: Fixture {
    public static func fixture() -> PharmaDatabase.Row.Dosage {
        fixture(id: .fixture(), html: .fixture(), as_link_as_id: .fixture(), as_link_drug_id: .fixture())
    }
    public static func fixture(id: String = .fixture(), html: String = .fixture(), as_link_as_id: String? = .fixture(), as_link_drug_id: String? = .fixture()) -> PharmaDatabase.Row.Dosage {
        PharmaDatabase.Row.Dosage(id: id, html: html, as_link_as_id: as_link_as_id, as_link_drug_id: as_link_drug_id)
    }
}

extension PharmaDatabase.Row.Drug: Fixture {
    public static func fixture() -> PharmaDatabase.Row.Drug {
        fixture(id: .fixture(), name: .fixture(), atc_label: .fixture(), amboss_substance_id: .fixture(), vendor: .fixture(), application_forms: .fixture(), prescriptions: .fixture(), dosage_forms: .fixture(), published_at_ts: .fixture(), prescribing_information_url: .fixture(), patient_package_insert_url: .fixture())
    }
    public static func fixture(id: String = .fixture(), name: String? = .fixture(), atc_label: String? = .fixture(), amboss_substance_id: String? = .fixture(), vendor: String? = .fixture(), application_forms: String? = .fixture(), prescriptions: String? = .fixture(), dosage_forms: String? = .fixture(), published_at_ts: Int64? = .fixture(), prescribing_information_url: String? = .fixture(), patient_package_insert_url: String? = .fixture()) -> PharmaDatabase.Row.Drug {
        PharmaDatabase.Row.Drug(id: id, name: name, atc_label: atc_label, amboss_substance_id: amboss_substance_id, vendor: vendor, application_forms: application_forms, prescriptions: prescriptions, dosage_forms: dosage_forms, published_at_ts: published_at_ts, prescribing_information_url: prescribing_information_url, patient_package_insert_url: patient_package_insert_url)
    }
}

extension PharmaDatabase.Row.DrugSection: Fixture {
    public static func fixture() -> PharmaDatabase.Row.DrugSection {
        fixture(drug_id: .fixture(), section_id: .fixture(), position: .fixture())
    }
    public static func fixture(drug_id: String? = .fixture(), section_id: String? = .fixture(), position: Int? = .fixture()) -> PharmaDatabase.Row.DrugSection {
        PharmaDatabase.Row.DrugSection(drug_id: drug_id, section_id: section_id, position: position)
    }
}

extension PharmaDatabase.Row.Package: Fixture {
    public static func fixture() -> PharmaDatabase.Row.Package {
        fixture(id: .fixture(), drug_id: .fixture(), position_ascending: .fixture(), position_mixed: .fixture(), package_size: .fixture(), amount: .fixture(), unit: .fixture(), pharmacy_price: .fixture(), recommended_price: .fixture(), prescription: .fixture())
    }
    public static func fixture(id: Int = .fixture(), drug_id: String? = .fixture(), position_ascending: Int? = .fixture(), position_mixed: Int? = .fixture(), package_size: String? = .fixture(), amount: String? = .fixture(), unit: String? = .fixture(), pharmacy_price: String? = .fixture(), recommended_price: String? = .fixture(), prescription: String? = .fixture()) -> PharmaDatabase.Row.Package {
        PharmaDatabase.Row.Package(id: id, drug_id: drug_id, position_ascending: position_ascending, position_mixed: position_mixed, package_size: package_size, amount: amount, unit: unit, pharmacy_price: pharmacy_price, recommended_price: recommended_price, prescription: prescription)
    }
}

extension PharmaDatabase.Row.PocketCard: Fixture {
    public static func fixture() -> PharmaDatabase.Row.PocketCard {
        fixture(id: .fixture(), amboss_substance_id: .fixture())
    }
    public static func fixture(id: String = .fixture(), amboss_substance_id: String = .fixture()) -> PharmaDatabase.Row.PocketCard {
        PharmaDatabase.Row.PocketCard(id: id, amboss_substance_id: amboss_substance_id)
    }
}

extension PharmaDatabase.Row.PocketCardGroup: Fixture {
    public static func fixture() -> PharmaDatabase.Row.PocketCardGroup {
        fixture(id: .fixture(), pocket_card_id: .fixture(), position: .fixture(), title: .fixture())
    }
    public static func fixture(id: String = .fixture(), pocket_card_id: String = .fixture(), position: Int? = .fixture(), title: String = .fixture()) -> PharmaDatabase.Row.PocketCardGroup {
        PharmaDatabase.Row.PocketCardGroup(id: id, pocket_card_id: pocket_card_id, position: position, title: title)
    }
}

extension PharmaDatabase.Row.PocketCardSection: Fixture {
    public static func fixture() -> PharmaDatabase.Row.PocketCardSection {
        fixture(id: .fixture(), pocket_card_group_id: .fixture(), position: .fixture(), title: .fixture(), content: .fixture())
    }
    public static func fixture(id: String = .fixture(), pocket_card_group_id: String = .fixture(), position: Int? = .fixture(), title: String = .fixture(), content: String = .fixture()) -> PharmaDatabase.Row.PocketCardSection {
        PharmaDatabase.Row.PocketCardSection(id: id, pocket_card_group_id: pocket_card_group_id, position: position, title: title, content: content)
    }
}

extension PharmaDatabase.Row.Section: Fixture {
    public static func fixture() -> PharmaDatabase.Row.Section {
        fixture(id: .fixture(), title: .fixture(), content: .fixture())
    }
    public static func fixture(id: Int = .fixture(), title: String? = .fixture(), content: Data? = .fixture()) -> PharmaDatabase.Row.Section {
        PharmaDatabase.Row.Section(id: id, title: title, content: content)
    }
}

extension PharmaDatabase.Row.Version: Fixture {
    public static func fixture() -> PharmaDatabase.Row.Version {
        fixture(id: .fixture(), major: .fixture(), minor: .fixture(), patch: .fixture())
    }
    public static func fixture(id: Int = .fixture(), major: Int = .fixture(), minor: Int = .fixture(), patch: Int = .fixture()) -> PharmaDatabase.Row.Version {
        PharmaDatabase.Row.Version(id: id, major: major, minor: minor, patch: patch)
    }
}


// MARK: - Enums

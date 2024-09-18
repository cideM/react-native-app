//
//  PharmaDatabase.swift
//  PharmaDatabase
//
//  Created by Roberto Seidenberg on 31.03.21.
//

import Foundation
import GRDB

public struct PharmaDatabase {

    /// Means: Use any version that is:
    /// * Exactly this version
    /// But:
    /// * Do not use any version lower or higher
    public static let supportedMajorSchemaVersion = 10

    /// Means: Use any version that is:
    /// * Exactly this version
    /// * Higher than this version
    /// But:
    /// * Do not use any version that is below this version
    ///
    /// We first started altering db adapter logic for minor version changes with v5.2
    /// Notable changes between minor versions:
    ///
    /// __v5.2:__
    /// * Adds the column "atc_label" to the "drug" table
    /// * This is replacing column "group_name" in the "agent" table and is henceforth used by the database adapter
    /// * For the time being "group_name" is still present but (starting with the requirement of x.2) not used any more
    ///
    /// __v5.3:__
    /// * Introduces the "dosage" table which is used by the db adapter to return offline dosage info
    /// 
    /// __v6.0:__
    /// * Removes column "text" from table "dosage"
    /// * Adds column "html" to table "dosage"
    ///
    /// __v7.0:__
    /// * Renames table "agent" to "amboss_substance"
    /// * Renames column "agent_id" to "amboss_substance_id" in table "drug"
    /// * Removes column "group_name" from table "amboss_substance"
    /// * Removes column "agent_id" from table "dosage"
    /// * Adds columns "as_link_as_id" and "as_link_drug_id' to table "dosage"
    /// 
    /// __v8.0:__
    /// * Adds column "published" to the "amboss_substance" table (only published items should be shown in search resutls)
    /// (This requires a major version update cause it might happen that an app update is installed before a db update.
    /// This will result in the app expecting the column to be available, the db, still on v7 will not provide it though)
    ///
    /// __v8.0:__ (internal change only)
    /// * https://miamed.atlassian.net/browse/PHEX-1675 removes "Rote Hand" and "Embryotox" Hence this needs not to
    /// be parsed any more. Means the "embryotox" in the "amboss_substance" table is ignored starting with app version
    /// 2.14.0. This is still the same major and minor schema version though!
    ///
    /// __v8.1:__ (an app using this db version was never released, we went straight to v10)
    /// * Adds table "pocket_card"
    /// 
    /// __v9.0:__ (an app using this db version was never released, we went straight to v10)
    /// * Removes column "embryotox" from table "amboss_substance" (not parsed since previous app version, see above)
    ///
    /// __v10.0:__
    /// * Changes the type of the row "id" in table "dosage" from INT to TEXT
    public static let supportedMinorSchemaVersion = 0 // -> also see testFailureUnsupportedMinorVersion()

    /// Backend documentation about version changes can be found here:
    /// https://github.com/amboss-mededu/go-pharma/blob/master/cmd/offline/CHANGELOG.md

    let queue: DatabaseReader

    public init(url: URL) throws {
        var configuration = Configuration()
        configuration.readonly = true
        let queue = try DatabaseQueue(path: url.path, configuration: configuration)
        try self.init(queue: queue)
    }

    // This is required for (memory only) db injection during testing
    init(queue: DatabaseReader) throws {
        self.queue = queue
        try validateDatabaseSchema()
    }

    private func validateDatabaseSchema() throws {
        // Doing this first to avoid crash for malformed version table ...
        try queue.read { database in
            try PharmaDatabase.Row.Version.validate(in: database)
        }

        // Will only continue valdating remaining rows if sufficient version ...
        let version = try self.version()
        if version.major != Self.supportedMajorSchemaVersion {
            throw SchemaValidationError.schemaMajorVersionMismatch(version: version, required: Self.supportedMajorSchemaVersion)
        } else if version.minor < Self.supportedMinorSchemaVersion {
            throw SchemaValidationError.schemaMinorVersionMismatch(version: version, required: Self.supportedMinorSchemaVersion)
        }

        // Version ok, lets see if the table columns are as expected ...
        try queue.read { database in
            try PharmaDatabase.Row.AmbossSubstance.validate(in: database)
            try PharmaDatabase.Row.Section.validate(in: database)
            try PharmaDatabase.Row.Drug.validate(in: database)
            try PharmaDatabase.Row.DrugSection.validate(in: database)
            try PharmaDatabase.Row.Package.validate(in: database)
            try PharmaDatabase.Row.PocketCard.validate(in: database)
            try PharmaDatabase.Row.PocketCardGroup.validate(in: database)
            try PharmaDatabase.Row.PocketCardSection.validate(in: database)
            try PharmaDatabase.Row.Dosage.validate(in: database)
        }
    }
}

//
//  Localization.swift
//  Localization
//
//  Created by Manaf Alabd Alrahim on 09.06.23.
//

public final class Localization {

    internal static var shared = Localization(config: Localization.Configuration())

    let config: Localization.Configuration
    let bundle: Bundle

    init(config: Localization.Configuration) {
        self.config = config
        self.bundle = Bundle(for: Localization.self)
    }

    public static func configure(config: Localization.Configuration) {
        shared = Localization(config: config)
    }

    /// Used in SwiftGen's `lookupFunctions` in order to have a dynamic localization lookup with only one `Localizable.strings` file
    /// More info here: https://github.com/SwiftGen/SwiftGen/blob/6.3.0/Documentation/Articles/Customize-loading-of-resources.md#override-the-lookup-functionhttps://github.com/SwiftGen/SwiftGen/blob/6.3.0/Documentation/Articles/Customize-loading-of-resources.md#override-the-lookup-function
    static func lookupTranslation(forKey key: String, inTable table: String) -> String {

        let languageCode: String = Localization.shared.config.languageCode

        guard let path = shared.bundle.path(forResource: languageCode, ofType: "lproj"),
              let bundle = Bundle(path: path)
        else { fatalError("Can't find a bundle for the specified language code.") }

        return bundle.localizedString(forKey: key, value: nil, table: table)
    }
}

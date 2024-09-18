//
//  Localiation+Configuration.swift
//  Localization
//
//  Created by Manaf Alabd Alrahim on 09.06.23.
//

extension Localization {
    public class Configuration {
        let languageCode: String

        public init (languageCode: String = "en") {
            self.languageCode = languageCode
        }
    }
}

//
//  LocalizationUtils.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 20/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Vapor

enum LocalizationUtils {
    static let defaultLocale = Constants.defaultLocale

    static func getCountryName(from translations: [BoothCountryTranslation],
                               locale: String) -> String {
        (translations.first { $0.locale == locale }
            ?? translations.first { $0.locale == defaultLocale })?
            .name ?? "No country name"
    }

    static func getLocale(req: Request) -> String {
        guard let input = try? req.query.decode(LocaleInput.self),
              let locale = input.locale else {
            return defaultLocale
        }

        return locale
    }
}

//
//  BoothCountryTranslationDTO.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 09/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Fluent
import Vapor

struct BoothCountryTranslationInput: Content {
    let locale: String
    let name: String
    let countryID: UUID
}

extension BoothCountryTranslationInput: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("locale",
                        as: String.self,
                        is: Constants.BoothCountryTranslation.Locale.validator)
        validations.add("name",
                        as: String.self,
                        is: Constants.BoothCountryTranslation.Name.validator)
    }
}

extension BoothCountryTranslationInput {
    func toModel() -> BoothCountryTranslation {
        BoothCountryTranslation(locale: locale,
                                name: name,
                                countryID: countryID)
    }
}

struct BoothCountryTranslationOutput: Content {
    let id: UUID
    let locale: String
    let name: String
    let countryID: UUID
}

extension BoothCountryTranslationOutput {
    init(_ translation: BoothCountryTranslation) throws {
        self.id = try translation.requireID()
        self.locale = translation.locale
        self.name = translation.name
        self.countryID = translation.$country.id
    }
}

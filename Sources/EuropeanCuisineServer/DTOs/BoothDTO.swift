//
//  BoothDTO.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 09/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Fluent
import Vapor

struct BoothInput: Content {
    let name: String
    let about: String
    let pictureURL: String
    let location: String
    let isVegan: Bool
    let isPRM: Bool
    let isFamilyFriendly: Bool
    let allergens: Set<Allergen>
    let startTime: Date
    let endTime: Date
    let countryID: UUID
}

extension BoothInput: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name",
                        as: String.self,
                        is: Constants.Booth.Name.validator)
        validations.add("about",
                        as: String.self,
                        is: Constants.Booth.About.validator)
        validations.add("pictureURL",
                        as: String.self,
                        is: Constants.Booth.PictureURL.validator)
        validations.add("location",
                        as: String.self,
                        is: Constants.Booth.Location.validator)
        validations.add("allergens", as: [String].self, is: .allergens)
    }
}

extension BoothInput {
    func toModel(status: Booth.Status) -> Booth {
        Booth(name: name.trimmed,
              about: about.trimmed,
              pictureURL: pictureURL.trimmed,
              location: location.trimmed,
              isVegan: isVegan,
              isPRM: isPRM,
              isFamilyFriendly: isFamilyFriendly,
              allergens: allergens,
              startTime: startTime,
              endTime: endTime,
              status: status,
              countryID: countryID)
    }
}

struct BoothOutput: Content {
    let id: UUID
    let name: String
    let about: String
    let pictureURL: String
    let location: String
    let isVegan: Bool
    let isPRM: Bool
    let isFamilyFriendly: Bool
    let allergens: Set<Allergen>
    let startTime: Date
    let endTime: Date
    let countryCode: String
    let countryName: String
}

extension BoothOutput {
    init(_ booth: Booth, countryName: String = "No country name") throws {
        self.id = try booth.requireID()
        self.name = booth.name
        self.about = booth.about
        self.pictureURL = booth.pictureURL
        self.location = booth.location
        self.isVegan = booth.isVegan
        self.isPRM = booth.isPRM
        self.isFamilyFriendly = booth.isFamilyFriendly
        self.allergens = booth.allergens
        self.startTime = booth.startTime
        self.endTime = booth.endTime
        self.countryCode = booth.country.code
        self.countryName = countryName
    }
}

struct LocaleInput: Content {
    var locale: String?
}

private struct AllergensValidatorResult: ValidatorResult {
    let invalid: [String]
    let hasDuplicates: Bool

    var isFailure: Bool {
        !invalid.isEmpty || hasDuplicates
    }

    var successDescription: String? {
        "contains only valid allergens"
    }

    var failureDescription: String? {
        if !invalid.isEmpty {
            let valid = Allergen.allCases.map(\.rawValue).joined(separator: ", ")
            return "contains invalid allergens: \(invalid.joined(separator: ", ")). Valid values: \(valid)"
        }
        return "contains duplicate allergens"
    }
}

extension Validator where T == [String] {
    static var allergens: Validator<T> {
        .init { values in
            AllergensValidatorResult(invalid: values.filter { Allergen(rawValue: $0) == nil },
                                     hasDuplicates: Set(values).count != values.count)
        }
    }
}

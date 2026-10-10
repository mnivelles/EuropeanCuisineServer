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
    let description: String
    let pictureURL: String
    let location: String
    let isVegan: Bool
    let isPRM: Bool
    let isFamilyFriendly: Bool
    let countryID: UUID
}

extension BoothInput: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: .count(1 ... 100))
        validations.add("description", as: String.self, is: .count(1 ... 1000))
        validations.add("pictureURL",
                        as: String.self,
                        is: .count(1 ... 500) && .url)
        validations.add("location",
                        as: String.self,
                        is: .count(1 ... 100))
    }
}

extension BoothInput {
    func toModel(status: Booth.Status) -> Booth {
        Booth(name: name,
              description: description,
              pictureURL: pictureURL,
              location: location,
              isVegan: isVegan,
              isPRM: isPRM,
              isFamilyFriendly: isFamilyFriendly,
              status: status,
              countryID: countryID)
    }
}

struct BoothOutput: Content {
    let id: UUID
    let name: String
    let description: String
    let pictureURL: String
    let location: String
    let isVegan: Bool
    let isPRM: Bool
    let isFamilyFriendly: Bool
    let countryID: UUID
}

extension BoothOutput {
    init(_ booth: Booth) throws {
        self.id = try booth.requireID()
        self.name = booth.name
        self.description = booth.description
        self.pictureURL = booth.pictureURL
        self.location = booth.location
        self.isVegan = booth.isVegan
        self.isPRM = booth.isPRM
        self.isFamilyFriendly = booth.isFamilyFriendly
        self.countryID = booth.$country.id
    }
}

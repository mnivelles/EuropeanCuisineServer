//
//  BoothCountryDTO.swift
//  EuropeanCuisineServer
//  
//  Created by Mathieu Nivelles on 09/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//  

import Fluent
import Vapor

struct BoothCountryInput: Content {
    let code: String
    let nameEN: String
    let nameFR: String
}

extension BoothCountryInput: Validatable {
    
    static func validations(_ validations: inout Validations) {
        validations.add("code",
                        as: String.self,
                        is: .pattern("^[A-Z]{3}$"))
        validations.add("nameEN",
                        as: String.self,
                        is: .count(1...100))
        validations.add("nameFR",
                        as: String.self,
                        is: .count(1...100))
    }
}

extension BoothCountryInput {
    
    func toModel() -> BoothCountry {
        BoothCountry(code: code,
                     nameEN: nameEN,
                     nameFR: nameFR)
    }
}

struct BoothCountryOutput: Content {
    let id: UUID
    let code: String
    let nameEN: String
    let nameFR: String
}

extension BoothCountryOutput {
    
    init(_ country: BoothCountry) throws {
        self.id = try country.requireID()
        self.code = country.code
        self.nameEN = country.nameEN
        self.nameFR = country.nameFR
    }
}

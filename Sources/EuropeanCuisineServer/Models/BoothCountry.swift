//
//  BoothCountry.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 09/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Fluent
import Vapor

final class BoothCountry: Model, @unchecked Sendable {
    static let schema: String = "booth_countries"

    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "code")
    var code: String

    @Field(key: "name_en")
    var nameEN: String
    
    @Field(key: "name_fr")
    var nameFR: String

    @Children(for: \.$country)
    var booths: [Booth]

    init() {}

    init(id: UUID? = nil,
         code: String,
         nameEN: String,
         nameFR: String) {
        self.id = id
        self.code = code
        self.nameEN = nameEN
        self.nameFR = nameFR
    }
}

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

    @Field(key: "name")
    var name: String

    @Field(key: "code")
    var code: String

    @Children(for: \.$country)
    var booths: [Booth]

    init() {}

    init(id: UUID? = nil, name: String, code: String) {
        self.id = id
        self.name = name
        self.code = code
    }
}

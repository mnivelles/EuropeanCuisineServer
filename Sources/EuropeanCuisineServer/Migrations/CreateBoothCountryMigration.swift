//
//  CreateBoothCountryMigration.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 09/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Fluent
import FluentSQL
import Vapor

struct CreateBoothCountryMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(BoothCountry.schema)
            .id()
            .field("code",
                   .sql(unsafeRaw: "VARCHAR(3)"),
                   .required)
            .field("name_en",
                   .sql(unsafeRaw: "VARCHAR(100)"),
                   .required)
            .field("name_fr",
                   .sql(unsafeRaw: "VARCHAR(100)"),
                   .required)
            .unique(on: "code")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(BoothCountry.schema)
            .delete()
    }
}

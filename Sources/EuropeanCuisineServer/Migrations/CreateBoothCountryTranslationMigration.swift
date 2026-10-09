//
//  CreateBoothCountryTranslationMigration.swift
//  EuropeanCuisineServer
//  
//  Created by Mathieu Nivelles on 09/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//  

import Fluent
import FluentSQL
import Vapor

struct CreateBoothCountryTranslationMigration: AsyncMigration {
    
    func prepare(on database: any Database) async throws {
        try await database.schema(BoothCountryTranslation.schema)
            .id()
            .field("locale",
                   .sql(unsafeRaw: "VARCHAR(2)"),
                .required)
            .field("name",
                   .sql(unsafeRaw: "VARCHAR(100)"),
                .required)
            .field("country_id",
                   .uuid,
                   .required,
                   .references(BoothCountry.schema, "id", onDelete: .cascade))
            .unique(on: "country_id", "locale")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(BoothCountryTranslation.schema)
            .delete()
    }
}

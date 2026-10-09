//
//  CreateBoothMigration.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 09/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Fluent
import FluentSQL
import Vapor

struct CreateBoothMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        var builder = database.enum(Booth.Status.schema)
        for currentStatus in Booth.Status.allCases {
            builder = builder.case(currentStatus.rawValue)
        }
        let status = try await builder.create()

        try await database.schema(Booth.schema)
            .id()
            .field("name",
                   .sql(unsafeRaw: "VARCHAR(100)"),
                   .required)
            .field("description",
                   .sql(unsafeRaw: "TEXT"),
                   .required)
            .field("picture_url",
                   .sql(unsafeRaw: "VARCHAR(500)"),
                   .required)
            .field("location",
                   .sql(unsafeRaw: "VARCHAR(100)"),
                   .required)
            .field("is_vegan", .bool, .required)
            .field("is_prm", .bool, .required)
            .field("is_family_friendly", .bool, .required)
            .field("status", status, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("country_id",
                   .uuid,
                   .required,
                   .references(BoothCountry.schema, "id", onDelete: .noAction))
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Booth.schema)
            .delete()

        try await database.enum(Booth.Status.schema).delete()
    }
}

//
//  CreateWorkshopMigration.swift
//  EuropeanCuisineServer
//
//  Created by Aesmond on 01/10/2026.
//  Copyright © 2026 Aesmond. All rights reserved.
//

import Fluent
import FluentSQL
import Vapor

struct CreateWorkshopMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {

      try await database.schema(Workshop.schema)
            .id()
            .field("name", .sql(unsafeRaw: "VARCHAR(100)"), .required)
            .field("start_time", .datetime, .required)
            .field("end_time", .datetime, .required)
            .field("capacity_max", .uint16, .required)
            .field("description", .sql(unsafeRaw: "TEXT"), .required)
            .field("is_vegan", .bool, .required)
            .field("is_prm", .bool, .required)
            .field("is_family_friendly", .bool, .required)
            .field("category_id",
                   .uuid,
                   .required,
                   .references(Category.schema, "id", onDelete: .noAction))
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("workshops")
            .delete()
    }
}

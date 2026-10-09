//
//  CreateWorkshopInfosMigration.swift
//  EuropeanCuisineServer
//
//  Created by Aesmond on 07/10/2026.
//  Copyright © 2026 Aesmond. All rights reserved.
//

import Fluent
import FluentSQL
import Vapor

struct CreateWorkshopInfosMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        var builder = database.enum(Workshop.Status.schema)
        for currentStatus in Workshop.Status.allCases {
            builder = builder.case(currentStatus.rawValue)
        }
        let status = try await builder.create()

        try await database.schema(WorkshopInfos.schema)
            .id()
            .field("status", status, .required)
            .field("picture_url", .sql(unsafeRaw: "VARCHAR(500)"), .required)
            .field("location", .sql(unsafeRaw: "VARCHAR(100)"), .required)
            .field("is_vegan", .bool, .required)
            .field("is_prm", .bool, .required)
            .field("is_family_friendly", .bool, .required)
            .field("workshop_id",
                   .uuid,
                   .required,
                   .references(Workshop.schema, "id", onDelete: .cascade))
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(WorkshopInfos.schema)
            .delete()

        try await database.enum(Workshop.Status.schema).delete()
    }
}

//
//  CreateUserMigration.swift
//  EuropeanCuisineServer
//
//  Created by Aesmond on 01/10/2026.
//  Copyright © 2026 Aesmond. All rights reserved.
//

import Fluent
import FluentSQL
import Vapor

struct CreateUserMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        var builder = database.enum("user_role")
        for r in User.Role.allCases {
            builder = builder.case(r.rawValue)
        }
        let role = try await builder.create()

      try await database.schema(User.schema)
            .id()
            .field("name", .sql(unsafeRaw: "VARCHAR(100)"), .required)
            .field("email", .sql(unsafeRaw: "VARCHAR(254)"), .required)
            .field("password_hash", .sql(unsafeRaw: "VARCHAR(100)"), .required)
            .field("role", role, .required)
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("users")
            .delete()
        
        try await database.enum("user_role").delete()
    }
}

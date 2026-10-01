//
//  CreateUserMigration.swift
//  EuropeanCuisineServer
//
//  Created by Aesmond on 01/10/2026.
//  Copyright © 2026 Aesmond. All rights reserved.
//

import Fluent
import Vapor

struct CreateUserMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        var builderR = database.enum("user_role")
        for r in User.Role.allCases {
            builderR = builderR.case(r.rawValue)
        }
        let role = try await builderR.create()

        var builderS = database.enum("user_status")
        for s in User.Status.allCases {
            builderS = builderS.case(s.rawValue)
        }
        let status = try await builderS.create()

        try await database.schema("users")
            .id()
            .field("name", .string, .required)
            .field("email", .string, .required)
            .field("password_hash", .string, .required)
            .field("picture_url", .string)
            .field("role", role, .required)
            .field("status", status, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("users")
            .delete()
    }
}

//
//  CreateUserInfosMigration.swift
//  EuropeanCuisineServer
//
//  Created by Aesmond on 07/10/2026.
//  Copyright © 2026 Aesmond. All rights reserved.
//  

import Fluent
import FluentSQL
import Vapor

struct CreateUserInfosMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        var builder = database.enum("user_status")
        for s in User.Status.allCases {
            builder = builder.case(s.rawValue)
        }
        let status = try await builder.create()
        
        try await database.schema(UserInfos.schema)
            .id()
            .field("status", status, .required)
            .field("picture_url", .sql(unsafeRaw: "VARCHAR(500)"))
            .field(
                "user_id",
                .uuid,
                .required,
                .references(User.schema, "id", onDelete: .cascade)
            )
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(UserInfos.schema)
            .delete()
        
        try await database.enum("user_status").delete()
    }
}

//
//  CreateCategoryMigration.swift
//  EuropeanCuisineServer
//
//  Created by Aesmond on 01/10/2026.
//  Copyright © 2026 Aesmond. All rights reserved.
//

import Fluent
import Vapor

struct CreateCategoryMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
      try await database.schema(Category.schema)
            .id()
            .field("name", .string, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("categories")
            .delete()
    }
}

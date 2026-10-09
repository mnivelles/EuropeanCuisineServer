//
//  CreateReservationMigration.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 01/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Fluent
import Vapor

struct CreateReservationMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        var builder = database.enum(Reservation.Status.schema)
        for currentStatus in Reservation.Status.allCases {
            builder = builder.case(currentStatus.rawValue)
        }
        let status = try await builder.create()

        try await database.schema(Reservation.schema)
            .id()
            .field("status", status, .required)
            .field("workshop_id",
                   .uuid,
                   .required,
                   .references(Workshop.schema, "id", onDelete: .cascade))
            .field("user_id",
                   .uuid,
                   .required,
                   .references(User.schema, "id", onDelete: .cascade))
            .unique(on: "workshop_id", "user_id")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Reservation.schema)
            .delete()

        try await database.enum(Reservation.Status.schema).delete()
    }
}

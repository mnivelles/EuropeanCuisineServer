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
        var builder = database.enum("reservation_status")
        for s in Reservation.Status.allCases {
            builder = builder.case(s.rawValue)
        }
        let status = try await builder.create()

        try await database.schema("reservations")
            .id()
            .field("status", status, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("workshop_id",
                   .uuid,
                   .required,
                   .references("workshops", "id", onDelete: .cascade))
            .field("user_id",
                   .uuid,
                   .required,
                   .references("users", "id", onDelete: .cascade))
            .unique(on: "workshop_id", "user_id")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("reservations")
            .delete()
    }
}

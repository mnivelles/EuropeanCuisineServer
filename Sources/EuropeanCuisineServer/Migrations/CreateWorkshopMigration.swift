//
//  CreateWorkshopMigration.swift
//  EuropeanCuisineServer
//
//  Created by Aesmond on 01/10/2026.
//  Copyright © 2026 Aesmond. All rights reserved.
//  

import Fluent
import Vapor

struct CreateWorkshopMigration: AsyncMigration {
    
    func prepare(on database: any Database) async throws {
        var builder = database.enum("status")
        for s in Workshop.Status.allCases {
            builder = builder.case(s.rawValue)
        }
        let status = try await builder.create()
        
        try await database.schema("workshops")
            .id()
            .field("name", .string, .required)
            .field("start_time", .datetime, .required)
            .field("end_time", .datetime, .required)
            .field("capacity_max", .uint16, .required)
            .field("description", .string, .required) // FIXME: Mettre text
            .field("picture_url", .string, .required)
            .field("status", status, .required)
            .field("is_vegan", .bool, .required)
            .field("is_prm", .bool, .required)
            .field("is_family_friendly", .bool, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("workshops")
            .delete()
    }
}

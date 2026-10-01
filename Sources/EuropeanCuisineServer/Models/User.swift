//
//  User.swift
//  EuropeanCuisineServer
//
//  Created by Aesmond on 01/10/2026.
//  Copyright © 2026 Aesmond. All rights reserved.
//

import Fluent
import Vapor

final class User: Model, @unchecked Sendable {
    static let schema: String = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "email")
    var email: String

    @Field(key: "password_hash")
    var passwordHash: String

    @OptionalField(key: "picture_url")
    var pictureURL: String?

    @Enum(key: "role")
    var role: User.Role

    @Enum(key: "status")
    var status: User.Status

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Children(for: \.$user)
    var reservations: [Reservation]

    init() {}

    init(id: UUID? = nil,
         name: String,
         email: String,
         passwordHash: String,
         pictureURL: String? = nil,
         role: User.Role,
         status: User.Status) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
        self.pictureURL = pictureURL
        self.role = role
        self.status = status
    }
}

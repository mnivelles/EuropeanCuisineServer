//
//  UserController.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 15/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let api = routes.grouped("api", "v0")

        // Admin : only an admin can see list of users
        let adminUsers = api
            .grouped("admin", "users")
            .requiring(.admin)
        adminUsers.get(use: list)

        // A user authenticated can see his/her infos
        let authenticatedUsers = api
            .grouped("users")
            .authenticated()
        authenticatedUsers.get("infos", use: show)
    }

    private func list(req: Request) async throws -> [UserOutput] {
        let users = try await User
            .query(on: req.db)
            .sort(\.$name, .ascending)
            .with(\.$infos)
            .all()

        return try users.compactMap { user in
            guard let infos = user.infos else {
                return nil
            }

            return try UserOutput(user: user,
                                  infos: infos)
        }
    }

    private func show(req: Request) async throws -> UserOutput {
        let user = try req.auth.require(User.self)

        try await user.$infos.load(on: req.db)

        guard let infos = user.infos else {
            throw UserError.infosNotFound
        }

        return try UserOutput(user: user,
                              infos: infos)
    }
}

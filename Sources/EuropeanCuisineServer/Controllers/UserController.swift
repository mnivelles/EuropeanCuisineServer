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
        // Protected routes - require authentication
        let protected = routes.grouped(JWTAuthMiddleware(),
                                       User.guardMiddleware())

        let users = routes.grouped("api", "v0", "users")

        users.get(use: list)

        #warning("teste une route qui nécessite d'être authentifié")
        let protectedUsers = protected.grouped("api", "v0", "users")
        protectedUsers.get("me") { req -> UserOutput in
            let user = try req.auth.require(User.self)

            try await user.$infos.load(on: req.db)

            guard let infos = user.infos else {
                throw UserError.infosNotFound
            }

            return try UserOutput(user: user,
                                  infos: infos)
        }

        #warning("teste une route qui nécessite d'être authentifié et admin")
        let protectedForAdmin = protectedUsers.requiring(.admin)
        protectedForAdmin.get("profile") { _ -> String in
            "You are an admin"
        }
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

            return try UserOutput(user: user, infos: infos)
        }
    }
}

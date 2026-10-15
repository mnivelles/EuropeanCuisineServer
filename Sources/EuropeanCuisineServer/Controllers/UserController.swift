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
        let users = routes.grouped("api", "v0", "users")

        users.get(use: list)
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

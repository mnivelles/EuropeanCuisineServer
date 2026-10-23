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

    private func list(req: Request) async throws -> Page<AdminUserListItemOutput> {
        let locale = LocalizationUtils.getLocale(req: req)
        let input = try req.query.decode(AdminUserListSortSearchInput.self)

        let user = try req.auth.require(User.self)

        let query = try User
            .query(on: req.db)
            .filter(\.$id != user.requireID())
            .with(\.$infos)

        if let searchText = input.query,
           searchText.trimmed.isNotEmpty {
            query
                .filter(\.$name ~~ searchText.trimmed)
        }

        if let sort = input.sort {
            switch sort {
            case .name:
                query
                    .sort(\.$name, .ascending)
            case .email:
                query
                    .sort(\.$email, .ascending)
            case .role:
                query
                    .sort(\.$role, .ascending)
                    .sort(\.$name, .ascending)
            case .createdAt:
                query
                    .sort(\.$createdAt, .descending)
            }
        } else {
            query
                .sort(\.$name, .ascending)
        }

        if let role = input.role {
            query
                .filter(\.$role == role)
        }

        let users = try await query
            .paginate(for: req)

        return try users.compactMap { user in
            guard let infos = user.infos else {
                return nil
            }

            return try AdminUserListItemOutput(user: user,
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

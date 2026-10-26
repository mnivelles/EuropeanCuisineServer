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
    private let imageFolder = "users"

    func boot(routes: any RoutesBuilder) throws {
        let api = routes.grouped("api", "v0")

        // A user authenticated can see his/her infos
        let authenticatedUsers = api
            .grouped("users")
            .authenticated()
        authenticatedUsers.get("infos", use: infos)

        // Admin : only an admin can see list of users
        let adminUsers = api
            .grouped("admin", "users")
            .requiring(.admin)
        adminUsers.get(use: adminList)

        adminUsers.group(":id") { user in
            user.get(use: adminShow)
            user.on(.PUT,
                    body: .collect(maxSize: Constants.Image.requestMaxSize),
                    use: adminUpdate)
            user.patch("enable", use: adminEnableUser)
            user.patch("disable", use: adminDisableUser)
        }
    }

    private func adminList(req: Request) async throws -> Page<AdminUserListItemOutput> {
        let input = try req.query.decode(AdminUserListSortSearchInput.self)

        let user = try req.auth.require(User.self)

        let query = try User
            .query(on: req.db)
            .filter(\.$id != user.requireID())
            .join(UserInfos.self, on: \User.$id == \UserInfos.$user.$id)
            .with(\.$infos)

        if let searchText = input.query,
           searchText.trimmed.isNotEmpty {
            query
                .filter(\.$name ~~ searchText.trimmed)
        }

        if let status = input.status {
            switch status {
            case .enabled:
                query
                    .filter(UserInfos.self, \.$status == .active)
            case .disabled:
                query
                    .filter(UserInfos.self, \.$status == .disabled)
            }
        }

        if let role = input.role {
            query
                .filter(\.$role == role)
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

    private func infos(req: Request) async throws -> UserOutput {
        let user = try req.auth.require(User.self)

        try await user.$infos.load(on: req.db)

        guard let infos = user.infos else {
            throw UserError.infosNotFound
        }

        return try UserOutput(user: user,
                              infos: infos)
    }

    private func adminShow(req: Request) async throws -> AdminShowUserOutput {
        let id = try req.parameters.require("id", as: UUID.self)

        let authUser = try req.auth.require(User.self)

        guard authUser.id != id else {
            throw UserError.sameUser
        }

        guard let user = try await User.find(id, on: req.db) else {
            throw UserError.notFound
        }

        try await user.$infos.load(on: req.db)

        guard let infos = user.infos else {
            throw UserError.infosNotFound
        }

        return try AdminShowUserOutput(user: user, infos: infos)
    }

    private func adminUpdate(req: Request) async throws -> AdminShowUserOutput {
        let id = try req.parameters.require("id", as: UUID.self)

        let authUser = try req.auth.require(User.self)

        guard authUser.id != id else {
            throw UserError.sameUser
        }

        try AdminUpdateUserInput.validate(content: req)

        let input = try req.content.decode(AdminUpdateUserInput.self)

        guard let user = try await User.find(id, on: req.db) else {
            throw UserError.notFound
        }

        try await user.$infos.load(on: req.db)

        guard user.infos?.status == .active else {
            throw UserError.disabled
        }

        guard try await (User.query(on: req.db).filter(\.$email == input.email).first() == nil) ||
            user.email == input.email.trimmed else {
            throw UserError.emailAlreadyExists
        }

        return try await req.db.transaction { db in
            if let picture = input.picture {
                let storage = ImageStorage()

                let url = try await storage.upload(req: req,
                                                   file: picture,
                                                   folder: imageFolder,
                                                   id: user.requireID())

                user.infos?.pictureURL = url.absoluteString

                try await user.infos?.update(on: db)
            }

            apply(input: input, to: user)

            try await user.update(on: db)

            guard let infos = user.infos else {
                throw UserError.infosNotFound
            }

            return try AdminShowUserOutput(user: user,
                                           infos: infos)
        }
    }

    private func adminEnableUser(req: Request) async throws -> HTTPStatus {
        let id = try req.parameters.require("id", as: UUID.self)

        let authUser = try req.auth.require(User.self)

        guard authUser.id != id else {
            throw UserError.sameUser
        }

        guard let user = try await User.find(id, on: req.db) else {
            throw UserError.notFound
        }

        try await user.$infos.load(on: req.db)

        guard user.infos?.status == .disabled else {
            throw UserError.invalidAction
        }

        user.infos?.status = .active
        try await user.infos?.update(on: req.db)

        return .ok
    }

    private func adminDisableUser(req: Request) async throws -> HTTPStatus {
        let id = try req.parameters.require("id", as: UUID.self)

        let authUser = try req.auth.require(User.self)

        guard authUser.id != id else {
            throw UserError.sameUser
        }

        guard let user = try await User.find(id, on: req.db) else {
            throw UserError.notFound
        }

        try await user.$infos.load(on: req.db)

        guard user.infos?.status == .active else {
            throw UserError.invalidAction
        }

        user.infos?.status = .disabled
        try await user.infos?.update(on: req.db)

        return .ok
    }

    private func apply(input: AdminUpdateUserInput, to user: User) {
        user.name = input.name.trimmed
        user.email = input.email.trimmed
        user.role = input.role
    }
}

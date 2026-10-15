//
//  AuthController.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 15/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Fluent
import Vapor

struct AuthController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("api", "v0", "auth")

        // signup -> admin seulement
        users.post("sign-up", use: signup)

        users.post("log-in", use: login)
    }

    private func signup(req: Request) async throws -> Response {
        try AuthSignupInput.validate(content: req)

        let input = try req.content.decode(AuthSignupInput.self)

        guard try await User
            .query(on: req.db)
            .filter(\.$email == input.email)
            .first() == nil else {
            throw AuthError.passwordOrEmailFailed
        }

        let passwordHash = try Bcrypt.hash(input.password)

        let user = User(name: input.name,
                        email: input.email,
                        passwordHash: passwordHash,
                        role: .staff)

        return try await req.db.transaction { db in
            try await user.create(on: db)

            let infos = try UserInfos(status: .active,
                                      pictureURL: nil,
                                      userID: user.requireID())

            try await infos.create(on: db)

            return try await UserOutput(user: user, infos: infos)
                .encodeResponse(status: .created, for: req)
        }
    }

    private func login(req: Request) async throws -> TokenResponse {
        try AuthLoginInput.validate(content: req)

        let input = try req.content.decode(AuthLoginInput.self)

        guard let user = try await User
            .query(on: req.db)
            .filter(\.$email == input.email)
            .first() else {
            throw AuthError.unauthorized
        }

        guard try user.verify(password: input.password) else {
            throw AuthError.unauthorized
        }

        let token = try await UserJWTPayload.generateToken(for: user,
                                                           req: req)

        return TokenResponse(token: token)
    }
}

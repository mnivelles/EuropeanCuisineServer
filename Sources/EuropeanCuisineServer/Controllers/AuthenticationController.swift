//
//  AuthenticationController.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 15/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Fluent
import Vapor

struct AuthenticationController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let api = routes.grouped("api", "v0")

        // Public
        let publicAuth = api.grouped("auth")
        publicAuth.post("sign-up", use: signUpFestivalGoer) // Sign up Festival goer
        publicAuth.post("log-in", use: login) // Log in anybody

        // Admin
        let adminAuth = api
            .grouped("admin", "auth")
            .requiring(.admin)
        adminAuth
            .post("sign-up", use: signUpStaff) // Sign up Staff
    }

    private func signUpFestivalGoer(req: Request) async throws -> Response {
        try await signUp(req: req, role: .festivalGoer)
    }

    private func signUpStaff(req: Request) async throws -> Response {
        try await signUp(req: req, role: .staff)
    }

    private func login(req: Request) async throws -> LogInOutput {
        try AuthLogInInput.validate(content: req)

        let input = try req.content.decode(AuthLogInInput.self)

        guard let user = try await User
            .query(on: req.db)
            .filter(\.$email == input.email)
            .with(\.$infos)
            .first() else {
            throw AuthError.unauthorized
        }

        guard try user.verify(password: input.password) else {
            throw AuthError.unauthorized
        }

        guard user.isActive else {
            throw AuthError.notActive
        }

        let token = try await UserJWTPayload.generateToken(for: user,
                                                           req: req)

        let pictureURL = user.infos?.pictureURL

        return LogInOutput(token: token,
                           name: user.name,
                           email: user.email,
                           pictureURL: pictureURL)
    }

    private func signUp(req: Request, role: User.Role) async throws -> Response {
        try AuthSignUpInput.validate(content: req)

        let input = try req.content.decode(AuthSignUpInput.self)

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
                        role: role)

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
}

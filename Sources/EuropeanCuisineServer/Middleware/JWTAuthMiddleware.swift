//
//  JWTAuthMiddleware.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 15/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Fluent
import JWT
import Vapor

struct JWTAuthMiddleware: JWTAuthenticator {
    func authenticate(jwt: UserJWTPayload, for req: Vapor.Request) async throws {
        guard let userID = UUID(uuidString: jwt.subject.value) else {
            return
        }

        guard let user = try await User.query(on: req.db)
            .filter(\.$id == userID)
            .with(\.$infos)
            .first() else {
            return
        }

        guard user.isActive else {
            return
        }

        req.auth.login(user)
    }
}

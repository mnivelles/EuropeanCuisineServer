//
//  RoleMiddleware.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 15/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Vapor

struct RoleMiddleware: AsyncMiddleware {
    let allowedRoles: [User.Role]

    init(allowing roles: User.Role...) {
        self.allowedRoles = roles
    }

    func respond(to req: Request,
                 chainingTo next: any AsyncResponder) async throws -> Response {
        let user = try req.auth.require(User.self)

        guard allowedRoles.contains(user.role) else {
            throw Abort(.forbidden,
                        reason: "Access denied. You don't have permission to access this resource.")
        }

        return try await next.respond(to: req)
    }
}

extension RoutesBuilder {
    func requiring(_ roles: User.Role...) -> any RoutesBuilder {
        grouped(RoleMiddleware(allowing: roles))
    }
}

extension RoleMiddleware {
    init(allowing roles: [User.Role]) {
        self.allowedRoles = roles
    }
}

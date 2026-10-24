//
//  UserRoleController.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 24/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Vapor

struct UserRoleController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let roles = routes.grouped("api", "v0", "admin", "users", "roles")

        roles
            .requiring(.admin)
            .get("options", use: options)
    }

    private func options(req: Request) -> [UserRoleOptionOutput] {
        UserRoleUtils.getOptions()
    }
}

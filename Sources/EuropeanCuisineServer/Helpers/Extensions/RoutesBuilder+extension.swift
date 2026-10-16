//
//  RoutesBuilder+extension.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 15/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Vapor

extension RoutesBuilder {
    func authenticated() -> any RoutesBuilder {
        grouped(JWTAuthMiddleware(),
                User.guardMiddleware())
    }

    func requiring(_ roles: User.Role...) -> any RoutesBuilder {
        authenticated()
            .grouped(RoleMiddleware(allowing: roles))
    }
}

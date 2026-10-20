//
//  AllergenController.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 20/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Vapor

struct AllergenController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let allergens = routes.grouped("api", "v0", "allergens")

        allergens.get("options", use: options)
    }

    private func options(req: Request) -> [AllergenOptionOutput] {
        AllergenUtils.getOptions()
    }
}

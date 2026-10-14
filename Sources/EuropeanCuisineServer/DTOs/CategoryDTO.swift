//
//  CategoryDTO.swift
//  EuropeanCuisineServer
//
//  Created by Aesmond on 08/10/2026.
//  Copyright © 2026 Aesmond. All rights reserved.
//

import Fluent
import Vapor

struct CategoryInput: Content {
    let name: String
}

extension CategoryInput {
    func toModel() -> Category {
        Category(name: name.trimmed)
    }
}

extension CategoryInput: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name",
                        as: String.self,
                        is: Constants.Category.Name.validator)
    }
}

struct CategoryOutput: Content {
    let id: UUID
    let name: String
}

extension CategoryOutput {
    init(_ category: Category) throws {
        self.id = try category.requireID()
        self.name = category.name
    }
}

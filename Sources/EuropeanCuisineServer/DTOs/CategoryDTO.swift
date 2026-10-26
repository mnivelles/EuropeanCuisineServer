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

struct AdminCategoryListSortSearchInput: Content {
    let query: String?
    let sort: Sort?

    enum Sort: String, Codable {
        case name
        case workshopCount = "workshop_count"
    }

    enum CodingKeys: String, CodingKey {
        case query, sort
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.query = try container.decodeIfNotEmpty(String.self, forKey: .query)
        self.sort = try container.decodeIfNotEmpty(Sort.self, forKey: .sort)
    }
}

struct AdminCreateCategoryInput: Content {
    let name: String
}

extension AdminCreateCategoryInput {
    func toModel() -> Category {
        Category(name: name.trimmed)
    }
}

extension AdminCreateCategoryInput: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name",
                        as: String.self,
                        is: Constants.Category.Name.validator)
    }
}

struct AdminCreateCategoryOutput: Content {
    let id: UUID
    let name: String
}

extension AdminCreateCategoryOutput {
    init(_ category: Category) throws {
        self.id = try category.requireID()
        self.name = category.name
    }
}

struct AdminShowCategoryOutput: Content {
    let id: UUID
    let name: String
}

extension AdminShowCategoryOutput {
    init(_ category: Category) throws {
        self.id = try category.requireID()
        self.name = category.name
    }
}

struct AdminUpdateCategoryInput: Content {
    let name: String
}

extension AdminUpdateCategoryInput: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name",
                        as: String.self,
                        is: Constants.Category.Name.validator)
    }
}

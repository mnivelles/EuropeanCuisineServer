//
//  Category.swift
//  EuropeanCuisineServer
//
//  Created by Aesmond on 01/10/2026.
//  Copyright © 2026 Aesmond. All rights reserved.
//

import Fluent
import Vapor

final class Category: Model, @unchecked Sendable {
    static let schema: String = "categories"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Children(for: \.$category)
    var workshops: [Workshop]

    init() {}

    init(id: UUID? = nil,
         name: String) {
        self.id = id
        self.name = name
    }
}

//
//  CategoryController.swift
//  EuropeanCuisineServer
//
//  Created by Aesmond on 08/10/2026.
//  Copyright © 2026 Aesmond. All rights reserved.
//

import Fluent
import Vapor

struct CategoryController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let api = routes.grouped("api", "v0")

        #warning("Delete from public create, update and delete")
        let publicCategories = api.grouped("categories")
        publicCategories.get(use: list)
        publicCategories.post(use: create)

        publicCategories.group(":id") { category in
            category.get(use: show)
            category.put(use: update)
            category.delete(use: delete)
        }

        let adminCategories = api.grouped("admin", "categories")
            .requiring(.admin, .staff)
        adminCategories.get(use: adminTableList)
    }

    private func list(req: Request) async throws -> [CategoryOutput] {
        let categories = try await Category.query(on: req.db).all()

        return try categories.map(CategoryOutput.init)
    }

    private func adminTableList(req: Request) async throws -> Page<CategoryOutput> {
        let query = Category.query(on: req.db)
            .sort(\.$name, .ascending)

        let page = try await query.paginate(for: req)

        let items = try page.items.map(CategoryOutput.init)

        return Page(items: items, metadata: page.metadata)
    }

    private func create(req: Request) async throws -> Response {
        try CategoryInput.validate(content: req)

        let input = try req.content.decode(CategoryInput.self)

        guard try await Category.query(on: req.db).filter(\.$name == input.name).first() == nil
        else {
            throw CategoryError.alreadyExists
        }

        let category = input.toModel()

        try await category.create(on: req.db)

        return try await CategoryOutput(category)
            .encodeResponse(status: .created, for: req)
    }

    private func show(req: Request) async throws -> CategoryOutput {
        let category = try await findCategory(req: req)

        return try CategoryOutput(category)
    }

    private func update(req: Request) async throws -> CategoryOutput {
        try CategoryInput.validate(content: req)

        let input = try req.content.decode(CategoryInput.self)

        let category = try await findCategory(req: req)

        guard try await Category.query(on: req.db).filter(\.$name == input.name)
            .first() == nil || (input.name == category.name) else {
            throw CategoryError.alreadyExists
        }

        apply(input: input, to: category)

        try await category.update(on: req.db)

        return try CategoryOutput(category)
    }

    private func delete(req: Request) async throws -> HTTPStatus {
        let category = try await findCategory(req: req)

        try await category.delete(on: req.db)

        return .noContent
    }

    private func findCategory(req: Request) async throws -> Category {
        let id = try req.parameters.require("id", as: UUID.self)

        guard let category = try await Category.find(id, on: req.db) else {
            throw CategoryError.notFound
        }

        return category
    }

    private func apply(input: CategoryInput, to category: Category) {
        category.name = input.name
    }
}

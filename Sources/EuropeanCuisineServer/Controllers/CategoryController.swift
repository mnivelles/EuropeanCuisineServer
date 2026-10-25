//
//  CategoryController.swift
//  EuropeanCuisineServer
//
//  Created by Aesmond on 08/10/2026.
//  Copyright © 2026 Aesmond. All rights reserved.
//

import Fluent
import SQLKit
import Vapor

struct CategoryController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let api = routes.grouped("api", "v0")

        #warning("remove create, update and delete from public")

        // Public
        let publicCategories = api.grouped("categories")
        publicCategories.get(use: list)
        publicCategories.post(use: create)

        publicCategories.group(":id") { category in
            category.get(use: show)
            category.put(use: update)
            category.delete(use: delete)
        }

        // Admin
        let adminCategories = api
            .grouped("admin", "categories")
            .requiring(.admin, .staff)

        adminCategories
            .get(use: adminList)
        adminCategories
            .post(use: adminCreate)

        adminCategories.group(":id") { category in
            category.get(use: adminShow)
            category.put(use: adminUpdate)
            category.delete(use: adminDelete)
        }
    }

    private func list(req: Request) async throws -> [CategoryOutput] {
        let categories = try await Category.query(on: req.db).all()

        return try categories.map(CategoryOutput.init)
    }

    private func create(req: Request) async throws -> Response {
        try CategoryInput.validate(content: req)

        let input = try req.content.decode(CategoryInput.self)

        guard try await Category.query(on: req.db).filter(\.$name == input.name.trimmed)
            .first() == nil
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
            .first() == nil || (input.name.trimmed == category.name.trimmed) else {
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

    private func adminList(req: Request) async throws -> Page<AdminWorkshopCategoryListOutput> {
        guard let sql = req.db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "SQL database required")
        }

        let input = try req.query.decode(AdminCategoryListSortSearchInput.self)
        let pageRequest = try req.query.decode(PageRequest.self)

        let page = max(pageRequest.page, 1)
        let per = min(max(pageRequest.per, 1), 100)
        let offset = (page - 1) * per

        var whereClause: SQLQueryString = ""
        if let searchText = input.query?.trimmed, searchText.isNotEmpty {
            whereClause = "WHERE c.name LIKE \(bind: "%\(searchText)%")"
        }

        let orderClause: SQLQueryString = input.sort == .workshopCount
            ? "ORDER BY workshop_count ASC, c.name ASC"
            : "ORDER BY c.name ASC"

        struct Row: Decodable {
            let id: UUID
            let name: String
            let workshop_count: Int
            let total: Int
        }

        let rows = try await sql.raw("""
        SELECT
            c.id AS id,
            c.name AS name,
            COUNT(w.id) AS workshop_count,
            COUNT(*) OVER() AS total
        FROM categories c
        LEFT JOIN workshops w ON w.category_id = c.id
        \(whereClause)
        GROUP BY c.id, c.name
        \(orderClause)
        LIMIT \(literal: per)
        OFFSET \(literal: offset)
        """)
        .all(decoding: Row.self)

        let items = rows.map {
            AdminWorkshopCategoryListOutput(id: $0.id,
                                            name: $0.name,
                                            numberOfWorkshops: UInt($0.workshop_count))
        }

        return Page(items: items,
                    metadata: PageMetadata(page: page, per: per, total: rows.first?.total ?? 0))
    }

    private func adminCreate(req: Request) async throws -> Response {
        try AdminCreateCategoryInput.validate(content: req)

        let input = try req.content.decode(AdminCreateCategoryInput.self)

        guard try await Category.query(on: req.db).filter(\.$name == input.name.trimmed)
            .first() == nil
        else {
            throw CategoryError.alreadyExists
        }

        let category = input.toModel()

        try await category.create(on: req.db)

        return try await AdminCreateCategoryOutput(category)
            .encodeResponse(status: .created, for: req)
    }

    private func adminShow(req: Request) async throws -> AdminShowCategoryOutput {
        let category = try await findCategory(req: req)

        return try AdminShowCategoryOutput(category)
    }

    private func adminUpdate(req: Request) async throws -> AdminShowCategoryOutput {
        try AdminUpdateCategoryInput.validate(content: req)

        let input = try req.content.decode(AdminUpdateCategoryInput.self)

        let category = try await findCategory(req: req)

        guard try await Category.query(on: req.db).filter(\.$name == input.name.trimmed)
            .first() == nil || (input.name.trimmed == category.name)
        else {
            throw CategoryError.alreadyExists
        }

        apply(input: input, to: category)

        try await category.update(on: req.db)

        return try AdminShowCategoryOutput(category)
    }

    private func adminDelete(req: Request) async throws -> HTTPStatus {
        let category = try await findCategory(req: req)

        let workshopsCount = try await category.$workshops
            .query(on: req.db)
            .count()

        guard workshopsCount == 0 else {
            throw CategoryError.containsWorkshops
        }

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
        category.name = input.name.trimmed
    }

    private func apply(input: AdminUpdateCategoryInput, to category: Category) {
        category.name = input.name.trimmed
    }
}

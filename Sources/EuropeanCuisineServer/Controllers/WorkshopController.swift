//
//  WorkshopController.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 05/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Fluent
import Vapor

struct WorkshopController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let workshops = routes.grouped("api", "v0", "workshops")

        workshops.get(use: list)
        workshops.post(use: create)

        workshops.group(":id") { workshop in
            workshop.get(use: show)
            workshop.put(use: update)
            workshop.delete(use: delete)
        }
    }

    private func list(req: Request) async throws -> [WorkshopOutput] {
        let workshops = try await Workshop.query(on: req.db).all()

        return try workshops.map(WorkshopOutput.init)
    }

    private func create(req: Request) async throws -> Response {
        try WorkshopInput.validate(content: req)

        let input = try req.content.decode(WorkshopInput.self)

        try input.validateDateOrder()

        guard try await Category.query(on: req.db).filter(\.$id == input.categoryID).first() != nil
        else {
            throw CategoryError.notFound
        }

        let workshop = input.toModel()

        try await workshop.create(on: req.db)

        return try await WorkshopOutput(workshop)
            .encodeResponse(status: .created, for: req)
    }

    private func show(req: Request) async throws -> WorkshopOutput {
        let workshop = try await findWorkshop(req: req)

        return try WorkshopOutput(workshop)
    }

    private func update(req: Request) async throws -> WorkshopOutput {
        try WorkshopInput.validate(content: req)

        let input = try req.content.decode(WorkshopInput.self)

        try input.validateDateOrder()

        let workshop = try await findWorkshop(req: req)

        apply(input: input, to: workshop)

        try await workshop.update(on: req.db)

        return try WorkshopOutput(workshop)
    }

    private func delete(req: Request) async throws -> HTTPStatus {
        let workshop = try await findWorkshop(req: req)

        try await workshop.delete(on: req.db)

        return .noContent
    }

    private func findWorkshop(req: Request) async throws -> Workshop {
        let id = try req.parameters.require("id", as: UUID.self)

        guard let workshop = try await Workshop.find(id, on: req.db) else {
            throw WorkshopError.notFound
        }

        return workshop
    }

    private func apply(input: WorkshopInput, to workshop: Workshop) {
        workshop.name = input.name
        workshop.startTime = input.startTime
        workshop.endTime = input.endTime
        workshop.capacityMax = input.capacityMax
        workshop.description = input.description
        workshop.$category.id = input.categoryID
    }
}

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
        let workshops = try await Workshop
            .query(on: req.db)
            .with(\.$infos)
            .with(\.$category)
            .all()

        var outputs: [WorkshopOutput] = []

        for workshop in workshops {
            guard let infos = workshop.infos else {
                continue
            }

            let bookedCapacity = try await calculateBookedCapacity(workshopID: workshop.requireID(),
                                                                   req: req)

            let output = try WorkshopOutput(workshop: workshop,
                                            infos: infos,
                                            bookedCapacity: bookedCapacity)
            outputs.append(output)
        }

        return outputs
    }

    private func create(req: Request) async throws -> Response {
        try WorkshopInput.validate(content: req)

        let input = try req.content.decode(WorkshopInput.self)

        try input.validateDateOrder()

        guard try await Category.query(on: req.db).filter(\.$id == input.categoryID).first() != nil
        else {
            throw CategoryError.notFound
        }

        return try await req.db.transaction { db in
            let workshop = input.toModel()

            try await workshop.create(on: db)

            let infos = try input.toInfos(workshopID: workshop.requireID())

            try await infos.create(on: db)

            try await workshop.$category.load(on: db)

            let bookedCapacity = try await calculateBookedCapacity(workshopID: workshop.requireID(),
                                                                   req: req)

            return try await WorkshopOutput(workshop: workshop,
                                            infos: infos, bookedCapacity: bookedCapacity)
                .encodeResponse(status: .created, for: req)
        }
    }

    private func show(req: Request) async throws -> WorkshopOutput {
        let workshop = try await findWorkshop(req: req)

        guard let infos = workshop.infos else {
            throw WorkshopError.infosNotFound
        }

        let bookedCapacity = try await calculateBookedCapacity(workshopID: workshop.requireID(),
                                                               req: req)

        return try WorkshopOutput(workshop: workshop,
                                  infos: infos, bookedCapacity: bookedCapacity)
    }

    private func update(req: Request) async throws -> WorkshopOutput {
        try WorkshopInput.validate(content: req)

        let input = try req.content.decode(WorkshopInput.self)

        try input.validateDateOrder()

        let workshop = try await findWorkshop(req: req)

        guard let infos = workshop.infos else {
            throw WorkshopError.infosNotFound
        }

        apply(input: input, to: workshop)
        apply(input: input, to: infos)

        return try await req.db.transaction { db in
            try await workshop.update(on: db)
            try await infos.update(on: db)

            let bookedCapacity = try await calculateBookedCapacity(workshopID: workshop.requireID(),
                                                                   req: req)

            return try WorkshopOutput(workshop: workshop,
                                      infos: infos, bookedCapacity: bookedCapacity)
        }
    }

    private func delete(req: Request) async throws -> HTTPStatus {
        let workshop = try await findWorkshop(req: req)

        try await workshop.delete(on: req.db)

        return .noContent
    }

    private func findWorkshop(req: Request) async throws -> Workshop {
        let id = try req.parameters.require("id", as: UUID.self)

        let workshop = try await Workshop
            .query(on: req.db)
            .filter(\.$id == id)
            .with(\.$infos)
            .with(\.$category)
            .first()

        guard let workshop else {
            throw WorkshopError.notFound
        }

        return workshop
    }

    private func calculateBookedCapacity(workshopID: UUID, req: Request) async throws -> UInt16 {
        let reservations = try await Reservation
            .query(on: req.db)
            .filter(\.$workshop.$id == workshopID)
            .all()

        let activeReservations = reservations.filter {
            $0.status == .confirmed || $0.status == .pending
        }

        return UInt16(activeReservations.count)
    }

    private func apply(input: WorkshopInput, to workshop: Workshop) {
        workshop.name = input.name
        workshop.startTime = input.startTime
        workshop.endTime = input.endTime
        workshop.capacityMax = input.capacityMax
        workshop.description = input.description
        workshop.$category.id = input.categoryID
    }

    private func apply(input: WorkshopInput,
                       to infos: WorkshopInfos) {
        infos.pictureURL = input.pictureURL
        infos.location = input.location
        infos.isVegan = input.isVegan
        infos.isPRM = input.isPRM
        infos.isFamilyFriendly = input.isFamilyFriendly
    }
}

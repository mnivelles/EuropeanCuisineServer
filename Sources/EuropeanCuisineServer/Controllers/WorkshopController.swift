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
    private let imageFolder = "workshops"

    func boot(routes: any RoutesBuilder) throws {
        let api = routes.grouped("api", "v0")

        // Public
        #warning("Delete from public create, update and delete")
        let publicWorkshops = api.grouped("workshops")
        publicWorkshops.get(use: list)

        publicWorkshops.group(":id") { workshop in
            workshop.get(use: show)
        }

        // Admin
        let adminWorkshops = api.grouped("admin", "workshops")
            .requiring(.admin, .staff)
        adminWorkshops.get(use: adminTableList)
        adminWorkshops.on(.POST,
                          body: .collect(maxSize: Constants.Image.requestMaxSize),
                          use: adminCreate)

        adminWorkshops.get(":workshopID", "reservations", use: adminWorkshopReservationList)

        adminWorkshops.get("calendar", use: adminCalendar)

        adminWorkshops.group(":id") { workshop in
            workshop.on(.PUT,
                        body: .collect(maxSize: Constants.Image.requestMaxSize),
                        use: adminUpdate)
            workshop.patch("cancel", use: adminCancel)
            workshop.patch("publish", use: adminPublish)
        }
    }

    private func list(req: Request) async throws -> [WorkshopOutput] {
        let workshops = try await Workshop
            .query(on: req.db)
            .with(\.$infos)
            .with(\.$category)
            .sort(\.$name, .ascending)
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

    private func adminTableList(req: Request) async throws -> Page<AdminWorkshopListItemOutput> {
        let input = try req.query.decode(AdminWorkshopListSortSearchInput.self)

        let query = Workshop.query(on: req.db)
            .join(Category.self, on: \Workshop.$category.$id == \Category.$id)
            .join(WorkshopInfos.self, on: \WorkshopInfos.$workshop.$id == \Workshop.$id)
            .with(\.$infos)
            .with(\.$category)

        if let searchText = input.query,
           searchText.trimmed.isNotEmpty {
            query
                .filter(\.$name ~~ searchText.trimmed)
        }

        if let sort = input.sort {
            switch sort {
            case .name:
                query
                    .sort(\.$name, .ascending)
            case .category:
                query
                    .sort(Category.self, \.$name, .ascending)
                    .sort(\.$name, .ascending)
            case .location:
                query
                    .sort(WorkshopInfos.self, \.$location, .ascending)
                    .sort(\.$name, .ascending)
            case .date:
                query
                    .sort(\.$startTime, .ascending)
            }
        } else {
            query
                .sort(\.$name, .ascending)
        }

        let page = try await query.paginate(for: req)

        var items: [AdminWorkshopListItemOutput] = []
        for workshop in page.items {
            guard let infos = workshop.infos else { continue }

            let bookedCapacity = try await calculateBookedCapacity(workshopID: workshop.requireID(),
                                                                   req: req)

            try items.append(AdminWorkshopListItemOutput(workshop: workshop,
                                                         infos: infos,
                                                         bookedCapacity: bookedCapacity))
        }

        return Page(items: items, metadata: page.metadata)
    }

    private func adminWorkshopReservationList(req: Request) async throws
        -> Page<AdminWorkshopReservationListItemOutput> {
        let workshopID = try req.parameters.require("workshopID", as: UUID.self)

        let filter = req.query[String.self, at: "filter"] ?? "status"

        let query = Reservation.query(on: req.db)
            .filter(\.$workshop.$id == workshopID)
        if filter != "status",
           let status = Reservation.Status(rawValue: filter) {
            query.filter(\.$status == status)
        }

        query.with(\.$user) { user in
            user.with(\.$infos)
        }

        let page = try await query.paginate(for: req)

        let items = try page.items.map { reservation in
            try AdminWorkshopReservationListItemOutput(reservation: reservation,
                                                       user: reservation.user)
        }

        return Page(items: items, metadata: page.metadata)
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

    private func adminCreate(req: Request) async throws -> Response {
        try AdminCreateWorkshopInput.validate(content: req)

        let input = try req.content.decode(AdminCreateWorkshopInput.self)
        let picture = input.picture

        guard try await Workshop.query(on: req.db)
            .filter(\.$name == input.name)
            .first() == nil else {
            throw WorkshopError.alreadyExists
        }

        guard let category = try await Category.query(on: req.db)
            .filter(\.$name == input.category.trimmed)
            .first()
        else {
            throw CategoryError.notFound
        }

        return try await req.db.transaction { db in
            let workshop = try input.toModel(categoryID: category.requireID())

            try await workshop.create(on: db)

            let storage = ImageStorage()

            let url = try await storage.upload(req: req,
                                               file: picture,
                                               folder: imageFolder,
                                               id: workshop.requireID())

            let infos = try input.toInfos(workshopID: workshop.requireID(),
                                          pictureURL: url.absoluteString)

            try await infos.create(on: db)

            try await workshop.$category.load(on: db)

            return try await AdminWorkshopListItemOutput(workshop: workshop,
                                                         infos: infos,
                                                         bookedCapacity: 0)
                .encodeResponse(status: .created, for: req)
        }
    }

    private func adminUpdate(req: Request) async throws -> WorkshopOutput {
        try AdminUpdateWorkshopInput.validate(content: req)

        let input = try req.content.decode(AdminUpdateWorkshopInput.self)
        try input.validateDateOrder()

        guard let category = try await Category.query(on: req.db)
            .filter(\.$name == input.category.trimmed)
            .first()
        else {
            throw CategoryError.notFound
        }

        let workshop = try await findWorkshop(req: req)

        guard let infos = workshop.infos else {
            throw WorkshopError.infosNotFound
        }

        let newStartTime = Date.combineUTC(date: input.date, time: input.startTime) ?? .distantPast
        let newEndTime = Date.combineUTC(date: input.date, time: input.endTime) ?? .distantPast

        var pictureURL = infos.pictureURL

        if let picture = input.picture {
            let storage = ImageStorage()
            let url = try await storage.upload(req: req,
                                               file: picture,
                                               folder: imageFolder,
                                               id: workshop.requireID())
            pictureURL = url.absoluteString
        }

        workshop.name = input.name.trimmed
        workshop.startTime = newStartTime
        workshop.endTime = newEndTime
        workshop.capacityMax = input.capacityMax
        workshop.description = input.about.trimmed
        workshop.$category.id = try category.requireID()

        infos.pictureURL = pictureURL
        infos.location = input.location.trimmed
        infos.isVegan = input.isVegan
        infos.isPRM = input.isPRM
        infos.isFamilyFriendly = input.isFamilyFriendly

        try await req.db.transaction { db in
            try await workshop.update(on: db)
            try await infos.update(on: db)
            try await workshop.$category.load(on: db)
        }

        let bookedCapacity = try await calculateBookedCapacity(workshopID: workshop.requireID(),
                                                               req: req)

        return try WorkshopOutput(workshop: workshop,
                                  infos: infos,
                                  bookedCapacity: bookedCapacity)
    }

    private func adminPublish(req: Request) async throws -> HTTPStatus {
        let workshop = try await findWorkshop(req: req)

        guard let infos = workshop.infos else {
            throw WorkshopError.infosNotFound
        }

        guard infos.status == .cancelled else {
            throw WorkshopError.invalidAction
        }

        infos.status = .published
        try await infos.update(on: req.db)

        return .noContent
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

    private func adminCancel(req: Request) async throws -> HTTPStatus {
        let workshop = try await findWorkshop(req: req)

        guard let infos = workshop.infos else {
            throw WorkshopError.infosNotFound
        }

        guard infos.status == .published else {
            throw WorkshopError.invalidAction
        }

        let workshopID = try workshop.requireID()

        let confirmedReservationsCount = try await Reservation
            .query(on: req.db)
            .filter(\.$workshop.$id == workshopID)
            .filter(\.$status == .confirmed)
            .count()

        guard confirmedReservationsCount == 0 else {
            throw WorkshopError.invalidAction
        }

        try await req.db.transaction { db in
            try await Reservation.query(on: db)
                .filter(\.$workshop.$id == workshopID)
                .filter(\.$status == .pending)
                .delete()

            try await Reservation.query(on: db)
                .filter(\.$workshop.$id == workshopID)
                .filter(\.$status == .cancelled)
                .delete()

            infos.status = .cancelled
            try await infos.update(on: db)
        }

        return .noContent
    }

    private func adminCalendar(req: Request) async throws -> AdminCalendarOutput {
        let input = try req.query.decode(AdminCalendarPaginationInput.self)
        let page = input.page ?? 1
        let per = input.per ?? 5

        let categories = try await Category.query(on: req.db)
            .sort(\.$name, .ascending)
            .all()

        let workshops = try await Workshop.query(on: req.db)
            .join(WorkshopInfos.self, on: \Workshop.$id == \WorkshopInfos.$workshop.$id)
            .filter(WorkshopInfos.self, \.$status == .published)
            .with(\.$category)
            .sort(\.$startTime, .ascending)
            .all()

        let items = try AdminCalendarOutput.make(from: workshops, categories: categories)
        let days = AdminCalendarOutput.days(from: workshops)
        let legend = try AdminCalendarOutput.legend(for: categories)

        let offset = max(0, (page - 1) * per)

        let paginatedItems = Array(items.dropFirst(offset).prefix(per))
        let paginatedDays = Array(days.dropFirst(offset).prefix(per))

        let totalPages = max(1, Int(ceil(Double(items.count) / Double(per))))
        let isFirstPage = (page == 1) && !items.isEmpty
        let isLastPage = (page >= totalPages) && !items.isEmpty

        return .init(items: paginatedItems,
                     rangeTitle: AdminCalendarOutput.rangeTitle(for: paginatedDays),
                     metadata: .init(isFirstPage: isFirstPage,
                                     isLastPage: isLastPage,
                                     page: page),
                     legends: legend)
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
        let count = try await Reservation
            .query(on: req.db)
            .filter(\.$workshop.$id == workshopID)
            .filter(\.$status == .confirmed)
            .count()

        guard count <= Int(UInt16.max) else {
            return 0
        }

        return UInt16(count)
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

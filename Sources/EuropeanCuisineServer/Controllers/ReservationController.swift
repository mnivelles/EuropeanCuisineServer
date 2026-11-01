//
//  ReservationController.swift
//  EuropeanCuisineServer
//
//  Created by Aesmond on 17/10/2026.
//  Copyright © 2026 Aesmond. All rights reserved.
//

import Fluent
import Vapor

struct ReservationController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let api = routes.grouped("api", "v0")

        // Authenticated routes
        let authReservations = api
            .grouped("reservations")
            .authenticated()
        authReservations.get(use: list)
        authReservations.post(use: create)
        authReservations.patch("cancel", use: authCancel)
        authReservations.get("is-reserved", use: isReserved)
        authReservations.get("are-reserved-list", use: areReservedList)

        authReservations.group(":id") { reservation in
            reservation.delete(use: cancel)
        }

        // Admin routes: User is Staff or Admin
        let adminReservations = api.grouped("admin", "reservations")
            .requiring(.admin, .staff)
        adminReservations.get(use: adminTableList)

        adminReservations.group(":id") { reservation in
            reservation.get(use: adminShow)
            reservation.patch(use: adminUpdate)
        }
    }

    private func list(req: Request) async throws -> [ReservationOutput] {
        let user = try req.auth.require(User.self)
        let userID = try user.requireID()

        let reservations = try await Reservation
            .query(on: req.db)
            .filter(\.$user.$id == userID)
            .filter(\.$status == .confirmed)
            .all()

        var outputs: [ReservationOutput] = []

        for reservation in reservations {
            try await reservation.$workshop.load(on: req.db)

            let workshop = reservation.workshop

            try await workshop.$infos.load(on: req.db)
            try await workshop.$category.load(on: req.db)

            guard let infos = workshop.infos else {
                continue
            }

            let bookedCapacity = try await calculateBookedCapacity(workshopID: workshop.requireID(),
                                                                   req: req)

            let output = try ReservationOutput(reservation: reservation,
                                               workshop: workshop,
                                               infos: infos, bookedCapacity: bookedCapacity)
            outputs.append(output)
        }

        return outputs
    }

    private func adminTableList(req: Request) async throws -> Page<AdminReservationListItemOutput> {
        let input = try req.query.decode(AdminReservationListSortSearchInput.self)

        let query = Reservation.query(on: req.db)
            .join(Workshop.self, on: \Reservation.$workshop.$id == \Workshop.$id)
            .join(Category.self, on: \Workshop.$category.$id == \Category.$id)
            .join(WorkshopInfos.self, on: \WorkshopInfos.$workshop.$id == \Workshop.$id)
            .join(User.self, on: \Reservation.$user.$id == \User.$id)
            .with(\.$workshop) { workshop in
                workshop
                    .with(\.$infos)
                    .with(\.$category)
            }
            .with(\.$user)
            .with(\.$user) { user in
                user.with(\.$infos)
            }

        if let searchText = input.query,
           searchText.trimmed.isNotEmpty {
            query
                .group(.or) { group in
                    group.filter(Workshop.self,
                                 \.$name ~~ searchText.trimmed)
                    group.filter(User.self,
                                 \.$name ~~ searchText.trimmed)
                }
        }

        if let status = input.status {
            switch status {
            case .confirmed:
                query.filter(\.$status == .confirmed)
            case .pending:
                query.filter(\.$status == .pending)
            case .cancelled:
                query.filter(\.$status == .cancelled)
            }
        }

        if let sort = input.sort {
            switch sort {
            case .name:
                query
                    .sort(Workshop.self, \.$name, .ascending)
                    .sort(User.self, \.$name, .ascending)
            case .category:
                query
                    .sort(Category.self, \.$name, .ascending)
                    .sort(Workshop.self, \.$name, .ascending)
                    .sort(User.self, \.$name, .ascending)
            case .date:
                query
                    .sort(Workshop.self, \.$startTime, .ascending)
                    .sort(User.self, \.$name, .ascending)
            }
        } else {
            query
                .sort(Workshop.self, \.$name, .ascending)
                .sort(User.self, \.$name, .ascending)
        }

        let page = try await query.paginate(for: req)

        var items: [AdminReservationListItemOutput] = []

        for reservation in page.items {
            let workshop = reservation.workshop
            let user = reservation.user

            guard let infos = workshop.infos else {
                continue
            }

            try items.append(AdminReservationListItemOutput(reservation: reservation,
                                                            workshop: workshop,
                                                            infos: infos,
                                                            user: user))
        }

        return Page(items: items,
                    metadata: page.metadata)
    }

    private func adminShow(req: Request) async throws -> AdminReservationEditOutput {
        let reservationID = try req.parameters.require("id", as: UUID.self)

        guard let reservation = try await Reservation
            .query(on: req.db)
            .filter(\.$id == reservationID)
            .first()
        else {
            throw ReservationError.notFound
        }

        try await reservation.$workshop.load(on: req.db)
        try await reservation.$user.load(on: req.db)

        let workshop = reservation.workshop

        try await workshop.$category.load(on: req.db)

        return AdminReservationEditOutput(reservation: reservation,
                                          workshop: reservation.workshop,
                                          user: reservation.user)
    }

    private func adminUpdate(req: Request) async throws -> HTTPStatus {
        let reservationID = try req.parameters.require("id", as: UUID.self)
        let input = try req.content.decode(AdminUpdateReservationInput.self)

        guard let reservation = try await Reservation
            .query(on: req.db)
            .filter(\.$id == reservationID)
            .first()
        else {
            throw ReservationError.notFound
        }

        reservation.status = input.status
        try await reservation.update(on: req.db)

        return .noContent
    }

    private func isReserved(req: Request) async throws -> IsReservedWorkshopOutput {
        let userID = try req.auth.require(User.self).requireID()
        let input = try req.query.decode(IsReservedWorkshopInput.self)

        if try await Reservation.query(on: req.db)
            .filter(\.$user.$id == userID)
            .filter(\.$workshop.$id == input.workshopID)
            .filter(\.$status == .confirmed)
            .first() != nil {
            return IsReservedWorkshopOutput(isReserved: true)
        } else {
            return IsReservedWorkshopOutput(isReserved: false)
        }
    }

    private func areReservedList(req: Request) async throws -> AreReservedListWorkshopOutput {
        let userID = try req.auth.require(User.self).requireID()
        let input = try req.query.decode(AreReservedListWorkshopInput.self)

        guard input.workshopIDs.isNotEmpty else {
            return AreReservedListWorkshopOutput(reservedWorkshopIDs: [])
        }

        let reservations = try await Reservation.query(on: req.db)
            .filter(\.$user.$id == userID)
            .filter(\.$workshop.$id ~~ input.workshopIDs)
            .filter(\.$status == .confirmed)
            .all()

        return AreReservedListWorkshopOutput(reservedWorkshopIDs: reservations.map(\.$workshop.id))
    }

    private func authCancel(req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        let userID = try user.requireID()

        let input = try req.query.decode(CancelReservationInput.self)

        guard let reservation = try await Reservation
            .query(on: req.db)
            .filter(\.$user.$id == userID)
            .filter(\.$workshop.$id == input.workshopID)
            .first() else {
            throw ReservationError.notFound
        }

        guard reservation.status != .cancelled else {
            throw ReservationError.invalidStatus
        }

        reservation.status = .cancelled
        try await reservation.update(on: req.db)

        return .noContent
    }

    private func create(req: Request) async throws -> Response {
        let user = try req.auth.require(User.self)
        let userID = try user.requireID()

        let input = try req.content.decode(ReservationInput.self)

        guard let workshop = try await Workshop
            .query(on: req.db)
            .filter(\.$id == input.workshopID)
            .with(\.$infos)
            .with(\.$category)
            .first()
        else {
            throw ReservationError.workshopNotFound
        }

        guard let infos = workshop.infos,
              infos.status == .published
        else {
            throw ReservationError.workshopNotAvailable
        }

        if let existingReservation = try await Reservation
            .query(on: req.db)
            .filter(\.$user.$id == userID)
            .filter(\.$workshop.$id == input.workshopID)
            .first() {
            guard existingReservation.status == .cancelled else {
                throw ReservationError.alreadyExists
            }

            let workshopReservations = try await Reservation
                .query(on: req.db)
                .filter(\.$workshop.$id == input.workshopID)
                .all()

            let activeReservations = workshopReservations.filter {
                $0.status == .confirmed
            }

            guard activeReservations.count < Int(workshop.capacityMax) else {
                throw ReservationError.workshopNotAvailable
            }

            existingReservation.status = .confirmed
            try await existingReservation.update(on: req.db)

            let bookedCapacity = try await calculateBookedCapacity(workshopID: workshop.requireID(),
                                                                   req: req)

            return try await ReservationOutput(reservation: existingReservation,
                                               workshop: workshop,
                                               infos: infos, bookedCapacity: bookedCapacity)
                .encodeResponse(status: .created, for: req)
        }

        let workshopReservations = try await Reservation
            .query(on: req.db)
            .filter(\.$workshop.$id == input.workshopID)
            .all()

        let activeReservations = workshopReservations.filter {
            $0.status == .confirmed
        }

        guard activeReservations.count < Int(workshop.capacityMax) else {
            throw ReservationError.workshopNotAvailable
        }

        let reservation = Reservation(status: .confirmed,
                                      workshopID: input.workshopID,
                                      userID: userID)

        try await reservation.create(on: req.db)

        let bookedCapacity = try await calculateBookedCapacity(workshopID: workshop.requireID(),
                                                               req: req)

        return try await ReservationOutput(reservation: reservation,
                                           workshop: workshop,
                                           infos: infos, bookedCapacity: bookedCapacity)
            .encodeResponse(status: .created, for: req)
    }

    private func cancel(req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        let userID = try user.requireID()

        let reservationID = try req.parameters.require("id", as: UUID.self)

        guard let reservation = try await Reservation
            .query(on: req.db)
            .filter(\.$id == reservationID)
            .filter(\.$user.$id == userID)
            .first()
        else {
            throw ReservationError.notFound
        }

        guard reservation.status != .cancelled else {
            throw ReservationError.invalidStatus
        }

        reservation.status = .cancelled
        try await reservation.update(on: req.db)

        return .noContent
    }

    private func calculateBookedCapacity(workshopID: UUID,
                                         req: Request) async throws -> UInt16 {
        let count = try await Reservation
            .query(on: req.db)
            .filter(\.$workshop.$id == workshopID)
            .group(.or) { group in
                group.filter(\.$status == .confirmed)
                group.filter(\.$status == .pending)
            }
            .count()

        guard count <= Int(UInt16.max) else {
            return 0
        }

        return UInt16(count)
    }
}

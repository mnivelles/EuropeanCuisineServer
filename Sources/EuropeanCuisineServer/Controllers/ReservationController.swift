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
        let reservations = routes
            .authenticated()
            .grouped("api", "v0", "reservations")

        reservations.get(use: list)
        reservations.post(use: create)

        reservations.group(":id") { reservation in
            reservation.delete(use: cancel)
        }
    }

    private func list(req: Request) async throws -> [ReservationOutput] {
        let user = try req.auth.require(User.self)
        let userID = try user.requireID()

        let reservations = try await Reservation
            .query(on: req.db)
            .filter(\.$user.$id == userID)
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
                $0.status == .confirmed || $0.status == .pending
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
                .encodeResponse(status: .ok, for: req)
        }

        let workshopReservations = try await Reservation
            .query(on: req.db)
            .filter(\.$workshop.$id == input.workshopID)
            .all()

        let activeReservations = workshopReservations.filter {
            $0.status == .confirmed || $0.status == .pending
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

    private func calculateBookedCapacity(workshopID: UUID,
                                         req: Request) async throws -> UInt16 {
        let reservations = try await Reservation
            .query(on: req.db)
            .filter(\.$workshop.$id == workshopID)
            .all()

        let activeReservations = reservations.filter {
            $0.status == .confirmed || $0.status == .pending
        }

        return UInt16(activeReservations.count)
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
}

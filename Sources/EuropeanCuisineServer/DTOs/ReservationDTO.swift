//
//  ReservationDTO.swift
//  EuropeanCuisineServer
//
//  Created by Aesmond on 17/10/2026.
//  Copyright © 2026 Aesmond. All rights reserved.
//

import Fluent
import Vapor

struct ReservationInput: Content {
    let workshopID: UUID
}

struct ReservationOutput: Content {
    let id: UUID
    let status: Reservation.Status
    let workshop: WorkshopOutput
}

extension ReservationOutput {
    init(reservation: Reservation, workshop: Workshop, infos: WorkshopInfos,
         bookedCapacity: UInt16) throws {
        self.id = try reservation.requireID()
        self.status = reservation.status
        self.workshop = try WorkshopOutput(workshop: workshop,
                                           infos: infos, bookedCapacity: bookedCapacity)
    }
}

struct AdminReservationListItemOutput: Content {
    let workshop: String
    let category: String
    let date: String
    let startTime: String
    let endTime: String
    let userName: String
    let status: Reservation.Status
}

extension AdminReservationListItemOutput {
    init(reservation: Reservation, workshop: Workshop, infos: WorkshopInfos,
         user: User) throws {
        let locale = Locale(identifier: "en")
        let dateFormat = Date.FormatStyle(date: .numeric, time: .omitted, locale: locale)
        let timeFormat = Date.FormatStyle(date: .omitted, time: .shortened, locale: locale)

        self.workshop = workshop.name
        self.category = workshop.category.name
        self.date = workshop.startTime.formatted(dateFormat)
        self.startTime = workshop.startTime.formatted(timeFormat)
        self.endTime = workshop.endTime.formatted(timeFormat)
        self.userName = user.name
        self.status = reservation.status
    }
}

struct AdminReservationListSortSearchInput: Content {
    let query: String?
    let sort: Sort?

    enum Sort: String, Codable {
        case name
        case category
        case date
    }
}

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

struct IsReservedWorkshopInput: Content {
    let workshopID: UUID
}

struct IsReservedWorkshopOutput: Content {
    let isReserved: Bool
}

struct AreReservedListWorkshopInput: Content {
    let workshopIDs: [UUID]
}

struct AreReservedListWorkshopOutput: Content {
    let reservedWorkshopIDs: [UUID]
}

struct CancelReservationInput: Content {
    let workshopID: UUID
}

struct AdminReservationListItemOutput: Content {
    let id: UUID
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

        self.id = try reservation.requireID()
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
    let status: Status?

    enum Sort: String, Codable {
        case name
        case category
        case date
    }

    enum Status: String, Codable {
        case confirmed
        case pending
        case cancelled
    }

    enum CodingKeys: String, CodingKey {
        case query, sort, status
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.query = try container.decodeIfNotEmpty(String.self, forKey: .query)
        self.sort = try container.decodeIfNotEmpty(Sort.self, forKey: .sort)
        self.status = try container.decodeIfNotEmpty(Status.self, forKey: .status)
    }
}

struct AdminWorkshopReservationListItemOutput: Content {
    let id: UUID
    let userName: String
    let userPictureURL: String?
    let status: Reservation.Status
}

extension AdminWorkshopReservationListItemOutput {
    init(reservation: Reservation, user: User) throws {
        self.id = try reservation.requireID()
        self.userName = user.name
        self.userPictureURL = user.infos?.pictureURL
        self.status = reservation.status
    }
}

struct AdminUpdateReservationInput: Content {
    let status: Reservation.Status
}

struct AdminReservationEditOutput: Content {
    let status: Reservation.Status

    let workshop: WorkshopDetails
    let user: UserDetails

    struct WorkshopDetails: Content {
        let name: String
        let category: String
        let date: String
        let startTime: String
        let endTime: String
    }

    struct UserDetails: Content {
        let name: String
        let email: String
    }
}

extension AdminReservationEditOutput {
    init(reservation: Reservation,
         workshop: Workshop,
         user: User) {
        let locale = Locale(identifier: "en")
        let dateFormat = Date.FormatStyle(date: .complete,
                                          time: .omitted,
                                          locale: locale)
        let timeFormat = Date.FormatStyle(date: .omitted,
                                          time: .shortened,
                                          locale: locale)

        self.status = reservation.status

        self.workshop = WorkshopDetails(name: workshop.name,
                                        category: workshop.category.name,
                                        date: workshop.startTime.formatted(dateFormat),
                                        startTime: workshop.startTime.formatted(timeFormat),
                                        endTime: workshop.endTime.formatted(timeFormat))

        self.user = UserDetails(name: user.name,
                                email: user.email)
    }
}

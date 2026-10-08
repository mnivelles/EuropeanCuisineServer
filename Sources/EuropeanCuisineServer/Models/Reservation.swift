//
//  Reservation.swift
//  EuropeanCuisineServer
//
//  Created by Aesmond on 01/10/2026.
//  Copyright © 2026 Aesmond. All rights reserved.
//

import Fluent
import Vapor

final class Reservation: Model, @unchecked Sendable {
    static let schema: String = "reservations"

    @ID(key: .id)
    var id: UUID?

    @Enum(key: "status")
    var status: Reservation.Status

    @Parent(key: "workshop_id")
    var workshop: Workshop

    @Parent(key: "user_id")
    var user: User

    init() {}

    init(id: UUID? = nil,
         status: Reservation.Status,
         workshopID: Workshop.IDValue,
         userID: User.IDValue) {
        self.id = id
        self.status = status
        $workshop.id = workshopID
        $user.id = userID
    }
}

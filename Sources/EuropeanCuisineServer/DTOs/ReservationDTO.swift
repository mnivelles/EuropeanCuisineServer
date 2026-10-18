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
    init(reservation: Reservation, workshop: Workshop, infos: WorkshopInfos) throws {
        self.id = try reservation.requireID()
        self.status = reservation.status
        self.workshop = try WorkshopOutput(workshop: workshop,
                                           infos: infos)
    }
}

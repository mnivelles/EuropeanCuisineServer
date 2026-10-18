//
//  ReservationError.swift
//  EuropeanCuisineServer
//
//  Created by Aesmond on 17/10/2026.
//  Copyright © 2026 Aesmond. All rights reserved.
//

import Vapor

enum ReservationError: AbortError {
    case notFound
    case workshopNotFound
    case workshopNotAvailable
    case alreadyExists
    case invalidStatus

    var status: HTTPResponseStatus {
        switch self {
        case .notFound:
            .notFound
        case .workshopNotFound:
            .notFound
        case .workshopNotAvailable:
            .conflict
        case .alreadyExists:
            .conflict
        case .invalidStatus:
            .badRequest
        }
    }

    var reason: String {
        switch self {
        case .notFound:
            "Reservation not found."
        case .workshopNotFound:
            "Workshop not found."
        case .workshopNotAvailable:
            "Workshop is not available for reservation."
        case .alreadyExists:
            "A reservation already exists for this workshop."
        case .invalidStatus:
            "The reservation status does not allow this operation."
        }
    }
}

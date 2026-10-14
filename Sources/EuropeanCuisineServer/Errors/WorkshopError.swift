//
//  WorkshopError.swift
//  EuropeanCuisineServer
//
//  Created by Aesmond on 08/10/2026.
//  Copyright © 2026 Aesmond. All rights reserved.
//

import Vapor

enum WorkshopError: AbortError {
    case notFound
    case invalidTimeOrder
    case infosNotFound

    var status: HTTPResponseStatus {
        switch self {
        case .notFound:
            .notFound
        case .invalidTimeOrder:
            .unprocessableEntity
        case .infosNotFound:
            .notFound
        }
    }

    var reason: String {
        switch self {
        case .notFound:
            "Workshop not found"
        case .invalidTimeOrder:
            "EndTime must be after StartTime"
        case .infosNotFound:
            "Workshop infos not found"
        }
    }
}

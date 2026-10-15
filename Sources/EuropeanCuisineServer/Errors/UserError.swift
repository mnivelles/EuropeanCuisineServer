//
//  UserError.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 15/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Vapor

enum UserError: AbortError {
    case infosNotFound

    var status: HTTPResponseStatus {
        switch self {
        case .infosNotFound:
            .notFound
        }
    }

    var reason: String {
        switch self {
        case .infosNotFound:
            "User infos not found"
        }
    }
}

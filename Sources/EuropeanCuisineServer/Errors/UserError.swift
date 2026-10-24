//
//  UserError.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 15/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Vapor

enum UserError: AbortError {
    case notFound
    case infosNotFound
    case sameUser
    case emailAlreadyExists

    var status: HTTPResponseStatus {
        switch self {
        case .notFound:
            .notFound
        case .infosNotFound:
            .notFound
        case .sameUser:
            .conflict
        case .emailAlreadyExists:
            .conflict
        }
    }

    var reason: String {
        switch self {
        case .notFound:
            "User not found"
        case .infosNotFound:
            "User infos not found"
        case .sameUser:
            "Same user"
        case .emailAlreadyExists:
            "Email is not valid"
        }
    }
}

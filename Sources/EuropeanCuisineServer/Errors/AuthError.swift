//
//  AuthError.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 15/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Vapor

enum AuthError: AbortError {
    case passwordOrEmailFailed
    case unauthorized

    var status: HTTPResponseStatus {
        switch self {
        case .passwordOrEmailFailed:
            .badRequest
        case .unauthorized:
            .unauthorized
        }
    }

    var reason: String {
        switch self {
        case .passwordOrEmailFailed:
            "Incorrect email or password"
        case .unauthorized:
            "Invalid credentials"
        }
    }
}

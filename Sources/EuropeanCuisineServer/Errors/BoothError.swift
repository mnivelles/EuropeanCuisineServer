//
//  BoothError.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 10/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Vapor

enum BoothError: AbortError {
    case alreadyExists
    case notFound

    var status: HTTPResponseStatus {
        switch self {
        case .alreadyExists:
            .conflict
        case .notFound:
            .notFound
        }
    }

    var reason: String {
        switch self {
        case .alreadyExists:
            "A booth with this name already exists"
        case .notFound:
            "Booth not found"
        }
    }
}

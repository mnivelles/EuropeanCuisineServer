//
//  CategoryError.swift
//  EuropeanCuisineServer
//
//  Created by Aesmond on 08/10/2026.
//  Copyright © 2026 Aesmond. All rights reserved.
//

import Vapor

enum CategoryError: AbortError {
    case alreadyExists
    case notFound
    case containsWorkshops

    var status: HTTPResponseStatus {
        switch self {
        case .alreadyExists:
            .conflict
        case .notFound:
            .notFound
        case .containsWorkshops:
            .conflict
        }
    }

    var reason: String {
        switch self {
        case .alreadyExists:
            "A category with this name already exists"
        case .notFound:
            "Category not found"
        case .containsWorkshops:
            "Category cannot be deleted because it still contains workshops"
        }
    }
}

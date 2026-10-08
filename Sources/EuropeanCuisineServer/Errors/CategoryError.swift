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
            "A category with this name already exists"
        case .notFound:
            "Category not found"
        }
    }
}

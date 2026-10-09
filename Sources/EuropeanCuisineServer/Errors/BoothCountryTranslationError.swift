//
//  BoothCountryTranslationError.swift
//  EuropeanCuisineServer
//  
//  Created by Mathieu Nivelles on 09/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//  

import Vapor

enum BoothCountryTranslationError: AbortError {
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
            "A translation with this locale and countryID already exists"
        case .notFound:
            "Translation not found"
        }
    }
}

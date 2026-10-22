//
//  ImageFileError.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 22/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Vapor

enum ImageFileError: AbortError {
    case fileMaxSize(max: Int)
    case fileExtension(extensions: [String])

    var status: HTTPResponseStatus {
        switch self {
        case .fileMaxSize:
            .badRequest
        case .fileExtension:
            .badRequest
        }
    }

    var reason: String {
        switch self {
        case let .fileMaxSize(max):
            "Image size should not exceed \(Double(max) / 1_000_000.0) MB"
        case let .fileExtension(extensions):
            "Image must be \(extensions.formatted(.list(type: .or).locale(Locale(identifier: "en"))))"
        }
    }
}

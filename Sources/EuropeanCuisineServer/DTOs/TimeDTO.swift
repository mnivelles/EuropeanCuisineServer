//
//  TimeDTO.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 20/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Vapor

struct TimeOptionOutput: Content {
    let value: Date
    let label: String
}

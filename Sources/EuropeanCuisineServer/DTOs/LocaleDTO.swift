//
//  LocaleDTO.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 18/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Vapor

struct LocaleInput: Content {
    var locale: String?
}

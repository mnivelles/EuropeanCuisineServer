//
//  AuthenticationDTO.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 15/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Vapor

struct LoginInput: Content {
    let email: String
    let password: String
}

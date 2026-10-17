//
//  AuthenticationDTO.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 15/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Vapor

struct AuthSignupInput: Content {
    let name: String
    let email: String
    let password: String
}

extension AuthSignupInput: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name",
                        as: String.self,
                        is: Constants.User.Name.validator)
        validations.add("email",
                        as: String.self,
                        is: Constants.User.Email.validator)
        validations.add("password",
                        as: String.self,
                        is: Constants.User.Password.validator)
    }
}

struct AuthLoginInput: Content {
    let email: String
    let password: String
}

extension AuthLoginInput: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email",
                        as: String.self,
                        is: Constants.User.Email.validator)
        validations.add("password",
                        as: String.self,
                        is: Constants.User.Password.validator)
    }
}

struct TokenResponse: Content {
    let token: String
}

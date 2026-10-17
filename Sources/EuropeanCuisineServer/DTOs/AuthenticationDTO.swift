//
//  AuthenticationDTO.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 15/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Vapor

struct AuthSignUpInput: Content {
    let name: String
    let email: String
    let password: String
}

extension AuthSignUpInput: Validatable {
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

struct AuthLogInInput: Content {
    let email: String
    let password: String
}

extension AuthLogInInput: Validatable {
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

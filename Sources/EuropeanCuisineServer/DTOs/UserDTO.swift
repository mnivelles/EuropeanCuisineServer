//
//  UserDTO.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 15/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Fluent
import Vapor

struct UserOutput: Content {
    let id: UUID
    let name: String
    let email: String
    let pictureURL: String?
}

extension UserOutput {
    init(user: User, infos: UserInfos) throws {
        self.id = try user.requireID()
        self.name = user.name
        self.email = user.email
        self.pictureURL = infos.pictureURL
    }
}

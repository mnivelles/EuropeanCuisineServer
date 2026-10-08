//
//  UserInfos.swift
//  EuropeanCuisineServer
//
//  Created by Aesmond on 07/10/2026.
//  Copyright © 2026 Aesmond. All rights reserved.
//

import Fluent
import Vapor

final class UserInfos: Model, @unchecked Sendable {
    static let schema: String = "user_infos"

    @ID(key: .id)
    var id: UUID?

    @Enum(key: "status")
    var status: User.Status

    @OptionalField(key: "picture_url")
    var pictureURL: String?

    @Parent(key: "user_id")
    var user: User

    init() {}

    init(id: UUID? = nil,
         status: User.Status,
         pictureURL: String? = nil,
         userID: User.IDValue) {
        self.id = id
        self.status = status
        self.pictureURL = pictureURL
        $user.id = userID
    }
}

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

struct AdminUserListSortSearchInput: Content {
    let query: String?
    let sort: Sort?
    let role: User.Role?
    let status: Status?

    enum Sort: String, Codable {
        case name
        case email
        case role
        case createdAt = "created_at"
    }

    enum Status: String, Codable {
        case enabled
        case disabled
    }

    enum CodingKeys: String, CodingKey {
        case query, sort, role, status
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.query = try container.decodeIfNotEmpty(String.self, forKey: .query)
        self.sort = try container.decodeIfNotEmpty(Sort.self, forKey: .sort)
        self.role = try container.decodeIfNotEmpty(User.Role.self, forKey: .role)
        self.status = try container.decodeIfNotEmpty(Status.self, forKey: .status)
    }
}

struct AdminUserListItemOutput: Content {
    let id: UUID
    let name: String
    let email: String
    let pictureURL: String?
    let role: User.Role
    let roleName: String
    let status: User.Status
    let creationDate: String
}

extension AdminUserListItemOutput {
    init(user: User, infos: UserInfos) throws {
        let locale = Locale(identifier: "en")
        let dateFormat = Date.FormatStyle(date: .numeric, time: .shortened, locale: locale)

        self.id = try user.requireID()
        self.name = user.name
        self.email = user.email
        self.pictureURL = infos.pictureURL
        self.role = user.role
        self.roleName = user.role.name
        self.status = infos.status
        self.creationDate = user.createdAt?.formatted(dateFormat) ?? "[missing]"
    }
}

struct AdminShowUserOutput: Content {
    let id: UUID
    let name: String
    let email: String
    let pictureURL: String?
    let role: User.Role
}

extension AdminShowUserOutput {
    init(user: User, infos: UserInfos) throws {
        self.id = try user.requireID()
        self.name = user.name
        self.email = user.email
        self.pictureURL = infos.pictureURL
        self.role = user.role
    }
}

struct UserRoleOptionOutput: Content {
    let value: User.Role
    let label: String
}

struct AdminUpdateUserInput: Content {
    let name: String
    let email: String
    let role: User.Role
    let picture: File?
}

extension AdminUpdateUserInput: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name",
                        as: String.self,
                        is: Constants.User.Name.validator)
        validations.add("email",
                        as: String.self,
                        is: Constants.User.Email.validator)
    }
}

//
//  Booth.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 09/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Fluent
import Vapor

final class Booth: Model, @unchecked Sendable {
    static let schema: String = "booths"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "description")
    var description: String

    @Field(key: "picture_url")
    var pictureURL: String

    @Field(key: "location")
    var location: String

    @Field(key: "is_vegan")
    var isVegan: Bool

    @Field(key: "is_prm")
    var isPRM: Bool

    @Field(key: "is_family_friendly")
    var isFamilyFriendly: Bool

    @Enum(key: "status")
    var status: Booth.Status

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Parent(key: "country_id")
    var country: BoothCountry

    init() {}

    init(id: UUID? = nil,
         name: String,
         description: String,
         pictureURL: String,
         location: String,
         isVegan: Bool,
         isPRM: Bool,
         isFamilyFriendly: Bool,
         status: Booth.Status,
         countryID: BoothCountry.IDValue) {
        self.id = id
        self.name = name
        self.description = description
        self.pictureURL = pictureURL
        self.location = location
        self.isVegan = isVegan
        self.isPRM = isPRM
        self.isFamilyFriendly = isFamilyFriendly
        self.status = status
        $country.id = countryID
    }
}

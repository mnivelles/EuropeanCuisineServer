//
//  WorkshopInfos.swift
//  EuropeanCuisineServer
//
//  Created by Aesmond on 07/10/2026.
//  Copyright © 2026 Aesmond. All rights reserved.
//

import Fluent
import Vapor

final class WorkshopInfos: Model, @unchecked Sendable {
    static let schema: String = "workshop_infos"

    @ID(key: .id)
    var id: UUID?

    @Enum(key: "status")
    var status: Workshop.Status

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

    @Parent(key: "workshop_id")
    var workshop: Workshop

    init() {}

    init(id: UUID? = nil,
         status: Workshop.Status,
         pictureURL: String,
         location: String,
         isVegan: Bool,
         isPRM: Bool,
         isFamilyFriendly: Bool,
         workshopID: Workshop.IDValue) {
        self.id = id
        self.status = status
        self.pictureURL = pictureURL
        self.location = location
        self.isVegan = isVegan
        self.isPRM = isPRM
        self.isFamilyFriendly = isFamilyFriendly
        $workshop.id = workshopID
    }
}

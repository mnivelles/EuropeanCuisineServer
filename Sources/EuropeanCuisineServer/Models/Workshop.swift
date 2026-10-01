//
//  Workshop.swift
//  EuropeanCuisineServer
//
//  Created by Aesmond on 01/10/2026.
//  Copyright © 2026 Aesmond. All rights reserved.
//  

import Fluent
import Vapor

final class Workshop: Model, @unchecked Sendable {
    
    static let schema: String = "workshop"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "start_time")
    var startTime: Date
    
    @Field(key: "end_time")
    var endTime: Date
    
    @Field(key: "capacity_max")
    var capacityMax: UInt16
    
    @Field(key: "description")
    var description: String
    
    @Field(key: "picture_url")
    var pictureURL: String
    
    @Enum(key: "status")
    var status: Workshop.Status
    
    @Field(key: "is_vegan")
    var isVegan: Bool
    
    @Field(key: "is_prm")
    var isPRM: Bool
    
    @Field(key: "is_family_friendly")
    var isFamilyFriendly: Bool
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Parent(key: "category_id")
    var category: Category
    
    @Children(for: \.$workshop)
    var reservations: [Reservation]
    
    init() {}
    
    init(
        id: UUID? = nil,
        name: String,
        startTime: Date,
        endTime: Date,
        capacityMax: Int,
        description: String,
        pictureURL: String,
        status: Workshop.Status,
        isVegan: Bool,
        isPRM: Bool,
        isFamilyFriendly: Bool,
        categoryID: Category.IDValue
    ) {
        self.id = id
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.capacityMax = capacityMax
        self.description = description
        self.pictureURL = pictureURL
        self.status = status
        self.isVegan = isVegan
        self.isPRM = isPRM
        self.isFamilyFriendly = isFamilyFriendly
        self.$category.id = categoryID
    }
}

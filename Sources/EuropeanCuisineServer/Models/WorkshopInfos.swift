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
    
    @Parent(key: "workshop_id")
    var workshop: Workshop
    
    init() {}
    
    init(
        id: UUID? = nil,
        status: Workshop.Status,
        pictureURL: String,
        workshopID: Workshop.IDValue
    ) {
        self.id = id
        self.status = status
        self.pictureURL = pictureURL
        self.$workshop.id = workshopID
    }
}

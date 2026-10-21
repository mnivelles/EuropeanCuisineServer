//
//  WorkshopDTO.swift
//  EuropeanCuisineServer
//
//  Created by Aesmond on 08/10/2026.
//  Copyright © 2026 Aesmond. All rights reserved.
//

import Fluent
import Vapor

struct WorkshopInput: Content {
    let name: String
    let startTime: Date
    let endTime: Date
    let capacityMax: UInt16
    let description: String
    let pictureURL: String
    let location: String
    let isVegan: Bool
    let isPRM: Bool
    let isFamilyFriendly: Bool
    let categoryID: UUID
}

extension WorkshopInput {
    func toModel() -> Workshop {
        Workshop(name: name.trimmed,
                 startTime: startTime,
                 endTime: endTime,
                 capacityMax: capacityMax,
                 description: description,
                 categoryID: categoryID)
    }

    func toInfos(workshopID: UUID) -> WorkshopInfos {
        WorkshopInfos(status: .published,
                      pictureURL: pictureURL,
                      location: location,
                      isVegan: isVegan,
                      isPRM: isPRM,
                      isFamilyFriendly: isFamilyFriendly,
                      workshopID: workshopID)
    }
}

extension WorkshopInput: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name",
                        as: String.self,
                        is: Constants.Workshop.Name.validator)
        validations.add("capacityMax",
                        as: UInt16.self,
                        is: Constants.Workshop.CapacityMax.validator)
        validations.add("description",
                        as: String.self,
                        is: Constants.Workshop.Description.validator)
    }

    func validateDateOrder() throws {
        guard endTime > startTime else {
            throw WorkshopError.invalidTimeOrder
        }
    }
}

struct WorkshopOutput: Content {
    let id: UUID
    let name: String
    let startTime: Date
    let endTime: Date
    let bookedCapacity: UInt16
    let capacityMax: UInt16
    let description: String
    let pictureURL: String
    let location: String
    let isVegan: Bool
    let isPRM: Bool
    let isFamilyFriendly: Bool
    let categoryID: UUID
    let categoryName: String
}

extension WorkshopOutput {
    init(workshop: Workshop, infos: WorkshopInfos, bookedCapacity: UInt16) throws {
        self.id = try workshop.requireID()
        self.name = workshop.name
        self.startTime = workshop.startTime
        self.endTime = workshop.endTime
        self.bookedCapacity = bookedCapacity
        self.capacityMax = workshop.capacityMax
        self.description = workshop.description
        self.pictureURL = infos.pictureURL
        self.location = infos.location
        self.isVegan = infos.isVegan
        self.isPRM = infos.isPRM
        self.isFamilyFriendly = infos.isFamilyFriendly
        self.categoryID = try workshop.category.requireID()
        self.categoryName = workshop.category.name
    }
}

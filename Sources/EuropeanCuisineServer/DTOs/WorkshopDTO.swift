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
    let categoryID: UUID
}

extension WorkshopInput {
    
    func toModel() -> Workshop {
        let workshop = Workshop(
            name: name,
            startTime: startTime,
            endTime: endTime,
            capacityMax: capacityMax,
            description: description
        )
        workshop.$category.id = categoryID
        
        return workshop
    }
}

extension WorkshopInput: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: .count(1 ... 100))
        validations.add("capacityMax", as: UInt16.self, is: .range(1 ... 60000))
        validations.add("description", as: String.self, is: .count(1 ... 1000))
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
    let capacityMax: UInt16
    let description: String
//    let isVegan: Bool
//    let isPRM: Bool
//    let isFamilyFriendly: Bool
}

extension WorkshopOutput {
    init(_ workshop: Workshop) throws {
        self.id = try workshop.requireID()
        self.name = workshop.name
        self.startTime = workshop.startTime
        self.endTime = workshop.endTime
        self.capacityMax = workshop.capacityMax
        self.description = workshop.description
//        self.isVegan = workshop.isVegan
//        self.isPRM = workshop.isPRM
//        self.isFamilyFriendly = workshop.isFamilyFriendly
    }
}

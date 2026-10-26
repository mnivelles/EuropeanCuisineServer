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

struct AdminWorkshopListItemOutput: Content {
    let id: UUID
    let status: Workshop.Status
    let pictureURL: String
    let name: String
    let category: String
    let location: String
    let date: String
    let startTime: String
    let endTime: String
    let capacity: String
    let capacityPercent: Double
}

extension AdminWorkshopListItemOutput {
    init(workshop: Workshop, infos: WorkshopInfos, bookedCapacity: UInt16) throws {
        let locale = Locale(identifier: "en")
        let dateFormat = Date.FormatStyle(date: .numeric, time: .omitted, locale: locale)
        let timeFormat = Date.FormatStyle(date: .omitted, time: .shortened, locale: locale)
        self.id = try workshop.requireID()
        self.status = infos.status
        self.pictureURL = infos.pictureURL
        self.name = workshop.name
        self.category = workshop.category.name
        self.location = infos.location
        self.date = workshop.startTime.formatted(dateFormat)
        self.startTime = workshop.startTime.formatted(timeFormat)
        self.endTime = workshop.endTime.formatted(timeFormat)
        self.capacity = "\(bookedCapacity)/\(workshop.capacityMax)"
        self.capacityPercent = workshop.capacityMax != 0
            ? Double(bookedCapacity) / Double(workshop.capacityMax)
            : 0
    }
}

struct AdminWorkshopListSortSearchInput: Content {
    let query: String?
    let sort: Sort?

    enum Sort: String, Codable {
        case name
        case category
        case location
        case date
    }
}

struct AdminCreateWorkshopInput: Content {
    var picture: File
    var name: String
    var category: String
    var about: String
    var date: String
    var startTime: Date
    var endTime: Date
    var capacityMax: UInt16
    var location: String
    var isVegan: Bool
    var isPRM: Bool
    var isFamilyFriendly: Bool

    enum CodingKeys: String, CodingKey {
        case picture
        case name
        case category
        case about
        case date
        case startTime
        case endTime
        case capacityMax
        case location
        case isVegan
        case isPRM
        case isFamilyFriendly
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.picture = try container.decode(File.self, forKey: .picture)
        self.name = try container.decode(String.self, forKey: .name)
        self.category = try container.decode(String.self, forKey: .category)
        self.about = try container.decode(String.self, forKey: .about)
        self.date = try container.decode(String.self, forKey: .date)
        self.startTime = try Self.decodeISODate(from: container, forKey: .startTime)
        self.endTime = try Self.decodeISODate(from: container, forKey: .endTime)
        self.capacityMax = try container.decode(UInt16.self, forKey: .capacityMax)
        self.location = try container.decode(String.self, forKey: .location)
        self.isVegan = try container.decode(Bool.self, forKey: .isVegan)
        self.isPRM = try container.decode(Bool.self, forKey: .isPRM)
        self.isFamilyFriendly = try container.decode(Bool.self, forKey: .isFamilyFriendly)
    }

    private static func decodeISODate(from container: KeyedDecodingContainer<CodingKeys>,
                                      forKey key: CodingKeys) throws -> Date {
        let string = try container.decode(String.self, forKey: key)
        guard let date = ISO8601DateFormatter().date(from: string) else {
            throw DecodingError.dataCorruptedError(forKey: key,
                                                   in: container,
                                                   debugDescription: "\(key.stringValue) must be an ISO 8601 date (e.g. 1970-01-01T08:00:00Z)")
        }
        return date
    }
}

extension AdminCreateWorkshopInput: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name",
                        as: String.self,
                        is: Constants.Workshop.Name.validator)
        validations.add("category",
                        as: String.self,
                        is: Constants.Category.Name.validator)
        validations.add("about",
                        as: String.self,
                        is: Constants.Booth.About.validator)
        validations.add("capacityMax",
                        as: UInt16.self,
                        is: Constants.Workshop.CapacityMax.validator)
        validations.add("location",
                        as: String.self,
                        is: Constants.Booth.Location.validator)
    }
}

// extension AdminCreateWorkshopInput {
//    func toModel(status: Workshop.Status,
//                 pictureURL picture: String, bookedCapacity: UInt16,
//                 categoryID: UUID, id: UUID) -> WorkshopOutput {
//        WorkshopOutput(id: id,
//                       name: name.trimmed,
//                       startTime: startTime,
//                       endTime: endTime,
//                       bookedCapacity: bookedCapacity,
//                       capacityMax: capacityMax,
//                       description: about.trimmed,
//                       pictureURL: picture,
//                       location: location.trimmed,
//                       isVegan: isVegan,
//                       isPRM: isPRM,
//                       isFamilyFriendly: isFamilyFriendly,
//                       categoryID: categoryID,
//                       categoryName: category.trimmed
//        )
//    }
// }

extension AdminCreateWorkshopInput {
    func toModel(categoryID: UUID) -> Workshop {
        Workshop(name: name.trimmed,
                 startTime: startTime,
                 endTime: endTime,
                 capacityMax: capacityMax,
                 description: about.trimmed,
                 categoryID: categoryID)
    }

    func toInfos(workshopID: UUID, pictureURL: String) -> WorkshopInfos {
        WorkshopInfos(status: .published,
                      pictureURL: pictureURL,
                      location: location.trimmed,
                      isVegan: isVegan,
                      isPRM: isPRM,
                      isFamilyFriendly: isFamilyFriendly,
                      workshopID: workshopID)
    }
}

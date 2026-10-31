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
    let bookedCapacity: UInt16
    let totalCapacity: UInt16
}

extension AdminWorkshopListItemOutput {
    init(workshop: Workshop, infos: WorkshopInfos, bookedCapacity: UInt16) throws {
        let locale = Locale(identifier: "en")
        let dateFormat = Date.FormatStyle(date: .numeric, time: .omitted, locale: locale,
                                          timeZone: .gmt)
        let timeFormat = Date.FormatStyle(date: .omitted, time: .shortened, locale: locale,
                                          timeZone: .gmt)
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
        self.bookedCapacity = bookedCapacity
        self.totalCapacity = workshop.capacityMax
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
    var date: Date
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
        let dateString = try container.decode(String.self, forKey: .date)
        self.date = Date.parseUTCDate(dateString) ?? .distantPast

        self.startTime = try container.decodeISODate(forKey: .startTime)
        self.endTime = try container.decodeISODate(forKey: .endTime)
        self.capacityMax = try container.decode(UInt16.self, forKey: .capacityMax)
        self.location = try container.decode(String.self, forKey: .location)
        self.isVegan = try container.decode(Bool.self, forKey: .isVegan)
        self.isPRM = try container.decode(Bool.self, forKey: .isPRM)
        self.isFamilyFriendly = try container.decode(Bool.self, forKey: .isFamilyFriendly)
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

extension AdminCreateWorkshopInput {
    func toModel(categoryID: UUID) -> Workshop {
        let newStartTime = Date.combineUTC(date: date, time: startTime) ?? .distantPast
        let newEndTime = Date.combineUTC(date: date, time: endTime) ?? .distantPast
        return Workshop(name: name.trimmed,
                        startTime: newStartTime,
                        endTime: newEndTime,
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

struct AdminUpdateWorkshopInput: Content {
    var picture: File?
    var name: String
    var category: String
    var about: String
    var date: Date
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

        self.picture = try container.decodeIfPresent(File.self, forKey: .picture)
        self.name = try container.decode(String.self, forKey: .name)
        self.category = try container.decode(String.self, forKey: .category)
        self.about = try container.decode(String.self, forKey: .about)

        let dateString = try container.decode(String.self, forKey: .date)
        self.date = Date.parseUTCDate(dateString) ?? .distantPast
        self.startTime = try container.decodeISODate(forKey: .startTime)
        self.endTime = try container.decodeISODate(forKey: .endTime)
        self.capacityMax = try container.decode(UInt16.self, forKey: .capacityMax)
        self.location = try container.decode(String.self, forKey: .location)
        self.isVegan = try container.decode(Bool.self, forKey: .isVegan)
        self.isPRM = try container.decode(Bool.self, forKey: .isPRM)
        self.isFamilyFriendly = try container.decode(Bool.self, forKey: .isFamilyFriendly)
    }
}

extension AdminUpdateWorkshopInput: Validatable {
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

    func validateDateOrder() throws {
        let newStartTime = Date.combineUTC(date: date, time: startTime) ?? .distantPast
        let newEndTime = Date.combineUTC(date: date, time: endTime) ?? .distantPast

        guard newEndTime > newStartTime else {
            throw WorkshopError.invalidTimeOrder
        }
    }
}

struct AdminWorkshopCategoryListOutput: Content {
    let id: UUID
    let name: String
    let numberOfWorkshops: UInt
}

struct AdminCalendarOutput: Content {
    let items: [Item]
    let rangeTitle: String
    let metadata: Metadata
    let legends: [CategoryLegend]

    struct Metadata: Content {
        let isFirstPage: Bool
        let isLastPage: Bool
        let page: Int
    }

    struct Item: Content {
        let weekdayShort: String
        let date: String
        let events: [Event]

        struct Event: Content {
            let id: UUID
            let name: String
            let startTime: String
            let endTime: String
            let startClass: String
            let endClass: String
            let themeClass: String
        }
    }

    struct CategoryLegend: Content {
        let category: String
        let theme: String
    }
}

extension AdminCalendarOutput {
    static func make(from workshops: [Workshop],
                     categories: [Category]) throws -> [AdminCalendarOutput.Item] {
        let themes = try CalendarTheme.assign(to: categories)
        let timeZone: TimeZone = .gmt
        let locale = Locale(identifier: "en_US_POSIX")

        let calendar = calendar

        let weekdayFormatter = DateFormatter()
        weekdayFormatter.locale = locale
        weekdayFormatter.timeZone = timeZone
        weekdayFormatter.dateFormat = "EEE"

        let dayFormatter = DateFormatter()
        dayFormatter.locale = locale
        dayFormatter.timeZone = timeZone
        dayFormatter.dateFormat = "d"

        let timeFormatter = DateFormatter()
        timeFormatter.locale = locale
        timeFormatter.timeZone = timeZone

        func clock(_ date: Date) -> String {
            let format = Date.FormatStyle(date: .omitted,
                                          time: .shortened,
                                          locale: locale,
                                          timeZone: timeZone)

            return date.formatted(format)
        }

        func slotClass(_ prefix: String, _ date: Date) -> String {
            let parts = calendar.dateComponents([.hour, .minute], from: date)
            return prefix + "_" + String(format: "%02d-%02d", parts.hour ?? 0, parts.minute ?? 0)
        }

        func themeClass(_ workshop: Workshop) -> String {
            themes[workshop.$category.id] ?? CalendarTheme.all[0]
        }

        let groupedByDay = Dictionary(grouping: workshops) {
            calendar.startOfDay(for: $0.startTime)
        }

        return try groupedByDay
            .sorted { $0.key < $1.key }
            .map { day, dayWorkshops in
                let events = try dayWorkshops
                    .sorted { $0.startTime < $1.startTime }
                    .map { workshop in
                        try AdminCalendarOutput.Item.Event(id: workshop.requireID(),
                                                           name: workshop.name,
                                                           startTime: clock(workshop.startTime),
                                                           endTime: clock(workshop.endTime),
                                                           startClass: slotClass("start",
                                                                                 workshop
                                                                                     .startTime),
                                                           endClass: slotClass("end",
                                                                               workshop.endTime),
                                                           themeClass: themeClass(workshop))
                    }

                return AdminCalendarOutput.Item(weekdayShort: weekdayFormatter.string(from: day),
                                                date: dayFormatter.string(from: day),
                                                events: events)
            }
    }
}

extension AdminCalendarOutput {
    private static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return calendar
    }

    static func days(from workshops: [Workshop]) -> [Date] {
        let calendar = calendar
        return Set(workshops.map { calendar.startOfDay(for: $0.startTime) }).sorted()
    }

    static func rangeTitle(for days: [Date]) -> String {
        guard let first = days.first, let last = days.last else {
            return "[error]"
        }

        let calendar = calendar
        let monthFormatter = DateFormatter()
        monthFormatter.locale = Locale(identifier: "en_US_POSIX")
        monthFormatter.timeZone = .gmt
        monthFormatter.dateFormat = "MMMM"

        let firstMonth = monthFormatter.string(from: first)
        let lastMonth = monthFormatter.string(from: last)
        let firstDay = calendar.component(.day, from: first)
        let lastDay = calendar.component(.day, from: last)

        if firstMonth != lastMonth {
            return "\(firstMonth) \(firstDay) - \(lastMonth) \(lastDay)"
        }
        return firstDay == lastDay
            ? "\(firstMonth) \(firstDay)"
            : "\(firstMonth) \(firstDay)-\(lastDay)"
    }
}

enum CalendarTheme {
    static let all: [String] = (1 ... 7).map { "theme\($0)" }

    static func assign(to categories: [Category]) throws -> [Category.IDValue: String] {
        var themes: [Category.IDValue: String] = [:]
        for (index, category) in categories.enumerated() {
            try themes[category.requireID()] = all[index % all.count]
        }
        return themes
    }
}

extension AdminCalendarOutput {
    static func legend(for categories: [Category]) throws -> [CategoryLegend] {
        let themes = try CalendarTheme.assign(to: categories)

        return try categories.map { category in
            try CategoryLegend(category: category.name,
                               theme: themes[category.requireID()] ?? CalendarTheme.all[0])
        }
    }
}

struct AdminCalendarPaginationInput: Content {
    let page: Int?
    let per: Int?
}

struct AdminWorkshopReservationListInput: Content {
    let status: Status?

    enum Status: String, Codable {
        case confirmed
        case pending
        case cancelled
    }

    enum CodingKeys: String, CodingKey {
        case status
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.status = try container.decodeIfNotEmpty(Status.self, forKey: .status)
    }
}

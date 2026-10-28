//
//  Date+extension.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 13/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Foundation

extension Date {
    static func fromUTC(year: Int,
                        month: Int,
                        day: Int,
                        hour: Int = 0,
                        minute: Int = 0,
                        second: Int = 0,
                        calendar: Calendar = .current) -> Date {
        var calendar = calendar
        calendar.timeZone = .gmt
        return DateComponents(calendar: calendar,
                              year: year,
                              month: month,
                              day: day,
                              hour: hour,
                              minute: minute,
                              second: second).date ?? .now
    }

    static func hourMinuteUTC(hour: Int, minute: Int) -> Date {
        Date(timeIntervalSince1970: TimeInterval(hour * 3600 + minute * 60))
    }

    static func combineUTC(date: Date, time: Date) -> Date? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.gmt

        let dateParts = calendar.dateComponents([.year, .month, .day], from: date)

        let timeParts = calendar.dateComponents([.hour, .minute], from: time)

        var components = DateComponents()
        components.timeZone = calendar.timeZone
        components.year = dateParts.year
        components.month = dateParts.month
        components.day = dateParts.day
        components.hour = timeParts.hour
        components.minute = timeParts.minute
        components.second = 0

        return calendar.date(from: components)
    }

    static func parseUTCDate(_ string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        formatter.timeZone = TimeZone.gmt
        return formatter.date(from: string)
    }
}

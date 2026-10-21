//
//  TimeUtils.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 20/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Foundation

enum TimeUtils {
    private static let utc = TimeZone(secondsFromGMT: 0)!

    static func getOption(for date: Date,
                          locale: String) -> TimeOptionOutput {
        TimeOptionOutput(value: date,
                         label: date.formatted(Date.FormatStyle(date: .omitted,
                                                                time: .shortened,
                                                                locale: .init(identifier: locale),
                                                                timeZone: utc)))
    }

    static func getOptions(fromHour startHour: Int = 8,
                           toHour endHour: Int = 18,
                           intervalMinutes: Int = 15,
                           locale: String) -> [TimeOptionOutput] {
        stride(from: startHour * 60, through: endHour * 60, by: intervalMinutes).map { minutes in
            getOption(for: Date(timeIntervalSince1970: TimeInterval(minutes * 60)),
                      locale: locale)
        }
    }
}

//
//  Date+extension.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 13/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Foundation

extension Date {
    static func from(year: Int,
                     month: Int,
                     day: Int,
                     hour: Int = 0,
                     minute: Int = 0,
                     second: Int = 0) -> Date {
        DateComponents(calendar: .current,
                       year: year,
                       month: month,
                       day: day,
                       hour: hour,
                       minute: minute,
                       second: second).date ?? .now
    }

    static func hourMinute(hour: Int, minute: Int) -> Date {
        from(year: 2001, month: 1, day: 1, hour: hour, minute: minute, second: 0)
    }
}

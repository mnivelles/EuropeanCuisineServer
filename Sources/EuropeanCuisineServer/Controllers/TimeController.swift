//
//  TimeController.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 20/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Vapor

struct TimeController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let times = routes.grouped("api", "v0", "times")

        times.get("options", use: options)
    }

    private func options(req: Request) -> [TimeOptionOutput] {
        let locale = LocalizationUtils.getLocale(req: req)

        return TimeUtils.getOptions(fromHour: Constants.OpeningHours.startHour,
                                    toHour: Constants.OpeningHours.endHour,
                                    intervalMinutes: Constants.OpeningHours.intervalMinutes,
                                    locale: locale)
    }
}

//
//  UserRoleUtils.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 20/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Foundation

enum UserRoleUtils {
    static func getOptions() -> [UserRoleOptionOutput] {
        User.Role
            .allCases
            .map {
                UserRoleOptionOutput(value: $0,
                                     label: $0.fullName)
            }
            .sorted(by: { $0.label.localizedCaseInsensitiveCompare($1.label) == .orderedAscending })
    }
}

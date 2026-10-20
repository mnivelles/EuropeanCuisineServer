//
//  AllergenUtils.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 20/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Foundation

enum AllergenUtils {
    static func getOptions() -> [AllergenOptionOutput] {
        Allergen
            .allCases
            .map {
                AllergenOptionOutput(value: $0,
                                     label: $0.name)
            }
            .sorted(by: { $0.label.localizedCaseInsensitiveCompare($1.label) == .orderedAscending })
    }
}

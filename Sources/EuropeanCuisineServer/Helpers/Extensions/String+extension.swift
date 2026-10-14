//
//  String+extension.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 14/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Foundation

extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

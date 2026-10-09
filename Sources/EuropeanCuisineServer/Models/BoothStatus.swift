//
//  BoothStatus.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 09/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

extension Booth {
    enum Status: String, Codable, CaseIterable {
        case active
        case disabled

        static let schema: String = "booth_status"
    }
}

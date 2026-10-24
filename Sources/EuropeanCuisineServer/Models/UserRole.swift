//
//  UserRole.swift
//  EuropeanCuisineServer
//
//  Created by Aesmond on 01/10/2026.
//  Copyright © 2026 Aesmond. All rights reserved.
//

extension User {
    enum Role: String, Codable, CaseIterable {
        case admin
        case staff
        case festivalGoer = "festival_goer"

        static let schema: String = "user_roles"

        var name: String {
            switch self {
            case .admin:
                "Admin"
            case .staff:
                "Staff"
            case .festivalGoer:
                "Goer"
            }
        }
    }
}

//
//  UserStatus.swift
//  EuropeanCuisineServer
//
//  Created by Aesmond on 01/10/2026.
//  Copyright © 2026 Aesmond. All rights reserved.
//

extension User {
    enum Status: String, Codable, CaseIterable {
        case active
        case disabled
        
        static let schema: String = "user_status"
    }
}

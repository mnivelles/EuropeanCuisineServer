//
//  WorkshopStatus.swift
//  EuropeanCuisineServer
//
//  Created by Aesmond on 01/10/2026.
//  Copyright © 2026 Aesmond. All rights reserved.
//

extension Workshop {
    enum Status: String, Codable, CaseIterable {
        case published
        case cancelled
    }
}

//
//  ReservationStatus.swift
//  EuropeanCuisineServer
//
//  Created by Aesmond on 01/10/2026.
//  Copyright © 2026 Aesmond. All rights reserved.
//

extension Reservation {
    enum Status: String, Codable, CaseIterable {
        case confirmed
        case pending
        case cancelled
        
        static let schema: String = "reservation_status"
    }
}

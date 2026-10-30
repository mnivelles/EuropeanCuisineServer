//
//  BoothControllerTests.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 30/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

@testable import EuropeanCuisineServer
import Testing
import VaporTesting

@Suite("Booth routes")
struct BoothControllerTests {
    @Suite("Public routes")
    struct Public {
        @Suite("GET /api/v0/booths")
        struct List {
            @Test
            func `The list is empty at the start`() async throws {
                try await withApp(configure: configure) { app in
                    try await app.testing().test(.GET, "api/v0/booths") { res in
                        #expect(res.status == .ok)

                        let booths = try res.content.decode([BoothOutput].self)

                        #expect(booths.isEmpty)
                    }
                }
            }
        }
    }

    @Suite("Staff & Admin routes")
    struct AdminStaff {}
}

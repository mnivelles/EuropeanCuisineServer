@testable import EuropeanCuisineServer
import Fluent
import Testing
import VaporTesting

@Suite("BoothCountry routes")
struct BoothCountryControllerTests {
    @Suite("GET /api/v0/booth-countries")
    struct List {
        @Test
        func `The list is empty at the start`() async throws {
            try await withApp(configure: configure) { app in
                try await app.testing().test(.GET, "api/v0/booth-countries") { res in
                    #expect(res.status == .ok)

                    let countries = try res.content.decode([BoothCountryOutput].self)

                    #expect(countries.isEmpty)
                }
            }
        }

        @Test
        func `The list contains added countries`() async throws {
            try await withApp(configure: configure) { app in
                let france = BoothCountry(code: "FRA")
                try await france.create(on: app.db)

                let japan = BoothCountry(code: "JPN")
                try await japan.create(on: app.db)

                let spain = BoothCountry(code: "ESP")
                try await spain.create(on: app.db)

                let southKorea = BoothCountry(code: "KOR")
                try await southKorea.create(on: app.db)

                try await app.testing().test(.GET, "api/v0/booth-countries") { res in
                    #expect(res.status == .ok)

                    let countries = try res.content.decode([BoothCountryOutput].self)
                    let codes = countries.map(\.code)

                    #expect(countries.count == 4)

                    #expect(codes.contains(france.code))
                    #expect(codes.contains(japan.code))
                    #expect(codes.contains(spain.code))
                    #expect(codes.contains(southKorea.code))

                    let ids = countries.map(\.id)

                    #expect(try ids.contains(france.requireID()))
                    #expect(try ids.contains(japan.requireID()))
                    #expect(try ids.contains(spain.requireID()))
                    #expect(try ids.contains(southKorea.requireID()))
                }
            }
        }
    }

    @Suite("POST /api/v0/booth-countries")
    struct Create {
        @Test
        func `Create country then return country with .create (201)`() async throws {
            try await withApp(configure: configure) { app in
                let input = BoothCountryInput(code: "JPN")

                try await app.testing()
                    .test(.POST, "api/v0/booth-countries", beforeRequest: { req in
                        try req.content.encode(input)
                    }, afterResponse: { res in
                        #expect(res.status == .created)

                        let country = try res.content.decode(BoothCountryOutput.self)

                        #expect(country.code == input.code)
                        #expect(country.name == "No country name")

                        let found = try #require(try await BoothCountry.find(country.id,
                                                                             on: app.db))

                        #expect(found.code == input.code)
                    })
            }
        }

        @Test
        func `Throw error when a country with same code already exists`() async throws {
            try await withApp(configure: configure) { app in
                let southKorea = BoothCountry(code: "KOR")
                try await southKorea.create(on: app.db)

                let input = BoothCountryInput(code: "KOR")

                let expected = BoothCountryError.alreadyExists
                try await app.testing().test(.POST, "api/v0/booth-countries",
                                             beforeRequest: { req in
                                                 try req.content.encode(input)
                                             }) { res in
                    #expect(res.status == expected.status)

                    let body = try res.content.decode(ErrorBody.self)

                    #expect(body.error == true)
                    #expect(body.reason == expected.reason)
                }
            }
        }

        @Test(arguments: ["INVALID", "es", "Portugal", "", "  \t", "--"])
        func `A invalid code return status .badRequest (400)`(code: String) async throws {
            let input = BoothCountryInput(code: code)

            try await withApp(configure: configure) { app in
                try await app.testing().test(.POST, "api/v0/booth-countries",
                                             beforeRequest: { req in
                                                 try req.content.encode(input)
                                             }) { res in
                    #expect(res.status == .badRequest)

                    let body = try res.content.decode(ErrorBody.self)
                    #expect(body.reason.contains("code"))
                }
            }
        }
    }

    @Suite("GET /api/v0/booth-countries/{id}")
    struct Show {
        @Test
        func `Show country`() async throws {
            try await withApp(configure: configure) { app in
                let portugal = BoothCountry(code: "PRT")
                try await portugal.create(on: app.db)

                try await app.testing()
                    .test(.GET, "api/v0/booth-countries/\(portugal.id!)") { res in
                        #expect(res.status == .ok)

                        let found = try res.content.decode(BoothCountryOutput.self)

                        #expect(found.id == portugal.id)
                        #expect(found.code == portugal.code)
                        #expect(found.name == "No country name")
                    }
            }
        }
    }

    @Suite("PUT /api/v0/booth-countries/{id}")
    struct Update {
        @Test
        func `Update country`() async throws {
            try await withApp(configure: configure) { app in
                let country = BoothCountry(code: "ARG")
                try await country.create(on: app.db)

                let input = BoothCountryInput(code: "FRA")

                try await app.testing().test(.PUT, "api/v0/booth-countries/\(country.id!)",
                                             beforeRequest: { req in
                                                 try req.content.encode(input)
                                             }, afterResponse: { res in
                                                 #expect(res.status == .ok)

                                                 let updated = try res.content
                                                     .decode(BoothCountryOutput.self)

                                                 #expect(updated.code == input.code)
                                                 #expect(updated.name == "No country name")
                                             })

                let updated = try #require(try await BoothCountry.find(country.id!,
                                                                       on: app.db))

                #expect(updated.code == input.code)
            }
        }
    }

    @Suite("DELETE /api/v0/booth-countries/{id}")
    struct Delete {
        @Test
        func `Delete country`() async throws {
            try await withApp(configure: configure) { app in
                let spain = BoothCountry(code: "ESP")
                try await spain.create(on: app.db)

                try await app.testing()
                    .test(.DELETE, "api/v0/booth-countries/\(spain.id!)") { res in
                        #expect(res.status == .noContent)
                    }

                let expected = BoothCountryError.notFound
                try await app.testing()
                    .test(.DELETE, "api/v0/booth-countries/\(spain.id!)") { res in
                        #expect(res.status == .notFound)

                        let body = try res.content.decode(ErrorBody.self)

                        #expect(body.error == true)
                        #expect(body.reason == expected.reason)
                    }
            }
        }
    }
}

fileprivate struct ErrorBody: Content {
    let error: Bool
    let reason: String
}

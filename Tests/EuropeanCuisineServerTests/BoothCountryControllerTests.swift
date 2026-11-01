@testable import EuropeanCuisineServer
import Fluent
import Testing
import VaporTesting

@Suite("BoothCountry routes")
struct BoothCountryControllerTests {
    @Suite("GET /api/v0/admin/booth-countries")
    struct List {
        @Test
        func `the list is empty at the start`() async throws {
            try await withApp(configure: configure) { app in
                let token = try await makeToken(app: app,
                                                role: .staff)

                try await app.testing().test(.GET,
                                             "api/v0/admin/booth-countries",
                                             headers: [
                                                 "Authorization": "Bearer \(token)",
                                             ]) { res in
                    #expect(res.status == .ok)

                    let countries = try res.content.decode([BoothCountryOutput].self)

                    #expect(countries.isEmpty)
                }
            }
        }

        @Test
        func `the list contains added countries`() async throws {
            try await withApp(configure: configure) { app in
                let france = BoothCountry(code: "FRA")

                let japan = BoothCountry(code: "JPN")

                let spain = BoothCountry(code: "ESP")

                let southKorea = BoothCountry(code: "KOR")

                try await [france, japan, spain, southKorea].create(on: app.db)

                let token = try await makeToken(app: app,
                                                role: .staff)

                try await app.testing().test(.GET,
                                             "api/v0/admin/booth-countries",
                                             headers: [
                                                 "Authorization": "Bearer \(token)",
                                             ]) { res in
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

    @Suite("POST /api/v0/admin/booth-countries")
    struct Create {
        @Test
        func `create country then return country with .create (201)`() async throws {
            try await withApp(configure: configure) { app in
                let input = BoothCountryInput(code: "JPN")

                let token = try await makeToken(app: app,
                                                role: .staff)

                try await app.testing()
                    .test(.POST,
                          "api/v0/admin/booth-countries",
                          headers: [
                              "Authorization": "Bearer \(token)",
                          ],
                          beforeRequest: { req in
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
        func `throw error when a country with same code already exists`() async throws {
            try await withApp(configure: configure) { app in
                let southKorea = BoothCountry(code: "KOR")
                try await southKorea.create(on: app.db)

                let input = BoothCountryInput(code: "KOR")

                let expected = BoothCountryError.alreadyExists

                let token = try await makeToken(app: app,
                                                role: .staff)

                try await app.testing().test(.POST,
                                             "api/v0/admin/booth-countries",
                                             headers: [
                                                 "Authorization": "Bearer \(token)",
                                             ],
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
        func `a invalid code return status .badRequest (400)`(code: String) async throws {
            let input = BoothCountryInput(code: code)

            try await withApp(configure: configure) { app in
                let token = try await makeToken(app: app,
                                                role: .staff)

                try await app.testing().test(.POST,
                                             "api/v0/admin/booth-countries",
                                             headers: [
                                                 "Authorization": "Bearer \(token)",
                                             ],
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

    @Suite("GET /api/v0/admin/booth-countries/{id}")
    struct Show {
        @Test
        func `show country`() async throws {
            try await withApp(configure: configure) { app in
                let portugal = BoothCountry(code: "PRT")
                try await portugal.create(on: app.db)

                let token = try await makeToken(app: app,
                                                role: .staff)

                try await app.testing()
                    .test(.GET,
                          "api/v0/admin/booth-countries/\(portugal.id!)",
                          headers: [
                              "Authorization": "Bearer \(token)",
                          ]) { res in
                        #expect(res.status == .ok)

                        let found = try res.content.decode(BoothCountryOutput.self)

                        #expect(found.id == portugal.id)
                        #expect(found.code == portugal.code)
                        #expect(found.name == "No country name")
                    }
            }
        }
    }

    @Suite("PUT /api/v0/admin/booth-countries/{id}")
    struct Update {
        @Test
        func `update country`() async throws {
            try await withApp(configure: configure) { app in
                let country = BoothCountry(code: "ARG")
                try await country.create(on: app.db)

                let input = BoothCountryInput(code: "FRA")

                let token = try await makeToken(app: app,
                                                role: .staff)

                try await app.testing().test(.PUT,
                                             "api/v0/admin/booth-countries/\(country.id!)",
                                             headers: [
                                                 "Authorization": "Bearer \(token)",
                                             ],
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

        @Test(arguments: ["INVALID", "es", "Portugal", "", "  \t", "--"])
        func `a invalid code return status .badRequest (400)`(code: String) async throws {
            try await withApp(configure: configure) { app in
                let country = BoothCountry(code: "BRA")
                try await country.create(on: app.db)

                let input = BoothCountryInput(code: code)

                let token = try await makeToken(app: app,
                                                role: .staff)

                try await app.testing().test(.PUT,
                                             "api/v0/admin/booth-countries/\(country.id!)",
                                             headers: [
                                                 "Authorization": "Bearer \(token)",
                                             ],
                                             beforeRequest: { req in
                                                 try req.content.encode(input)
                                             }, afterResponse: { res in
                                                 #expect(res.status == .badRequest)

                                                 let body = try res.content.decode(ErrorBody.self)
                                                 #expect(body.reason.contains("code"))
                                             })

                let notUpdated = try #require(try await BoothCountry.find(country.id!,
                                                                          on: app.db))

                #expect(notUpdated.code == country.code)
            }
        }
    }

    @Suite("DELETE /api/v0/admin/booth-countries/{id}")
    struct Delete {
        @Test
        func `delete country`() async throws {
            try await withApp(configure: configure) { app in
                let spain = BoothCountry(code: "ESP")
                try await spain.create(on: app.db)

                let token = try await makeToken(app: app,
                                                role: .staff)

                try await app.testing()
                    .test(.DELETE,
                          "api/v0/admin/booth-countries/\(spain.id!)",
                          headers: [
                              "Authorization": "Bearer \(token)",
                          ]) { res in
                        #expect(res.status == .noContent)
                    }

                let expected = BoothCountryError.notFound
                try await app.testing()
                    .test(.DELETE,
                          "api/v0/admin/booth-countries/\(spain.id!)",
                          headers: [
                              "Authorization": "Bearer \(token)",
                          ]) { res in
                        #expect(res.status == .notFound)

                        let body = try res.content.decode(ErrorBody.self)

                        #expect(body.error == true)
                        #expect(body.reason == expected.reason)
                    }
            }
        }
    }
}

fileprivate func addUser(app: Application,
                         name: String = "Tarō Yamada",
                         email: String = "taro@yamada.jp",
                         password: String = "secure-password-@1",
                         role: User.Role) async throws -> User {
    let user = try User(name: name,
                        email: email,
                        passwordHash: Bcrypt.hash(password, cost: 4),
                        role: .staff)
    try await user.create(on: app.db)

    let infos = try UserInfos(status: .active,
                              pictureURL: nil,
                              userID: user.requireID())

    try await infos.create(on: app.db)

    return user
}

fileprivate func makeToken(app: Application,
                           role: User.Role) async throws -> String {
    let name = "Juan Velaz"
    let email = "juan@velaz.es"
    let password = "user-secure-password-0"
    let _ = try await addUser(app: app,
                              name: name,
                              email: email,
                              password: password,
                              role: role)

    let logInInput = AuthLogInInput(email: email,
                                    password: password)
    var token = ""
    try await app.testing().test(.POST, "api/v0/auth/log-in",
                                 beforeRequest: { req in
                                     try req.content.encode(logInInput)
                                 }) { res in
        #expect(res.status == .ok)
        token = try res.content.decode(LogInOutput.self).token
    }
    return token
}

fileprivate struct ErrorBody: Content {
    let error: Bool
    let reason: String
}

@testable import EuropeanCuisineServer
import Fluent
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

            @Test
            func `The list contains added booths`() async throws {
                try await withApp(configure: configure) { app in
                    let france = try await addBoothCountry(app: app, code: "FRA", name: "France")
                    let franceID = try france.requireID()

                    let booth1 = Booth(name: "Quis Nobis Quod",
                                       about: "Sapiente Aut Est Omnis",
                                       pictureURL: "https://picsum.photos/800",
                                       location: "Tenetur Nulla",
                                       isVegan: false,
                                       isPRM: true,
                                       isFamilyFriendly: true,
                                       allergens: [.celery, .mustard],
                                       startTime: .now,
                                       endTime: .now,
                                       status: .active,
                                       countryID: franceID)

                    let booth2 = Booth(name: "Aspernatur Quaerat Voluptate Aspernatur",
                                       about: "Doloribus Animi Sed",
                                       pictureURL: "https://picsum.photos/800",
                                       location: "Voluptatum Ullam Est",
                                       isVegan: true,
                                       isPRM: false,
                                       isFamilyFriendly: true,
                                       allergens: [.fish, .crustaceans, .molluscs],
                                       startTime: .now,
                                       endTime: .now,
                                       status: .active,
                                       countryID: franceID)

                    let booth3 = Booth(name: "Quos Quisquam Accusantium",
                                       about: "Illum Tempora",
                                       pictureURL: "https://picsum.photos/800",
                                       location: "Ab Qui",
                                       isVegan: false,
                                       isPRM: false,
                                       isFamilyFriendly: true,
                                       allergens: [.nuts, .soybeans, .sesameSeeds, .peanuts],
                                       startTime: .now,
                                       endTime: .now,
                                       status: .active,
                                       countryID: franceID)

                    try await [booth1, booth2, booth3].create(on: app.db)

                    try await app.testing().test(.GET, "api/v0/booths") { res in
                        #expect(res.status == .ok)

                        let booths = try res.content.decode([BoothOutput].self)

                        #expect(booths.count == 3)

                        let names = booths.map(\.name)

                        #expect(names.contains(booth1.name))
                        #expect(names.contains(booth2.name))
                        #expect(names.contains(booth3.name))

                        let ids = booths.map(\.id)

                        #expect(ids.contains(booth1.id!))
                        #expect(ids.contains(booth2.id!))
                        #expect(ids.contains(booth3.id!))

                        // Order by name
                        #expect(ids[0] == booth2.id!)
                        #expect(ids[1] == booth1.id!)
                        #expect(ids[2] == booth3.id!)
                    }
                }
            }

            @Test
            func `The list contains only active booths`() async throws {
                try await withApp(configure: configure) { app in
                    let france = try await addBoothCountry(app: app, code: "FRA", name: "France")
                    let franceID = try france.requireID()

                    let booth1 = Booth(name: "Quis Nobis Quod",
                                       about: "Sapiente Aut Est Omnis",
                                       pictureURL: "https://picsum.photos/800",
                                       location: "Tenetur Nulla",
                                       isVegan: false,
                                       isPRM: true,
                                       isFamilyFriendly: true,
                                       allergens: [.celery, .mustard],
                                       startTime: .now,
                                       endTime: .now,
                                       status: .active,
                                       countryID: franceID)

                    let booth2 = Booth(name: "Aspernatur Quaerat Voluptate Aspernatur",
                                       about: "Doloribus Animi Sed",
                                       pictureURL: "https://picsum.photos/800",
                                       location: "Voluptatum Ullam Est",
                                       isVegan: true,
                                       isPRM: false,
                                       isFamilyFriendly: true,
                                       allergens: [.fish, .crustaceans, .molluscs],
                                       startTime: .now,
                                       endTime: .now,
                                       status: .disabled,
                                       countryID: franceID)

                    let booth3 = Booth(name: "Quos Quisquam Accusantium",
                                       about: "Illum Tempora",
                                       pictureURL: "https://picsum.photos/800",
                                       location: "Ab Qui",
                                       isVegan: false,
                                       isPRM: false,
                                       isFamilyFriendly: true,
                                       allergens: [.nuts, .soybeans, .sesameSeeds, .peanuts],
                                       startTime: .now,
                                       endTime: .now,
                                       status: .active,
                                       countryID: franceID)

                    try await [booth1, booth2, booth3].create(on: app.db)

                    try await app.testing().test(.GET, "api/v0/booths") { res in
                        #expect(res.status == .ok)

                        let booths = try res.content.decode([BoothOutput].self)

                        #expect(booths.count == 2)

                        let names = booths.map(\.name)

                        #expect(names.contains(booth1.name))
                        #expect(names.contains(booth3.name))

                        let ids = booths.map(\.id)

                        #expect(ids.contains(booth1.id!))
                        #expect(ids.contains(booth3.id!))

                        // Order by name
                        #expect(ids[0] == booth1.id!)
                        #expect(ids[1] == booth3.id!)
                    }
                }
            }
        }

        @Suite("GET /api/v0/booths/{id}")
        struct Show {
            @Test
            func `show booth`() async throws {
                try await withApp(configure: configure) { app in
                    let portugal = try await addBoothCountry(app: app, code: "PRT",
                                                             name: "Portugal")
                    let portugalID = try portugal.requireID()

                    let booth = Booth(name: "Quia Reprehenderit Ut Vitae",
                                      about: "Velit Autem Iste Suscipit",
                                      pictureURL: "https://picsum.photos/800",
                                      location: "Culpa Explicabo Eum",
                                      isVegan: false,
                                      isPRM: true,
                                      isFamilyFriendly: false,
                                      allergens: [.cerealsContainingGluten],
                                      startTime: .now,
                                      endTime: .now,
                                      status: .active,
                                      countryID: portugalID)
                    try await booth.create(on: app.db)

                    try await app.testing()
                        .test(.GET,
                              "api/v0/booths/\(booth.id!)") { res in
                            #expect(res.status == .ok)

                            let found = try res.content
                                .decode(BoothOutput.self)

                            #expect(found.id == booth.id)
                            #expect(found.name == booth.name)
                            #expect(found.location == booth.location)
                        }
                }
            }

            @Test
            func `throw error when booth is not found`() async throws {
                try await withApp(configure: configure) { app in
                    let luxembourg = try await addBoothCountry(app: app, code: "LUX",
                                                               name: "Luxembourg")
                    let luxembourgID = try luxembourg.requireID()

                    let booth = Booth(name: "Qui Rem Quia Repudiandae",
                                      about: "Nihil Eaque Cupiditate",
                                      pictureURL: "https://picsum.photos/800",
                                      location: "Consequatur Distinctio Aut Dicta",
                                      isVegan: true,
                                      isPRM: true,
                                      isFamilyFriendly: true,
                                      allergens: [.milk],
                                      startTime: .now,
                                      endTime: .now,
                                      status: .active,
                                      countryID: luxembourgID)
                    try await booth.create(on: app.db)

                    let expected = BoothError.notFound
                    try await app.testing()
                        .test(.GET,
                              "api/v0/booths/\(UUID())") { res in
                            #expect(res.status == expected.status)

                            let body = try res.content
                                .decode(ErrorBody.self)

                            #expect(body.error == true)
                            #expect(body.reason == expected.reason)
                        }
                }
            }

            @Test
            func `throw error when booth is not active`() async throws {
                try await withApp(configure: configure) { app in
                    let japan = try await addBoothCountry(app: app, code: "JPN", name: "Nihon")
                    let japanID = try japan.requireID()

                    let booth = Booth(name: "Et Placeat Beatae",
                                      about: "Quaerat Nihil",
                                      pictureURL: "https://picsum.photos/800",
                                      location: "Nemo Consequatur",
                                      isVegan: true,
                                      isPRM: false,
                                      isFamilyFriendly: false,
                                      allergens: [.eggs],
                                      startTime: .now,
                                      endTime: .now,
                                      status: .disabled,
                                      countryID: japanID)
                    try await booth.create(on: app.db)

                    let expected = BoothError.disabled
                    try await app.testing()
                        .test(.GET,
                              "api/v0/booths/\(booth.id!)") { res in
                            #expect(res.status == expected.status)

                            let body = try res.content
                                .decode(ErrorBody.self)

                            #expect(body.error == true)
                            #expect(body.reason == expected.reason)
                        }
                }
            }
        }
    }

    @Suite("Staff & Admin routes")
    struct AdminStaff {
        @Suite("GET /api/v0/booths")
        struct TableList {
            @Test
            func `The list is empty at the start - user is staff`() async throws {
                try await withApp(configure: configure) { app in
                    let token = try await makeToken(app: app,
                                                    role: .staff)

                    try await app.testing().test(.GET,
                                                 "api/v0/admin/booths",
                                                 headers: [
                                                     "Authorization": "Bearer \(token)",
                                                 ]) { res in
                        #expect(res.status == .ok)

                        let page = try res.content.decode(Page<AdminBoothListItemOutput>.self)

                        #expect(page.items.isEmpty)
                    }
                }
            }

            @Test
            func `The list contains added booths`() async throws {
                try await withApp(configure: configure) { app in
                    let france = try await addBoothCountry(app: app, code: "FRA", name: "France")
                    let franceID = try france.requireID()

                    let booth1 = Booth(name: "Quis Nobis Quod",
                                       about: "Sapiente Aut Est Omnis",
                                       pictureURL: "https://picsum.photos/800",
                                       location: "Tenetur Nulla",
                                       isVegan: false,
                                       isPRM: true,
                                       isFamilyFriendly: true,
                                       allergens: [.celery, .mustard],
                                       startTime: .now,
                                       endTime: .now,
                                       status: .active,
                                       countryID: franceID)

                    let booth2 = Booth(name: "Aspernatur Quaerat Voluptate Aspernatur",
                                       about: "Doloribus Animi Sed",
                                       pictureURL: "https://picsum.photos/800",
                                       location: "Voluptatum Ullam Est",
                                       isVegan: true,
                                       isPRM: false,
                                       isFamilyFriendly: true,
                                       allergens: [.fish, .crustaceans, .molluscs],
                                       startTime: .now,
                                       endTime: .now,
                                       status: .active,
                                       countryID: franceID)

                    let booth3 = Booth(name: "Quos Quisquam Accusantium",
                                       about: "Illum Tempora",
                                       pictureURL: "https://picsum.photos/800",
                                       location: "Ab Qui",
                                       isVegan: false,
                                       isPRM: false,
                                       isFamilyFriendly: true,
                                       allergens: [.nuts, .soybeans, .sesameSeeds, .peanuts],
                                       startTime: .now,
                                       endTime: .now,
                                       status: .active,
                                       countryID: franceID)

                    try await [booth1, booth2, booth3].create(on: app.db)

                    let token = try await makeToken(app: app,
                                                    role: .staff)

                    try await app.testing().test(.GET,
                                                 "api/v0/admin/booths",
                                                 headers: [
                                                     "Authorization": "Bearer \(token)",
                                                 ]) { res in
                        #expect(res.status == .ok)

                        let page = try res.content.decode(Page<AdminBoothListItemOutput>.self)

                        #expect(page.items.count == 3)

                        let names = page.items.map(\.name)

                        #expect(names.contains(booth1.name))
                        #expect(names.contains(booth2.name))
                        #expect(names.contains(booth3.name))

                        let ids = page.items.map(\.id)

                        #expect(ids.contains(booth1.id!))
                        #expect(ids.contains(booth2.id!))
                        #expect(ids.contains(booth3.id!))

                        // Order by name
                        #expect(ids[0] == booth2.id!)
                        #expect(ids[1] == booth1.id!)
                        #expect(ids[2] == booth3.id!)
                    }
                }
            }

            @Test
            func `The list contains active and disabled booths`() async throws {
                try await withApp(configure: configure) { app in
                    let france = try await addBoothCountry(app: app, code: "FRA", name: "France")
                    let franceID = try france.requireID()

                    let booth1 = Booth(name: "Quis Nobis Quod",
                                       about: "Sapiente Aut Est Omnis",
                                       pictureURL: "https://picsum.photos/800",
                                       location: "Tenetur Nulla",
                                       isVegan: false,
                                       isPRM: true,
                                       isFamilyFriendly: true,
                                       allergens: [.celery, .mustard],
                                       startTime: .now,
                                       endTime: .now,
                                       status: .active,
                                       countryID: franceID)

                    let booth2 = Booth(name: "Aspernatur Quaerat Voluptate Aspernatur",
                                       about: "Doloribus Animi Sed",
                                       pictureURL: "https://picsum.photos/800",
                                       location: "Voluptatum Ullam Est",
                                       isVegan: true,
                                       isPRM: false,
                                       isFamilyFriendly: true,
                                       allergens: [.fish, .crustaceans, .molluscs],
                                       startTime: .now,
                                       endTime: .now,
                                       status: .active,
                                       countryID: franceID)

                    let booth3 = Booth(name: "Quos Quisquam Accusantium",
                                       about: "Illum Tempora",
                                       pictureURL: "https://picsum.photos/800",
                                       location: "Ab Qui",
                                       isVegan: false,
                                       isPRM: false,
                                       isFamilyFriendly: true,
                                       allergens: [.nuts, .soybeans, .sesameSeeds, .peanuts],
                                       startTime: .now,
                                       endTime: .now,
                                       status: .disabled,
                                       countryID: franceID)

                    try await [booth1, booth2, booth3].create(on: app.db)

                    let token = try await makeToken(app: app,
                                                    role: .staff)

                    try await app.testing().test(.GET,
                                                 "api/v0/admin/booths",
                                                 headers: [
                                                     "Authorization": "Bearer \(token)",
                                                 ]) { res in
                        #expect(res.status == .ok)

                        let page = try res.content.decode(Page<AdminBoothListItemOutput>.self)

                        #expect(page.items.count == 3)

                        let names = page.items.map(\.name)

                        #expect(names.contains(booth1.name))
                        #expect(names.contains(booth2.name))
                        #expect(names.contains(booth3.name))

                        let ids = page.items.map(\.id)

                        #expect(ids.contains(booth1.id!))
                        #expect(ids.contains(booth2.id!))
                        #expect(ids.contains(booth3.id!))

                        // Order by name
                        #expect(ids[0] == booth2.id!)
                        #expect(ids[1] == booth1.id!)
                        #expect(ids[2] == booth3.id!)
                    }
                }
            }
        }

        @Suite("GET /api/v0/admin/booths/{id}")
        struct Show {
            @Test
            func `show booth`() async throws {
                try await withApp(configure: configure) { app in
                    let portugal = try await addBoothCountry(app: app, code: "PRT",
                                                             name: "Portugal")
                    let portugalID = try portugal.requireID()

                    let booth = Booth(name: "Quia Reprehenderit Ut Vitae",
                                      about: "Velit Autem Iste Suscipit",
                                      pictureURL: "https://picsum.photos/800",
                                      location: "Culpa Explicabo Eum",
                                      isVegan: false,
                                      isPRM: true,
                                      isFamilyFriendly: false,
                                      allergens: [.cerealsContainingGluten],
                                      startTime: .now,
                                      endTime: .now,
                                      status: .active,
                                      countryID: portugalID)
                    try await booth.create(on: app.db)

                    let token = try await makeToken(app: app,
                                                    role: .staff)

                    try await app.testing()
                        .test(.GET,
                              "api/v0/admin/booths/\(booth.id!)",
                              headers: ["Authorization": "Bearer \(token)"]) { res in
                            #expect(res.status == .ok)

                            let found = try res.content
                                .decode(AdminShowBoothOutput.self)

                            #expect(found.id == booth.id)
                            #expect(found.name == booth.name)
                            #expect(found.location == booth.location)
                        }
                }
            }

            @Test
            func `throw error when booth is not found`() async throws {
                try await withApp(configure: configure) { app in
                    let luxembourg = try await addBoothCountry(app: app, code: "LUX",
                                                               name: "Luxembourg")
                    let luxembourgID = try luxembourg.requireID()

                    let booth = Booth(name: "Qui Rem Quia Repudiandae",
                                      about: "Nihil Eaque Cupiditate",
                                      pictureURL: "https://picsum.photos/800",
                                      location: "Consequatur Distinctio Aut Dicta",
                                      isVegan: true,
                                      isPRM: true,
                                      isFamilyFriendly: true,
                                      allergens: [.milk],
                                      startTime: .now,
                                      endTime: .now,
                                      status: .active,
                                      countryID: luxembourgID)
                    try await booth.create(on: app.db)

                    let token = try await makeToken(app: app,
                                                    role: .staff)

                    let expected = BoothError.notFound
                    try await app.testing()
                        .test(.GET,
                              "api/v0/admin/booths/\(UUID())",
                              headers: ["Authorization": "Bearer \(token)"]) { res in
                            #expect(res.status == expected.status)

                            let body = try res.content
                                .decode(ErrorBody.self)

                            #expect(body.error == true)
                            #expect(body.reason == expected.reason)
                        }
                }
            }
        }

        @Suite("PATCH /api/v0/admin/booths/{id}/enable")
        struct Enable {
            @Test
            func `enable booth`() async throws {
                try await withApp(configure: configure) { app in
                    let portugal = try await addBoothCountry(app: app, code: "PRT",
                                                             name: "Portugal")
                    let portugalID = try portugal.requireID()

                    let booth = Booth(name: "Quia Reprehenderit Ut Vitae",
                                      about: "Velit Autem Iste Suscipit",
                                      pictureURL: "https://picsum.photos/800",
                                      location: "Culpa Explicabo Eum",
                                      isVegan: false,
                                      isPRM: true,
                                      isFamilyFriendly: false,
                                      allergens: [.cerealsContainingGluten],
                                      startTime: .now,
                                      endTime: .now,
                                      status: .disabled,
                                      countryID: portugalID)
                    try await booth.create(on: app.db)

                    let token = try await makeToken(app: app,
                                                    role: .staff)

                    try await app.testing()
                        .test(.PATCH,
                              "api/v0/admin/booths/\(booth.id!)/enable",
                              headers: ["Authorization": "Bearer \(token)"]) { res in
                            #expect(res.status == .noContent)
                        }
                }
            }

            @Test
            func `throw error when Booth is active`() async throws {
                try await withApp(configure: configure) { app in
                    let portugal = try await addBoothCountry(app: app, code: "PRT",
                                                             name: "Portugal")
                    let portugalID = try portugal.requireID()

                    let booth = Booth(name: "Quia Reprehenderit Ut Vitae",
                                      about: "Velit Autem Iste Suscipit",
                                      pictureURL: "https://picsum.photos/800",
                                      location: "Culpa Explicabo Eum",
                                      isVegan: false,
                                      isPRM: true,
                                      isFamilyFriendly: false,
                                      allergens: [.cerealsContainingGluten],
                                      startTime: .now,
                                      endTime: .now,
                                      status: .active,
                                      countryID: portugalID)
                    try await booth.create(on: app.db)

                    let token = try await makeToken(app: app,
                                                    role: .staff)

                    let expected = BoothError.invalidAction
                    try await app.testing()
                        .test(.PATCH,
                              "api/v0/admin/booths/\(booth.id!)/enable",
                              headers: ["Authorization": "Bearer \(token)"]) { res in
                            #expect(res.status == expected.status)

                            let body = try res.content
                                .decode(ErrorBody.self)

                            #expect(body.error == true)
                            #expect(body.reason == expected.reason)
                        }
                }
            }
        }

        @Suite("PATCH /api/v0/admin/booths/{id}/disable")
        struct Disable {
            @Test
            func `disable booth`() async throws {
                try await withApp(configure: configure) { app in
                    let portugal = try await addBoothCountry(app: app, code: "PRT",
                                                             name: "Portugal")
                    let portugalID = try portugal.requireID()

                    let booth = Booth(name: "Quia Reprehenderit Ut Vitae",
                                      about: "Velit Autem Iste Suscipit",
                                      pictureURL: "https://picsum.photos/800",
                                      location: "Culpa Explicabo Eum",
                                      isVegan: false,
                                      isPRM: true,
                                      isFamilyFriendly: false,
                                      allergens: [.cerealsContainingGluten],
                                      startTime: .now,
                                      endTime: .now,
                                      status: .active,
                                      countryID: portugalID)
                    try await booth.create(on: app.db)

                    let token = try await makeToken(app: app,
                                                    role: .staff)

                    try await app.testing()
                        .test(.PATCH,
                              "api/v0/admin/booths/\(booth.id!)/disable",
                              headers: ["Authorization": "Bearer \(token)"]) { res in
                            #expect(res.status == .noContent)
                        }
                }
            }

            @Test
            func `throw error when Booth is disabled`() async throws {
                try await withApp(configure: configure) { app in
                    let portugal = try await addBoothCountry(app: app, code: "PRT",
                                                             name: "Portugal")
                    let portugalID = try portugal.requireID()

                    let booth = Booth(name: "Quia Reprehenderit Ut Vitae",
                                      about: "Velit Autem Iste Suscipit",
                                      pictureURL: "https://picsum.photos/800",
                                      location: "Culpa Explicabo Eum",
                                      isVegan: false,
                                      isPRM: true,
                                      isFamilyFriendly: false,
                                      allergens: [.cerealsContainingGluten],
                                      startTime: .now,
                                      endTime: .now,
                                      status: .disabled,
                                      countryID: portugalID)
                    try await booth.create(on: app.db)

                    let token = try await makeToken(app: app,
                                                    role: .staff)

                    let expected = BoothError.invalidAction
                    try await app.testing()
                        .test(.PATCH,
                              "api/v0/admin/booths/\(booth.id!)/disable",
                              headers: ["Authorization": "Bearer \(token)"]) { res in
                            #expect(res.status == expected.status)

                            let body = try res.content
                                .decode(ErrorBody.self)

                            #expect(body.error == true)
                            #expect(body.reason == expected.reason)
                        }
                }
            }
        }
    }
}

fileprivate func addBoothCountry(app: Application, code: String,
                                 name: String) async throws -> BoothCountry {
    let country = BoothCountry(code: code)
    try await country.create(on: app.db)
    let countryID = try country.requireID()

    let translationEn = BoothCountryTranslation(locale: "en",
                                                name: name,
                                                countryID: countryID)
    try await translationEn.create(on: app.db)

    let translationFr = BoothCountryTranslation(locale: "fr",
                                                name: name,
                                                countryID: countryID)
    try await translationFr.create(on: app.db)

    return country
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

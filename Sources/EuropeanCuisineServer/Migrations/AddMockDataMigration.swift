//
//  AddMockDataMigration.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 12/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Fluent
import Vapor

struct AddMockDataMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await addBoothCountries(on: database)
        try await addBooths(on: database)
        try await addWorkshops(on: database)
        try await addUsers(on: database)
        try await addReservations(on: database)
    }

    func revert(on database: any Database) async throws {
        try await removeReservations(on: database)
        try await removeUsers(on: database)
        try await removeWorkshops(on: database)
        try await removeBooths(on: database)
        try await removeBoothCountries(on: database)
    }

    private func addBoothCountries(on database: any Database) async throws {
        let countries: [(code: String, en: String, fr: String)] = [
            ("ALB", "Albania", "Albanie"),
            ("AND", "Andorra", "Andorre"),
            ("AUT", "Austria", "Autriche"),
            ("BEL", "Belgium", "Belgique"),
            ("BGR", "Bulgaria", "Bulgarie"),
            ("BIH", "Bosnia and Herzegovina", "Bosnie-Herzégovine"),
//            ("BLR", "Belarus", "Biélorussie"),
            ("CHE", "Switzerland", "Suisse"),
            ("CYP", "Cyprus", "Chypre"),
            ("CZE", "Czechia", "Tchéquie"),
            ("DEU", "Germany", "Allemagne"),
            ("DNK", "Denmark", "Danemark"),
            ("ESP", "Spain", "Espagne"),
            ("EST", "Estonia", "Estonie"),
            ("FIN", "Finland", "Finlande"),
            ("FRA", "France", "France"),
            ("GBR", "United Kingdom", "Royaume-Uni"),
            ("GRC", "Greece", "Grèce"),
            ("HRV", "Croatia", "Croatie"),
            ("HUN", "Hungary", "Hongrie"),
            ("IRL", "Ireland", "Irlande"),
            ("ISL", "Iceland", "Islande"),
            ("ITA", "Italy", "Italie"),
            ("LIE", "Liechtenstein", "Liechtenstein"),
            ("LTU", "Lithuania", "Lituanie"),
            ("LUX", "Luxembourg", "Luxembourg"),
            ("LVA", "Latvia", "Lettonie"),
            ("MCO", "Monaco", "Monaco"),
            ("MDA", "Moldova", "Moldavie"),
            ("MKD", "North Macedonia", "Macédoine du Nord"),
            ("MLT", "Malta", "Malte"),
            ("MNE", "Montenegro", "Monténégro"),
            ("NLD", "Netherlands", "Pays-Bas"),
            ("NOR", "Norway", "Norvège"),
            ("POL", "Poland", "Pologne"),
            ("PRT", "Portugal", "Portugal"),
            ("ROU", "Romania", "Roumanie"),
//            ("RUS", "Russia", "Russie"),
            ("SMR", "San Marino", "Saint-Marin"),
            ("SRB", "Serbia", "Serbie"),
            ("SVK", "Slovakia", "Slovaquie"),
            ("SVN", "Slovenia", "Slovénie"),
            ("SWE", "Sweden", "Suède"),
            ("UKR", "Ukraine", "Ukraine"),
            ("VAT", "Vatican City", "Vatican"),
            ("XKX", "Kosovo", "Kosovo"),
        ]

        for country in countries {
            try await addBoothCountriesWithTranslations(on: database,
                                                        code: country.code,
                                                        enTranslation: country.en,
                                                        frTranslation: country.fr)
        }
    }

    private func addBooths(on database: any Database) async throws {
        let france = try await BoothCountry
            .query(on: database)
            .filter(\.$code == "FRA")
            .first()!

        let spain = try await BoothCountry
            .query(on: database)
            .filter(\.$code == "ESP")
            .first()!

        let greece = try await BoothCountry
            .query(on: database)
            .filter(\.$code == "GRC")
            .first()!

        let portugal = try await BoothCountry
            .query(on: database)
            .filter(\.$code == "PRT")
            .first()!

        let italy = try await BoothCountry
            .query(on: database)
            .filter(\.$code == "ITA")
            .first()!

        let latvia = try await BoothCountry
            .query(on: database)
            .filter(\.$code == "LVA")
            .first()!

        let sweden = try await BoothCountry
            .query(on: database)
            .filter(\.$code == "SWE")
            .first()!

        let croatia = try await BoothCountry
            .query(on: database)
            .filter(\.$code == "HRV")
            .first()!

        let frCountryID = try france.requireID()
        let esCountryID = try spain.requireID()
        let grCountryID = try greece.requireID()
        let ptCountryID = try portugal.requireID()
        let itCountryID = try italy.requireID()
        let lvCountryID = try latvia.requireID()
        let seCountryID = try sweden.requireID()
        let hrCountryID = try croatia.requireID()

        let frenchBooths: [Booth] = [
            Booth(name: "La Crêperie Bretonne",
                  about: "Crêpes and galettes made to order: ham and cheese, butter and sugar, salted caramel.",
                  pictureURL: "https://picsum.photos/seed/creperie/800",
                  location: "Aisle A - Stand 1",
                  isVegan: false,
                  isPRM: true,
                  isFamilyFriendly: true,
                  allergens: [.cerealsContainingGluten, .milk, .eggs],
                  startTime: .hourMinuteUTC(hour: 8, minute: 30),
                  endTime: .hourMinuteUTC(hour: 16, minute: 45),
                  status: .active,
                  countryID: frCountryID),

            Booth(name: "La Raclette Savoyarde",
                  about: "Melted raclette cheese served over potatoes, with cured meats and gherkins.",
                  pictureURL: "https://picsum.photos/seed/raclette/800",
                  location: "Aisle A - Stand 2",
                  isVegan: false,
                  isPRM: true,
                  isFamilyFriendly: true,
                  allergens: [.milk],
                  startTime: .hourMinuteUTC(hour: 9, minute: 30),
                  endTime: .hourMinuteUTC(hour: 17, minute: 30),
                  status: .active,
                  countryID: frCountryID),

            Booth(name: "Le Comptoir Provençal",
                  about: "Ratatouille, vegetable tian and socca made with fresh Southern vegetables. 100% plant-based.",
                  pictureURL: "https://picsum.photos/seed/ratatouille/800",
                  location: "Aisle B - Stand 3",
                  isVegan: true,
                  isPRM: true,
                  isFamilyFriendly: true,
                  allergens: [],
                  startTime: .hourMinuteUTC(hour: 8, minute: 0),
                  endTime: .hourMinuteUTC(hour: 16, minute: 0),
                  status: .active,
                  countryID: frCountryID),

            Booth(name: "Maison Macaron",
                  about: "Handmade macarons: raspberry, pistachio, dark chocolate, Madagascar vanilla and caramel.",
                  pictureURL: "https://picsum.photos/seed/macaron/800",
                  location: "Aisle B - Stand 4",
                  isVegan: false,
                  isPRM: false,
                  isFamilyFriendly: true,
                  allergens: [.nuts, .eggs, .milk],
                  startTime: .hourMinuteUTC(hour: 10, minute: 0),
                  endTime: .hourMinuteUTC(hour: 12, minute: 30),
                  status: .active,
                  countryID: frCountryID),

            Booth(name: "La Bouillabaisse Marseillaise",
                  about: "Traditional Provençal fish soup made with rockfish, served with croutons and homemade rouille.",
                  pictureURL: "https://picsum.photos/seed/bouillabaisse/800",
                  location: "Aisle C - Stand 5",
                  isVegan: false,
                  isPRM: true,
                  isFamilyFriendly: false,
                  allergens: [.fish, .crustaceans, .cerealsContainingGluten, .eggs],
                  startTime: .hourMinuteUTC(hour: 11, minute: 30),
                  endTime: .hourMinuteUTC(hour: 15, minute: 30),
                  status: .active,
                  countryID: frCountryID),

            Booth(name: "La Boulangerie Parisienne",
                  about: "Traditional baguettes, all-butter croissants, pains au chocolat and éclairs fresh from the oven.",
                  pictureURL: "https://picsum.photos/seed/boulangerie/800",
                  location: "Aisle C - Stand 6",
                  isVegan: false,
                  isPRM: true,
                  isFamilyFriendly: true,
                  allergens: [.cerealsContainingGluten, .milk, .eggs],
                  startTime: .hourMinuteUTC(hour: 9, minute: 0),
                  endTime: .hourMinuteUTC(hour: 17, minute: 0),
                  status: .active,
                  countryID: frCountryID),
        ]

        for booth in frenchBooths {
            try await booth.create(on: database)
        }

        let spanishBooths: [Booth] = [
            Booth(name: "La Tortilla de Patatas",
                  about: "Traditional Spanish omelette with potatoes and onions, served by the slice or as a pintxo.",
                  pictureURL: "https://picsum.photos/seed/tortilla/800",
                  location: "Aisle D - Stand 1",
                  isVegan: false,
                  isPRM: true,
                  isFamilyFriendly: true,
                  allergens: [.eggs],
                  startTime: .hourMinuteUTC(hour: 9, minute: 0),
                  endTime: .hourMinuteUTC(hour: 16, minute: 15),
                  status: .active,
                  countryID: esCountryID),

            Booth(name: "El Rincón de la Paella",
                  about: "Valencian paella cooked over a wood fire with chicken, rabbit, green beans and saffron.",
                  pictureURL: "https://picsum.photos/seed/paella/800",
                  location: "Aisle D - Stand 2",
                  isVegan: false,
                  isPRM: true,
                  isFamilyFriendly: true,
                  allergens: [],
                  startTime: .hourMinuteUTC(hour: 8, minute: 45),
                  endTime: .hourMinuteUTC(hour: 15, minute: 0),
                  status: .active,
                  countryID: esCountryID),

            Booth(name: "Churros y Chocolate",
                  about: "Crispy churros made to order, served with thick Spanish-style hot chocolate.",
                  pictureURL: "https://picsum.photos/seed/churros/800",
                  location: "Aisle D - Stand 3",
                  isVegan: false,
                  isPRM: true,
                  isFamilyFriendly: true,
                  allergens: [.cerealsContainingGluten, .milk],
                  startTime: .hourMinuteUTC(hour: 12, minute: 0),
                  endTime: .hourMinuteUTC(hour: 14, minute: 30),
                  status: .active,
                  countryID: esCountryID),

            Booth(name: "Gazpacho y Salmorejo",
                  about: "Andalusian cold soups made with ripe tomatoes, peppers and olive oil. 100% plant-based.",
                  pictureURL: "https://picsum.photos/seed/gazpacho/800",
                  location: "Aisle E - Stand 4",
                  isVegan: true,
                  isPRM: true,
                  isFamilyFriendly: true,
                  allergens: [.cerealsContainingGluten],
                  startTime: .hourMinuteUTC(hour: 10, minute: 30),
                  endTime: .hourMinuteUTC(hour: 15, minute: 30),
                  status: .active,
                  countryID: esCountryID),

            Booth(name: "Jamón & Tapas",
                  about: "Hand-carved Iberian ham, chorizo, Manchego cheese and pan con tomate.",
                  pictureURL: "https://picsum.photos/seed/jamon/800",
                  location: "Aisle E - Stand 5",
                  isVegan: false,
                  isPRM: false,
                  isFamilyFriendly: false,
                  allergens: [.cerealsContainingGluten, .milk],
                  startTime: .hourMinuteUTC(hour: 9, minute: 0),
                  endTime: .hourMinuteUTC(hour: 11, minute: 30),
                  status: .active,
                  countryID: esCountryID),

            Booth(name: "Pulpo a la Gallega",
                  about: "Galician-style octopus with boiled potatoes, smoked paprika and olive oil.",
                  pictureURL: "https://picsum.photos/seed/pulpo/800",
                  location: "Aisle E - Stand 6",
                  isVegan: false,
                  isPRM: true,
                  isFamilyFriendly: false,
                  allergens: [.molluscs],
                  startTime: .hourMinuteUTC(hour: 10, minute: 30),
                  endTime: .hourMinuteUTC(hour: 15, minute: 45),
                  status: .active,
                  countryID: esCountryID),
        ]

        for booth in spanishBooths {
            try await booth.create(on: database)
        }

        let greekBooths: [Booth] = [
            Booth(name: "O Souvlatzis",
                  about: "Grilled pork and chicken souvlaki served in warm pita with tzatziki, tomato, onion and fries.",
                  pictureURL: "https://picsum.photos/seed/souvlaki/800",
                  location: "Aisle F - Stand 1",
                  isVegan: false,
                  isPRM: true,
                  isFamilyFriendly: true,
                  allergens: [.cerealsContainingGluten, .milk],
                  startTime: .hourMinuteUTC(hour: 9, minute: 30),
                  endTime: .hourMinuteUTC(hour: 17, minute: 30),
                  status: .active,
                  countryID: grCountryID),

            Booth(name: "Mamá Moussaka",
                  about: "Homemade moussaka with layers of aubergine, potato and spiced minced beef, topped with creamy béchamel.",
                  pictureURL: "https://picsum.photos/seed/moussaka/800",
                  location: "Aisle F - Stand 2",
                  isVegan: false,
                  isPRM: true,
                  isFamilyFriendly: true,
                  allergens: [.cerealsContainingGluten, .milk, .eggs],
                  startTime: .hourMinuteUTC(hour: 11, minute: 0),
                  endTime: .hourMinuteUTC(hour: 16, minute: 0),
                  status: .active,
                  countryID: grCountryID),

            Booth(name: "Filo & Feta",
                  about: "Crispy spanakopita and tiropita: golden filo pastry filled with spinach, feta and fresh herbs.",
                  pictureURL: "https://picsum.photos/seed/spanakopita/800",
                  location: "Aisle F - Stand 3",
                  isVegan: false,
                  isPRM: false,
                  isFamilyFriendly: true,
                  allergens: [.cerealsContainingGluten, .milk, .eggs],
                  startTime: .hourMinuteUTC(hour: 8, minute: 30),
                  endTime: .hourMinuteUTC(hour: 15, minute: 0),
                  status: .active,
                  countryID: grCountryID),

            Booth(name: "Mezze Aegean",
                  about: "Gigantes plaki, dolmades, fava purée and horiatiki salad made with olive oil and fresh vegetables. 100% plant-based.",
                  pictureURL: "https://picsum.photos/seed/mezze/800",
                  location: "Aisle G - Stand 4",
                  isVegan: true,
                  isPRM: true,
                  isFamilyFriendly: true,
                  allergens: [],
                  startTime: .hourMinuteUTC(hour: 10, minute: 0),
                  endTime: .hourMinuteUTC(hour: 18, minute: 0),
                  status: .active,
                  countryID: grCountryID),

            Booth(name: "Loukoumades & Baklava",
                  about: "Hot honey doughnuts with cinnamon and walnuts, plus baklava layered with pistachios and syrup.",
                  pictureURL: "https://picsum.photos/seed/baklava/800",
                  location: "Aisle G - Stand 5",
                  isVegan: false,
                  isPRM: true,
                  isFamilyFriendly: true,
                  allergens: [.cerealsContainingGluten, .nuts, .milk],
                  startTime: .hourMinuteUTC(hour: 12, minute: 0),
                  endTime: .hourMinuteUTC(hour: 17, minute: 30),
                  status: .active,
                  countryID: grCountryID),
        ]

        for booth in greekBooths {
            try await booth.create(on: database)
        }

        let portugueseBooths: [Booth] = [
            Booth(name: "Pastéis de Nata Lisboa",
                  about: "Warm Portuguese custard tarts with flaky pastry, dusted with cinnamon.",
                  pictureURL: "https://picsum.photos/seed/pasteisnata/800",
                  location: "Aisle H - Stand 1",
                  isVegan: false,
                  isPRM: true,
                  isFamilyFriendly: true,
                  allergens: [.cerealsContainingGluten, .milk, .eggs],
                  startTime: .hourMinuteUTC(hour: 8, minute: 30),
                  endTime: .hourMinuteUTC(hour: 17, minute: 0),
                  status: .active,
                  countryID: ptCountryID),

            Booth(name: "Bacalhau à Brás",
                  about: "Shredded salted cod sautéed with thin fries, onions and scrambled eggs, topped with olives and parsley.",
                  pictureURL: "https://picsum.photos/seed/bacalhau/800",
                  location: "Aisle H - Stand 2",
                  isVegan: false,
                  isPRM: true,
                  isFamilyFriendly: true,
                  allergens: [.fish, .eggs],
                  startTime: .hourMinuteUTC(hour: 11, minute: 30),
                  endTime: .hourMinuteUTC(hour: 16, minute: 30),
                  status: .active,
                  countryID: ptCountryID),
        ]

        for booth in portugueseBooths {
            try await booth.create(on: database)
        }

        let italianBooths: [Booth] = [
            Booth(name: "Pizzeria Napoletana",
                  about: "Wood-fired Neapolitan pizzas: margherita, marinara and prosciutto e funghi.",
                  pictureURL: "https://picsum.photos/seed/napoletana/800",
                  location: "Aisle H - Stand 3",
                  isVegan: false,
                  isPRM: true,
                  isFamilyFriendly: true,
                  allergens: [.cerealsContainingGluten, .milk],
                  startTime: .hourMinuteUTC(hour: 10, minute: 0),
                  endTime: .hourMinuteUTC(hour: 18, minute: 30),
                  status: .active,
                  countryID: itCountryID),

            Booth(name: "Gelato Artigianale",
                  about: "Creamy handmade gelato: pistachio, hazelnut, stracciatella and lemon sorbet.",
                  pictureURL: "https://picsum.photos/seed/gelato/800",
                  location: "Aisle H - Stand 4",
                  isVegan: false,
                  isPRM: true,
                  isFamilyFriendly: true,
                  allergens: [.milk, .nuts, .eggs],
                  startTime: .hourMinuteUTC(hour: 12, minute: 0),
                  endTime: .hourMinuteUTC(hour: 19, minute: 0),
                  status: .active,
                  countryID: itCountryID),

            Booth(name: "L'Orto Italiano",
                  about: "Tuscan bruschetta, caponata and ribollita made with seasonal vegetables and extra virgin olive oil. 100% plant-based.",
                  pictureURL: "https://picsum.photos/seed/ribollita/800",
                  location: "Aisle I - Stand 5",
                  isVegan: true,
                  isPRM: true,
                  isFamilyFriendly: true,
                  allergens: [.cerealsContainingGluten, .celery],
                  startTime: .hourMinuteUTC(hour: 9, minute: 0),
                  endTime: .hourMinuteUTC(hour: 15, minute: 30),
                  status: .active,
                  countryID: itCountryID),
        ]

        for booth in italianBooths {
            try await booth.create(on: database)
        }

        let latvianBooths: [Booth] = [
            Booth(name: "Pīrāgi Rīga",
                  about: "Traditional Latvian bacon and onion buns, baked fresh and served warm.",
                  pictureURL: "https://picsum.photos/seed/piragi/800",
                  location: "Aisle I - Stand 6",
                  isVegan: false,
                  isPRM: true,
                  isFamilyFriendly: true,
                  allergens: [.cerealsContainingGluten, .milk, .eggs],
                  startTime: .hourMinuteUTC(hour: 9, minute: 30),
                  endTime: .hourMinuteUTC(hour: 16, minute: 0),
                  status: .active,
                  countryID: lvCountryID),

            Booth(name: "Aukstā Zupa",
                  about: "Refreshing cold beetroot soup with kefir, cucumber and dill, served with boiled potatoes and egg.",
                  pictureURL: "https://picsum.photos/seed/aukstazupa/800",
                  location: "Aisle I - Stand 7",
                  isVegan: false,
                  isPRM: false,
                  isFamilyFriendly: true,
                  allergens: [.milk, .eggs],
                  startTime: .hourMinuteUTC(hour: 11, minute: 0),
                  endTime: .hourMinuteUTC(hour: 14, minute: 30),
                  status: .active,
                  countryID: lvCountryID),
        ]

        for booth in latvianBooths {
            try await booth.create(on: database)
        }

        let swedishBooths: [Booth] = [
            Booth(name: "Köttbullar & Lingonberries",
                  about: "Swedish meatballs with creamy gravy, mashed potatoes, pickled cucumber and lingonberry jam.",
                  pictureURL: "https://picsum.photos/seed/kottbullar/800",
                  location: "Aisle I - Stand 8",
                  isVegan: false,
                  isPRM: true,
                  isFamilyFriendly: true,
                  allergens: [.cerealsContainingGluten, .milk, .eggs],
                  startTime: .hourMinuteUTC(hour: 10, minute: 30),
                  endTime: .hourMinuteUTC(hour: 17, minute: 30),
                  status: .active,
                  countryID: seCountryID),

            Booth(name: "Fika & Kanelbullar",
                  about: "Cinnamon and cardamom buns baked every hour, served with freshly brewed filter coffee.",
                  pictureURL: "https://picsum.photos/seed/kanelbullar/800",
                  location: "Aisle J - Stand 9",
                  isVegan: false,
                  isPRM: true,
                  isFamilyFriendly: true,
                  allergens: [.cerealsContainingGluten, .milk, .eggs],
                  startTime: .hourMinuteUTC(hour: 8, minute: 0),
                  endTime: .hourMinuteUTC(hour: 18, minute: 0),
                  status: .active,
                  countryID: seCountryID),

            Booth(name: "Gravlax Stockholm",
                  about: "Dill-cured salmon served on rye bread with mustard-dill sauce and boiled potatoes.",
                  pictureURL: "https://picsum.photos/seed/gravlax/800",
                  location: "Aisle J - Stand 10",
                  isVegan: false,
                  isPRM: false,
                  isFamilyFriendly: false,
                  allergens: [.fish, .mustard, .cerealsContainingGluten],
                  startTime: .hourMinuteUTC(hour: 12, minute: 0),
                  endTime: .hourMinuteUTC(hour: 16, minute: 30),
                  status: .active,
                  countryID: seCountryID),
        ]

        for booth in swedishBooths {
            try await booth.create(on: database)
        }

        let croatianBooths: [Booth] = [
            Booth(name: "Ćevapi Zagreb",
                  about: "Grilled minced-meat ćevapi served in warm flatbread with raw onion, ajvar and kajmak.",
                  pictureURL: "https://picsum.photos/seed/cevapi/800",
                  location: "Aisle J - Stand 11",
                  isVegan: false,
                  isPRM: true,
                  isFamilyFriendly: true,
                  allergens: [.cerealsContainingGluten, .milk],
                  startTime: .hourMinuteUTC(hour: 10, minute: 0),
                  endTime: .hourMinuteUTC(hour: 18, minute: 0),
                  status: .active,
                  countryID: hrCountryID),

            Booth(name: "Crni Rižot Dalmacija",
                  about: "Dalmatian black risotto with cuttlefish ink, finished with olive oil and white wine.",
                  pictureURL: "https://picsum.photos/seed/crnirizot/800",
                  location: "Aisle J - Stand 12",
                  isVegan: false,
                  isPRM: true,
                  isFamilyFriendly: false,
                  allergens: [.molluscs, .sulphurDioxideAndSulphites],
                  startTime: .hourMinuteUTC(hour: 11, minute: 30),
                  endTime: .hourMinuteUTC(hour: 15, minute: 30),
                  status: .active,
                  countryID: hrCountryID),
        ]

        for booth in croatianBooths {
            try await booth.create(on: database)
        }
    }

    private func removeBooths(on database: any Database) async throws {
        try await Booth.query(on: database).delete()
    }

    private func removeBoothCountries(on database: any Database) async throws {
        try await BoothCountryTranslation.query(on: database).delete()

        try await BoothCountry.query(on: database).delete()
    }

    private func addWorkshops(on database: any Database) async throws {
        let recipeCategory = Category(name: "Recipe")
        let cookingShowCategory = Category(name: "Cooking Show")
        let keynoteCategory = Category(name: "Keynote")
        let kidsFamilyCategory = Category(name: "Kids Family")
        let discoveryCategory = Category(name: "Discovery")

        try await recipeCategory.create(on: database)
        try await cookingShowCategory.create(on: database)
        try await keynoteCategory.create(on: database)
        try await kidsFamilyCategory.create(on: database)
        try await discoveryCategory.create(on: database)

        let recipeCategoryID = try recipeCategory.requireID()
        let cookingShowCategoryID = try cookingShowCategory.requireID()
        let keynoteCategoryID = try keynoteCategory.requireID()
        let kidsFamilyCategoryID = try kidsFamilyCategory.requireID()
        let discoveryCategoryID = try discoveryCategory.requireID()

        let recipeWorkshopInputs: [WorkshopInput] = [
            WorkshopInput(name: "A Journey Through Italian Cuisine",
                          startTime: .fromUTC(year: 2026, month: 11, day: 2, hour: 10, minute: 30),
                          endTime: .fromUTC(year: 2026, month: 11, day: 2, hour: 12, minute: 0),
                          capacityMax: 20,
                          description: "Discover the secrets of Italian cuisine: fresh pasta, traditional sauces and the story behind each region's recipes, with a tasting at the end of the workshop.",
                          pictureURL: "https://picsum.photos/seed/pasta/800",
                          location: "Kitchen Room, Hall A",
                          isVegan: false,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: recipeCategoryID),
            WorkshopInput(name: "Spanish Tapas and Jamón Ibérico",
                          startTime: .fromUTC(year: 2026, month: 11, day: 3, hour: 10, minute: 0),
                          endTime: .fromUTC(year: 2026, month: 11, day: 3, hour: 11, minute: 30),
                          capacityMax: 15,
                          description: "Learn how to prepare classic Spanish tapas, from tortilla española to patatas bravas, and discover how to carve and taste a real jamón ibérico.",
                          pictureURL: "https://picsum.photos/seed/jamon/800",
                          location: "Kitchen Room, Hall B",
                          isVegan: false,
                          isPRM: true,
                          isFamilyFriendly: false,
                          categoryID: recipeCategoryID),
            WorkshopInput(name: "French Pastry Masterclass",
                          startTime: .fromUTC(year: 2026, month: 11, day: 4, hour: 9, minute: 0),
                          endTime: .fromUTC(year: 2026, month: 11, day: 4, hour: 11, minute: 0),
                          capacityMax: 8,
                          description: "Master the basics of French pastry: choux dough, light éclairs and buttery croissants, guided step by step by a professional pastry chef.",
                          pictureURL: "https://picsum.photos/seed/croissant/800",
                          location: "Pastry Studio, Hall A",
                          isVegan: false,
                          isPRM: false,
                          isFamilyFriendly: true,
                          categoryID: recipeCategoryID),
            WorkshopInput(name: "Greek Mezze Without Meat",
                          startTime: .fromUTC(year: 2026, month: 11, day: 5, hour: 11, minute: 30),
                          endTime: .fromUTC(year: 2026, month: 11, day: 5, hour: 13, minute: 0),
                          capacityMax: 25,
                          description: "Prepare a colorful, fully plant-based Greek mezze table: hummus, dolmades, spanakopita with olive oil pastry and a fresh village salad.",
                          pictureURL: "https://picsum.photos/seed/olive/800",
                          location: "Garden Kitchen, Hall C",
                          isVegan: true,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: recipeCategoryID),
            WorkshopInput(name: "Authentic Portuguese Pastéis de Nata",
                          startTime: .fromUTC(year: 2026, month: 11, day: 6, hour: 12, minute: 0),
                          endTime: .fromUTC(year: 2026, month: 11, day: 6, hour: 13, minute: 30),
                          capacityMax: 15,
                          description: "Learn to prepare authentic Portuguese custard tarts with flaky pastry and a creamy filling, guided by a pastry specialist.",
                          pictureURL: "https://picsum.photos/seed/pasteis/800",
                          location: "Pastry Studio, Hall B",
                          isVegan: false,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: recipeCategoryID),
            WorkshopInput(name: "Handmade Polish Pierogi",
                          startTime: .fromUTC(year: 2026, month: 11, day: 7, hour: 11, minute: 0),
                          endTime: .fromUTC(year: 2026, month: 11, day: 7, hour: 12, minute: 30),
                          capacityMax: 20,
                          description: "Learn to roll, fill and fold traditional Polish pierogi, from the dough to classic fillings like potato and cheese or sauerkraut and mushrooms, then taste your own creations.",
                          pictureURL: "https://picsum.photos/seed/pierogi/800",
                          location: "Kitchen Room, Hall C",
                          isVegan: false,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: recipeCategoryID),
        ]

        for input in recipeWorkshopInputs {
            let workshop = input.toModel()
            try await workshop.create(on: database)

            let infos = try input.toInfos(workshopID: workshop.requireID())
            try await infos.create(on: database)
        }

        let cookingShowWorkshopInputs: [WorkshopInput] = [
            WorkshopInput(name: "European Sustainable Cooking Show",
                          startTime: .fromUTC(year: 2026, month: 11, day: 2, hour: 16, minute: 0),
                          endTime: .fromUTC(year: 2026, month: 11, day: 2, hour: 17, minute: 0),
                          capacityMax: 200,
                          description: "Watch European chefs cook live on stage with seasonal, plant-based and zero-waste ingredients, and discover sustainable techniques you can easily reuse at home.",
                          pictureURL: "https://picsum.photos/seed/sustainablecooking/800",
                          location: "Stage, Hall A",
                          isVegan: true,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: cookingShowCategoryID),
            WorkshopInput(name: "The Art of Mediterranean Gastronomy",
                          startTime: .fromUTC(year: 2026, month: 11, day: 4, hour: 14, minute: 30),
                          endTime: .fromUTC(year: 2026, month: 11, day: 4, hour: 15, minute: 30),
                          capacityMax: 180,
                          description: "A live cooking show celebrating Mediterranean cuisine, with vegetable-driven dishes built on olive oil, fresh herbs and sun-ripened produce, and the traditions behind each recipe.",
                          pictureURL: "https://picsum.photos/seed/mediterranean/800",
                          location: "Stage, Hall A",
                          isVegan: true,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: cookingShowCategoryID),
            WorkshopInput(name: "Traditional Recipes on Stage",
                          startTime: .fromUTC(year: 2026, month: 11, day: 5, hour: 16, minute: 30),
                          endTime: .fromUTC(year: 2026, month: 11, day: 5, hour: 17, minute: 30),
                          capacityMax: 180,
                          description: "Regional chefs bring Europe's heritage recipes to the stage, cooking plant-based versions of traditional dishes and sharing the family stories behind them.",
                          pictureURL: "https://picsum.photos/seed/traditional/800",
                          location: "Fashion Stage, Hall B",
                          isVegan: true,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: cookingShowCategoryID),
            WorkshopInput(name: "Young European Chefs",
                          startTime: .fromUTC(year: 2026, month: 11, day: 7, hour: 15, minute: 30),
                          endTime: .fromUTC(year: 2026, month: 11, day: 7, hour: 16, minute: 30),
                          capacityMax: 220,
                          description: "Meet the next generation of European chefs as they present bold plant-based dishes, experimental techniques and original takes on classic recipes.",
                          pictureURL: "https://picsum.photos/seed/youngchefs/800",
                          location: "Stage, Hall A",
                          isVegan: true,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: cookingShowCategoryID),
        ]

        for input in cookingShowWorkshopInputs {
            let workshop = input.toModel()
            try await workshop.create(on: database)

            let infos = try input.toInfos(workshopID: workshop.requireID())
            try await infos.create(on: database)
        }

        let keynoteWorkshopInputs: [WorkshopInput] = [
            WorkshopInput(name: "The Future of European Gastronomy",
                          startTime: .fromUTC(year: 2026, month: 11, day: 2, hour: 8, minute: 0),
                          endTime: .fromUTC(year: 2026, month: 11, day: 2, hour: 10, minute: 0),
                          capacityMax: 300,
                          description: "Opening keynote on the trends shaping European cuisine: sustainability, local sourcing and the new generation of chefs reinventing traditional recipes.",
                          pictureURL: "https://picsum.photos/seed/future/800",
                          location: "Main Stage, Hall A",
                          isVegan: false,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: keynoteCategoryID),
            WorkshopInput(name: "From Farm to Fork: Sustainable Food Systems",
                          startTime: .fromUTC(year: 2026, month: 11, day: 3, hour: 17, minute: 30),
                          endTime: .fromUTC(year: 2026, month: 11, day: 3, hour: 19, minute: 0),
                          capacityMax: 250,
                          description: "A talk on how short supply chains, seasonal produce and reduced food waste are changing the way Europe eats, with examples from small producers across the continent.",
                          pictureURL: "https://picsum.photos/seed/farm/800",
                          location: "Main Stage, Hall A",
                          isVegan: true,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: keynoteCategoryID),
            WorkshopInput(name: "Wine and Food Pairing Across Europe",
                          startTime: .fromUTC(year: 2026, month: 11, day: 6, hour: 10, minute: 0),
                          endTime: .fromUTC(year: 2026, month: 11, day: 6, hour: 11, minute: 0),
                          capacityMax: 200,
                          description: "A renowned sommelier explores the art of pairing wines with regional dishes, from Portuguese vinho verde to Hungarian Tokaji.",
                          pictureURL: "https://picsum.photos/seed/wine/800",
                          location: "Conference Room, Hall B",
                          isVegan: false,
                          isPRM: true,
                          isFamilyFriendly: false,
                          categoryID: keynoteCategoryID),
            WorkshopInput(name: "Culinary Heritage: Preserving Traditional Recipes",
                          startTime: .fromUTC(year: 2026, month: 11, day: 8, hour: 17, minute: 0),
                          endTime: .fromUTC(year: 2026, month: 11, day: 8, hour: 18, minute: 0),
                          capacityMax: 300,
                          description: "Closing keynote on the importance of documenting and passing on family and regional recipes, and how festivals like this one keep culinary traditions alive.",
                          pictureURL: "https://picsum.photos/seed/heritage/800",
                          location: "Main Stage, Hall A",
                          isVegan: false,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: keynoteCategoryID),
        ]

        for input in keynoteWorkshopInputs {
            let workshop = input.toModel()
            try await workshop.create(on: database)

            let infos = try input.toInfos(workshopID: workshop.requireID())
            try await infos.create(on: database)
        }

        let discoveryWorkshopInputs: [WorkshopInput] = [
            WorkshopInput(name: "Cheese Tasting Tour of Europe",
                          startTime: .fromUTC(year: 2026, month: 11, day: 3, hour: 13, minute: 0),
                          endTime: .fromUTC(year: 2026, month: 11, day: 3, hour: 14, minute: 0),
                          capacityMax: 30,
                          description: "Taste your way across the continent with a guided selection of cheeses: French comté, Dutch gouda, Italian pecorino and Swiss gruyère, each paired with the right bread and condiments.",
                          pictureURL: "https://picsum.photos/seed/cheese/800",
                          location: "Tasting Room, Hall B",
                          isVegan: false,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: discoveryCategoryID),
            WorkshopInput(name: "Scandinavian Smoked and Pickled Flavors",
                          startTime: .fromUTC(year: 2026, month: 11, day: 5, hour: 9, minute: 30),
                          endTime: .fromUTC(year: 2026, month: 11, day: 5, hour: 10, minute: 30),
                          capacityMax: 25,
                          description: "Discover the traditional preservation techniques of Northern Europe: cured salmon, pickled herring, rye bread and the rich flavors of the Nordic pantry.",
                          pictureURL: "https://picsum.photos/seed/salmon/800",
                          location: "Tasting Room, Hall C",
                          isVegan: false,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: discoveryCategoryID),
            WorkshopInput(name: "Central European Bread and Beer Pairing",
                          startTime: .fromUTC(year: 2026, month: 11, day: 6, hour: 14, minute: 30),
                          endTime: .fromUTC(year: 2026, month: 11, day: 6, hour: 15, minute: 30),
                          capacityMax: 30,
                          description: "Explore German, Czech and Belgian beer styles alongside freshly baked pretzels and regional breads, with tasting notes from a master brewer.",
                          pictureURL: "https://picsum.photos/seed/beer/800",
                          location: "Tasting Room, Hall B",
                          isVegan: true,
                          isPRM: true,
                          isFamilyFriendly: false,
                          categoryID: discoveryCategoryID),
            WorkshopInput(name: "Mediterranean Olive Oil and Honey Discovery",
                          startTime: .fromUTC(year: 2026, month: 11, day: 8, hour: 10, minute: 0),
                          endTime: .fromUTC(year: 2026, month: 11, day: 8, hour: 11, minute: 0),
                          capacityMax: 35,
                          description: "Learn to taste and compare olive oils from Greece, Spain and Italy, and discover the flavors of artisanal honeys from across the Mediterranean basin.",
                          pictureURL: "https://picsum.photos/seed/honey/800",
                          location: "Tasting Room, Hall C",
                          isVegan: false,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: discoveryCategoryID),
            WorkshopInput(name: "The Rise of Plant-Based European Cuisine",
                          startTime: .fromUTC(year: 2026, month: 11, day: 4, hour: 12, minute: 0),
                          endTime: .fromUTC(year: 2026, month: 11, day: 4, hour: 12, minute: 45),
                          capacityMax: 250,
                          description: "Explore how European chefs are reinventing traditional dishes with plant-based ingredients, sustainable techniques and innovative alternatives.",
                          pictureURL: "https://picsum.photos/seed/plantbased/800",
                          location: "Conference Room, Hall B",
                          isVegan: true,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: discoveryCategoryID),
            WorkshopInput(name: "European Coffee Culture and Roasting",
                          startTime: .fromUTC(year: 2026, month: 11, day: 7, hour: 9, minute: 0),
                          endTime: .fromUTC(year: 2026, month: 11, day: 7, hour: 10, minute: 0),
                          capacityMax: 30,
                          description: "Travel through Europe's coffee traditions, compare roasting profiles and discover how grind size, brewing methods and extraction influence the final cup.",
                          pictureURL: "https://picsum.photos/seed/coffee/800",
                          location: "Tasting Room, Hall A",
                          isVegan: true,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: discoveryCategoryID),
        ]

        for input in discoveryWorkshopInputs {
            let workshop = input.toModel()
            try await workshop.create(on: database)

            let infos = try input.toInfos(workshopID: workshop.requireID())
            try await infos.create(on: database)
        }

        let kidsFamilyWorkshopInputs: [WorkshopInput] = [
            WorkshopInput(name: "Kids' Baking: Decorate Your Own Cookies",
                          startTime: .fromUTC(year: 2026, month: 11, day: 2, hour: 14, minute: 0),
                          endTime: .fromUTC(year: 2026, month: 11, day: 2, hour: 15, minute: 0),
                          capacityMax: 16,
                          description: "A fun baking experience for children where little chefs decorate homemade cookies with colorful icing, sprinkles and creative designs.",
                          pictureURL: "https://picsum.photos/seed/kidscookies/800",
                          location: "Family Kitchen, Hall C",
                          isVegan: false,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: kidsFamilyCategoryID),
            WorkshopInput(name: "Little Chefs: Handmade Pizza",
                          startTime: .fromUTC(year: 2026, month: 11, day: 3, hour: 15, minute: 0),
                          endTime: .fromUTC(year: 2026, month: 11, day: 3, hour: 16, minute: 0),
                          capacityMax: 15,
                          description: "Children and their families learn to shape pizza dough, choose fresh toppings and prepare their own delicious Italian-style pizzas.",
                          pictureURL: "https://picsum.photos/seed/kidspizza/800",
                          location: "Family Kitchen, Hall A",
                          isVegan: false,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: kidsFamilyCategoryID),
            WorkshopInput(name: "Family Gingerbread Workshop",
                          startTime: .fromUTC(year: 2026, month: 11, day: 5, hour: 14, minute: 0),
                          endTime: .fromUTC(year: 2026, month: 11, day: 5, hour: 15, minute: 30),
                          capacityMax: 18,
                          description: "Families work together to bake and decorate gingerbread creations while discovering the sweet traditions of European festive baking.",
                          pictureURL: "https://picsum.photos/seed/gingerbread/800",
                          location: "Family Kitchen, Hall B",
                          isVegan: false,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: kidsFamilyCategoryID),
            WorkshopInput(name: "Junior Pastry Chefs",
                          startTime: .fromUTC(year: 2026, month: 11, day: 7, hour: 13, minute: 30),
                          endTime: .fromUTC(year: 2026, month: 11, day: 7, hour: 14, minute: 30),
                          capacityMax: 16,
                          description: "Young aspiring pastry chefs discover basic baking techniques and create simple sweet treats with guidance from an experienced instructor.",
                          pictureURL: "https://picsum.photos/seed/juniorpastry/800",
                          location: "Family Kitchen, Hall C",
                          isVegan: false,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: kidsFamilyCategoryID),
        ]

        for input in kidsFamilyWorkshopInputs {
            let workshop = input.toModel()
            try await workshop.create(on: database)

            let infos = try input.toInfos(workshopID: workshop.requireID())
            try await infos.create(on: database)
        }
    }

    private func removeWorkshops(on database: any Database) async throws {
        try await WorkshopInfos.query(on: database).delete()

        try await Workshop.query(on: database).delete()

        try await Category.query(on: database).delete()
    }

    private func addUsers(on database: any Database) async throws {
        // Admin user

        #warning("à retirer en production")
        let passwordHash = try Bcrypt.hash("Mot2Passe#12")

        let adminUser = User(name: "Hiroyuki Sawano",
                             email: "hiroyuki@sawano.jp",
                             passwordHash: passwordHash,
                             role: .admin)

        try await adminUser.create(on: database)

        let adminUserID = try adminUser.requireID()

        let adminUserInfos = UserInfos(status: .active,
                                       pictureURL: "https://api.dicebear.com/10.x/blobs/svg?seed=Hiroyuki&size=500",
                                       userID: adminUserID)

        try await adminUserInfos.create(on: database)

        // Staff
        let staffUser = User(name: "Takahiro Moriuchi",
                             email: "takahiro@moriuchi.jp",
                             passwordHash: passwordHash,
                             role: .staff)

        try await staffUser.create(on: database)

        let staffUserID = try staffUser.requireID()

        let staffUserInfos = UserInfos(status: .active,
                                       pictureURL: "https://api.dicebear.com/10.x/glyphs/png?seed=Taka&size=500",
                                       userID: staffUserID)

        try await staffUserInfos.create(on: database)

        // Other users

        // Festival Goer 1
        let goer1 = User(name: "Aka Hinawa",
                         email: "aka@hinawa.jp",
                         passwordHash: passwordHash,
                         role: .festivalGoer)

        try await goer1.create(on: database)

        let goer1ID = try goer1.requireID()

        let goer1Infos = UserInfos(status: .active,
                                   pictureURL: "https://picsum.photos/seed/aka/800",
                                   userID: goer1ID)

        try await goer1Infos.create(on: database)

        // Festival Goer 2
        let goer2 = User(name: "Suika Midori",
                         email: "suika@midori.jp",
                         passwordHash: passwordHash,
                         role: .festivalGoer)

        try await goer2.create(on: database)

        let goer2ID = try goer2.requireID()

        let goer2Infos = UserInfos(status: .active,
                                   pictureURL: "https://picsum.photos/seed/suika/800",
                                   userID: goer2ID)

        try await goer2Infos.create(on: database)

        // Festival Goer 3
        let goer3 = User(name: "Ringa Odori",
                         email: "ringa@odori.jp",
                         passwordHash: passwordHash,
                         role: .festivalGoer)

        try await goer3.create(on: database)

        let goer3ID = try goer3.requireID()

        let goer3Infos = UserInfos(status: .disabled,
                                   pictureURL: "https://picsum.photos/seed/ringa/800",
                                   userID: goer3ID)

        try await goer3Infos.create(on: database)

        // Staff 1
        let staff1 = User(name: "Myu Mikado",
                          email: "myu@mikado.jp",
                          passwordHash: passwordHash,
                          role: .staff)

        try await staff1.create(on: database)

        let staff1ID = try staff1.requireID()

        let staff1Infos = UserInfos(status: .active,
                                    pictureURL: "https://picsum.photos/seed/myu/800",
                                    userID: staff1ID)

        try await staff1Infos.create(on: database)

        // Staff 2
        let staff2 = User(name: "Claire Elisabeth de la Chance",
                          email: "claire.e.d.l.chance@example.com",
                          passwordHash: passwordHash,
                          role: .staff)

        try await staff2.create(on: database)

        let staff2ID = try staff2.requireID()

        let staff2Infos = UserInfos(status: .disabled,
                                    pictureURL: "https://picsum.photos/seed/claire/800",
                                    userID: staff2ID)

        try await staff2Infos.create(on: database)
    }

    private func removeUsers(on database: any Database) async throws {
        try await UserInfos.query(on: database).delete()

        try await User.query(on: database).delete()
    }

    private func addReservations(on database: any Database) async throws {
        #warning("à retirer en production")
        let passwordHash = try Bcrypt.hash("Mot2Passe#12")

        let userGoer1 = User(name: "Camille Martin", email: "camille.martin@example.com",
                             passwordHash: passwordHash, role: .festivalGoer)
        let userGoer2 = User(name: "John Doe", email: "john.doe@example.com",
                             passwordHash: passwordHash, role: .festivalGoer)

        try await userGoer1.create(on: database)
        try await userGoer2.create(on: database)

        let userGoerID1 = try userGoer1.requireID()
        let userGoerID2 = try userGoer2.requireID()

        let userGoerInfos1 = UserInfos(status: .active,
                                       pictureURL: "https://picsum.photos/id/189/800",
                                       userID: userGoerID1)
        let userGoerInfos2 = UserInfos(status: .active,
                                       pictureURL: "https://picsum.photos/id/189/800",
                                       userID: userGoerID2)

        try await userGoerInfos1.create(on: database)
        try await userGoerInfos2.create(on: database)

        let foodTastingCategory = Category(name: "Food Tasting")

        try await foodTastingCategory.create(on: database)

        let foodTastingCategoryID = try foodTastingCategory.requireID()

        let workshopInput1 = WorkshopInput(name: "The Art of French Pastry",
                                           startTime: .fromUTC(year: 2026, month: 11, day: 4,
                                                               hour: 16, minute: 0),
                                           endTime: .fromUTC(year: 2026, month: 11, day: 4,
                                                             hour: 17,
                                                             minute: 30),
                                           capacityMax: 15,
                                           description: "Explore the world of French pastry by learning the secrets behind classic croissants, éclairs and delicate pastries. Discover essential techniques and enjoy tasting your creations at the end of the workshop.",
                                           pictureURL: "https://picsum.photos/seed/frenchpastry/800",
                                           location: "Pastry Room, Hall B",
                                           isVegan: false,
                                           isPRM: true,
                                           isFamilyFriendly: true,
                                           categoryID: foodTastingCategoryID)

        let workshop1 = workshopInput1.toModel()
        try await workshop1.create(on: database)

        let infos1 = try workshopInput1.toInfos(workshopID: workshop1.requireID())
        try await infos1.create(on: database)

        let workshopInput2 = WorkshopInput(name: "A Taste of Spanish Tapas",
                                           startTime: .fromUTC(year: 2026, month: 11, day: 6,
                                                               hour: 16, minute: 0),
                                           endTime: .fromUTC(year: 2026, month: 11, day: 6,
                                                             hour: 17,
                                                             minute: 30),
                                           capacityMax: 20,
                                           description: "Discover the vibrant flavors of Spain through traditional tapas. Learn how to prepare patatas bravas, pan con tomate and other Spanish favorites while exploring the culinary traditions behind these iconic dishes.",
                                           pictureURL: "https://picsum.photos/seed/spanishtapas/800",
                                           location: "Cooking Room, Hall C",
                                           isVegan: false,
                                           isPRM: true,
                                           isFamilyFriendly: true,
                                           categoryID: foodTastingCategoryID)

        let workshop2 = workshopInput2.toModel()
        try await workshop2.create(on: database)

        let infos2 = try workshopInput2.toInfos(workshopID: workshop2.requireID())
        try await infos2.create(on: database)

        let workshopInput3 = WorkshopInput(name: "The Secrets of French Cheese",
                                           startTime: .fromUTC(year: 2026, month: 11, day: 8,
                                                               hour: 13, minute: 0),
                                           endTime: .fromUTC(year: 2026, month: 11, day: 8,
                                                             hour: 14,
                                                             minute: 0),
                                           capacityMax: 2,
                                           description: "Enjoy an intimate cheese-tasting experience and discover the secrets of French cheesemaking. Learn about regional specialties, explore different textures and flavors, and discover how to pair cheeses with complementary ingredients.",
                                           pictureURL: "https://picsum.photos/seed/frenchcheese/800",
                                           location: "Tasting Room, Hall A",
                                           isVegan: false,
                                           isPRM: true,
                                           isFamilyFriendly: true,
                                           categoryID: foodTastingCategoryID)

        let workshop3 = workshopInput3.toModel()
        try await workshop3.create(on: database)

        let infos3 = try workshopInput3.toInfos(workshopID: workshop3.requireID())
        try await infos3.create(on: database)

        // Workshop with one user
        let reservation1 = try Reservation(status: .confirmed, workshopID: workshop1.requireID(),
                                           userID: userGoerID1)

        // Workshop with several user
        let reservation2A = try Reservation(status: .confirmed, workshopID: workshop2.requireID(),
                                            userID: userGoerID1)
        let reservation2B = try Reservation(status: .cancelled, workshopID: workshop2.requireID(),
                                            userID: userGoerID2)

        // Workshop full
        let reservation3A = try Reservation(status: .pending, workshopID: workshop3.requireID(),
                                            userID: userGoerID1)
        let reservation3B = try Reservation(status: .confirmed, workshopID: workshop3.requireID(),
                                            userID: userGoerID2)

        try await reservation1.create(on: database)
        try await reservation2A.create(on: database)
        try await reservation2B.create(on: database)
        try await reservation3A.create(on: database)
        try await reservation3B.create(on: database)

        // Reservation with lots of Users

        let farmToForkCategory = Category(name: "Farm to Fork")
        try await farmToForkCategory.create(on: database)
        let farmToForkCategoryID = try farmToForkCategory.requireID()

        let workshopInputDay =
            WorkshopInput(name: "A Day on the Farm: Seasonal Cooking from Field to Plate",
                          startTime: .fromUTC(year: 2026, month: 11, day: 2,
                                              hour: 12, minute: 0),
                          endTime: .fromUTC(year: 2026, month: 11, day: 2,
                                            hour: 13, minute: 30),
                          capacityMax: 20,
                          description: "Meet a local farmer and learn how to turn fresh seasonal vegetables into a complete meal. Discover how to choose, store and cook produce at its peak, and how to cut food waste by using the whole vegetable, from root to leaf.",
                          pictureURL: "https://picsum.photos/seed/farmtofork/800",
                          location: "Kitchen, Hall C",
                          isVegan: true,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: farmToForkCategoryID)

        let workshopDay = workshopInputDay.toModel()
        try await workshopDay.create(on: database)
        let workshopDayID = try workshopDay.requireID()

        let infosDay = workshopInputDay.toInfos(workshopID: workshopDayID)
        try await infosDay.create(on: database)

        let faker = UserFaker()
        let usersForDay = faker.getUsers(count: 17)

        for fakeUser in usersForDay {
            let user = fakeUser.toUser(passwordHash: passwordHash,
                                       role: .festivalGoer)

            try await user.create(on: database)

            let userID = try user.requireID()

            let infos = fakeUser.toUserInfos(userID: userID,
                                             status: .active)
            try await infos.create(on: database)

            let reservation = Reservation(status: .confirmed,
                                          workshopID: workshopDayID,
                                          userID: userID)

            try await reservation.create(on: database)
        }
    }

    private func removeReservations(on database: any Database) async throws {
        try await Reservation.query(on: database).delete()
    }

    private func addBoothCountriesWithTranslations(on database: any Database,
                                                   code: String,
                                                   enTranslation: String,
                                                   frTranslation: String) async throws {
        let country = BoothCountry(code: code)
        try await country.create(on: database)

        let countryID = try country.requireID()

        let english = BoothCountryTranslation(locale: "en",
                                              name: enTranslation,
                                              countryID: countryID)
        let french = BoothCountryTranslation(locale: "fr",
                                             name: frTranslation,
                                             countryID: countryID)

        try await english.create(on: database)
        try await french.create(on: database)
    }
}

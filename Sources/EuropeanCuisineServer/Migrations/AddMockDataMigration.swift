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
        let france = BoothCountry(code: "FRA")
        let spain = BoothCountry(code: "ESP")

        try await france.create(on: database)
        try await spain.create(on: database)

        let frCountryID = try france.requireID()
        let esCountryID = try spain.requireID()

        let franceInFrench = BoothCountryTranslation(locale: "fr",
                                                     name: "France",
                                                     countryID: frCountryID)

        let franceInEnglish = BoothCountryTranslation(locale: "en",
                                                      name: "France",
                                                      countryID: frCountryID)

        let spainInFrench = BoothCountryTranslation(locale: "fr",
                                                    name: "Espagne",
                                                    countryID: esCountryID)

        let spainInEnglish = BoothCountryTranslation(locale: "en",
                                                     name: "Spain",
                                                     countryID: esCountryID)

        try await franceInFrench.create(on: database)
        try await franceInEnglish.create(on: database)
        try await spainInFrench.create(on: database)
        try await spainInEnglish.create(on: database)

        let frenchBooths: [Booth] = [
            Booth(name: "La Crêperie Bretonne",
                  description: "Crêpes and galettes made to order: ham and cheese, butter and sugar, salted caramel.",
                  pictureURL: "https://picsum.photos/seed/creperie/800",
                  location: "Aisle A - Stand 1",
                  isVegan: false,
                  isPRM: true,
                  isFamilyFriendly: true,
                  allergens: [.cerealsContainingGluten, .milk, .eggs],
                  startTime: .hourMinute(hour: 8, minute: 30),
                  endTime: .hourMinute(hour: 16, minute: 45),
                  status: .active,
                  countryID: frCountryID),

            Booth(name: "La Raclette Savoyarde",
                  description: "Melted raclette cheese served over potatoes, with cured meats and gherkins.",
                  pictureURL: "https://picsum.photos/seed/raclette/800",
                  location: "Aisle A - Stand 2",
                  isVegan: false,
                  isPRM: true,
                  isFamilyFriendly: true,
                  allergens: [.milk],
                  startTime: .hourMinute(hour: 9, minute: 30),
                  endTime: .hourMinute(hour: 17, minute: 30),
                  status: .active,
                  countryID: frCountryID),

            Booth(name: "Le Comptoir Provençal",
                  description: "Ratatouille, vegetable tian and socca made with fresh Southern vegetables. 100% plant-based.",
                  pictureURL: "https://picsum.photos/seed/ratatouille/800",
                  location: "Aisle B - Stand 3",
                  isVegan: true,
                  isPRM: true,
                  isFamilyFriendly: true,
                  allergens: [],
                  startTime: .hourMinute(hour: 8, minute: 0),
                  endTime: .hourMinute(hour: 16, minute: 0),
                  status: .active,
                  countryID: frCountryID),

            Booth(name: "Maison Macaron",
                  description: "Handmade macarons: raspberry, pistachio, dark chocolate, Madagascar vanilla and caramel.",
                  pictureURL: "https://picsum.photos/seed/macaron/800",
                  location: "Aisle B - Stand 4",
                  isVegan: false,
                  isPRM: false,
                  isFamilyFriendly: true,
                  allergens: [.nuts, .eggs, .milk],
                  startTime: .hourMinute(hour: 10, minute: 0),
                  endTime: .hourMinute(hour: 12, minute: 30),
                  status: .active,
                  countryID: frCountryID),

            Booth(name: "La Bouillabaisse Marseillaise",
                  description: "Traditional Provençal fish soup made with rockfish, served with croutons and homemade rouille.",
                  pictureURL: "https://picsum.photos/seed/bouillabaisse/800",
                  location: "Aisle C - Stand 5",
                  isVegan: false,
                  isPRM: true,
                  isFamilyFriendly: false,
                  allergens: [.fish, .crustaceans, .cerealsContainingGluten, .eggs],
                  startTime: .hourMinute(hour: 11, minute: 30),
                  endTime: .hourMinute(hour: 15, minute: 30),
                  status: .active,
                  countryID: frCountryID),

            Booth(name: "La Boulangerie Parisienne",
                  description: "Traditional baguettes, all-butter croissants, pains au chocolat and éclairs fresh from the oven.",
                  pictureURL: "https://picsum.photos/seed/boulangerie/800",
                  location: "Aisle C - Stand 6",
                  isVegan: false,
                  isPRM: true,
                  isFamilyFriendly: true,
                  allergens: [.cerealsContainingGluten, .milk, .eggs],
                  startTime: .hourMinute(hour: 9, minute: 0),
                  endTime: .hourMinute(hour: 17, minute: 0),
                  status: .active,
                  countryID: frCountryID),
        ]

        for booth in frenchBooths {
            try await booth.create(on: database)
        }

        let spanishBooths: [Booth] = [
            Booth(name: "La Tortilla de Patatas",
                  description: "Traditional Spanish omelette with potatoes and onions, served by the slice or as a pintxo.",
                  pictureURL: "https://picsum.photos/seed/tortilla/800",
                  location: "Aisle D - Stand 1",
                  isVegan: false,
                  isPRM: true,
                  isFamilyFriendly: true,
                  allergens: [.eggs],
                  startTime: .hourMinute(hour: 9, minute: 0),
                  endTime: .hourMinute(hour: 16, minute: 15),
                  status: .active,
                  countryID: esCountryID),

            Booth(name: "El Rincón de la Paella",
                  description: "Valencian paella cooked over a wood fire with chicken, rabbit, green beans and saffron.",
                  pictureURL: "https://picsum.photos/seed/paella/800",
                  location: "Aisle D - Stand 2",
                  isVegan: false,
                  isPRM: true,
                  isFamilyFriendly: true,
                  allergens: [],
                  startTime: .hourMinute(hour: 8, minute: 45),
                  endTime: .hourMinute(hour: 15, minute: 0),
                  status: .active,
                  countryID: esCountryID),

            Booth(name: "Churros y Chocolate",
                  description: "Crispy churros made to order, served with thick Spanish-style hot chocolate.",
                  pictureURL: "https://picsum.photos/seed/churros/800",
                  location: "Aisle D - Stand 3",
                  isVegan: false,
                  isPRM: true,
                  isFamilyFriendly: true,
                  allergens: [.cerealsContainingGluten, .milk],
                  startTime: .hourMinute(hour: 12, minute: 0),
                  endTime: .hourMinute(hour: 14, minute: 30),
                  status: .active,
                  countryID: esCountryID),

            Booth(name: "Gazpacho y Salmorejo",
                  description: "Andalusian cold soups made with ripe tomatoes, peppers and olive oil. 100% plant-based.",
                  pictureURL: "https://picsum.photos/seed/gazpacho/800",
                  location: "Aisle E - Stand 4",
                  isVegan: true,
                  isPRM: true,
                  isFamilyFriendly: true,
                  allergens: [.cerealsContainingGluten],
                  startTime: .hourMinute(hour: 10, minute: 30),
                  endTime: .hourMinute(hour: 15, minute: 30),
                  status: .active,
                  countryID: esCountryID),

            Booth(name: "Jamón & Tapas",
                  description: "Hand-carved Iberian ham, chorizo, Manchego cheese and pan con tomate.",
                  pictureURL: "https://picsum.photos/seed/jamon/800",
                  location: "Aisle E - Stand 5",
                  isVegan: false,
                  isPRM: false,
                  isFamilyFriendly: false,
                  allergens: [.cerealsContainingGluten, .milk],
                  startTime: .hourMinute(hour: 9, minute: 0),
                  endTime: .hourMinute(hour: 11, minute: 30),
                  status: .active,
                  countryID: esCountryID),

            Booth(name: "Pulpo a la Gallega",
                  description: " ian-style octopus with boiled potatoes, smoked paprika and olive oil.",
                  pictureURL: "https://picsum.photos/seed/pulpo/800",
                  location: "Aisle E - Stand 6",
                  isVegan: false,
                  isPRM: true,
                  isFamilyFriendly: false,
                  allergens: [.molluscs],
                  startTime: .hourMinute(hour: 10, minute: 30),
                  endTime: .hourMinute(hour: 15, minute: 45),
                  status: .active,
                  countryID: esCountryID),
        ]

        for booth in spanishBooths {
            try await booth.create(on: database)
        }
    }

    func revert(on database: any Database) async throws {
        try await database.schema(BoothCountryTranslation.schema)
            .delete()

        try await database.schema(BoothCountry.schema)
            .delete()

        try await database.schema(Booth.schema)
            .delete()
    }
}

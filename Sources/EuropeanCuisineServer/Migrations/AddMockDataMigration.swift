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
        try await addBooths(on: database)

        try await addWorkshops(on: database)
    }

    func revert(on database: any Database) async throws {
        try await removeBooths(on: database)

        try await removeWorkshops(on: database)
    }

    private func addBooths(on database: any Database) async throws {
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
                  about: "Crêpes and galettes made to order: ham and cheese, butter and sugar, salted caramel.",
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
                  about: "Melted raclette cheese served over potatoes, with cured meats and gherkins.",
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
                  about: "Ratatouille, vegetable tian and socca made with fresh Southern vegetables. 100% plant-based.",
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
                  about: "Handmade macarons: raspberry, pistachio, dark chocolate, Madagascar vanilla and caramel.",
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
                  about: "Traditional Provençal fish soup made with rockfish, served with croutons and homemade rouille.",
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
                  about: "Traditional baguettes, all-butter croissants, pains au chocolat and éclairs fresh from the oven.",
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
                  about: "Traditional Spanish omelette with potatoes and onions, served by the slice or as a pintxo.",
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
                  about: "Valencian paella cooked over a wood fire with chicken, rabbit, green beans and saffron.",
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
                  about: "Crispy churros made to order, served with thick Spanish-style hot chocolate.",
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
                  about: "Andalusian cold soups made with ripe tomatoes, peppers and olive oil. 100% plant-based.",
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
                  about: "Hand-carved Iberian ham, chorizo, Manchego cheese and pan con tomate.",
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
                  about: "Galician-style octopus with boiled potatoes, smoked paprika and olive oil.",
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

    private func removeBooths(on database: any Database) async throws {
        try await database.schema(Booth.schema)
            .delete()

        try await database.schema(BoothCountryTranslation.schema)
            .delete()

        try await database.schema(BoothCountry.schema)
            .delete()
    }

    private func addWorkshops(on database: any Database) async throws {
        let recipeCategory = Category(name: "Recipe")
        let keynoteCategory = Category(name: "Keynote")
        let discoveryCategory = Category(name: "Discovery")

        try await recipeCategory.create(on: database)
        try await keynoteCategory.create(on: database)
        try await discoveryCategory.create(on: database)

        let recipeCategoryID = try recipeCategory.requireID()
        let keynoteCategoryID = try keynoteCategory.requireID()
        let discoveryCategoryID = try discoveryCategory.requireID()

        let recipeWorkshopInputs: [WorkshopInput] = [
            WorkshopInput(name: "A Journey Through Italian Cuisine",
                          startTime: .from(year: 2026, month: 11, day: 14, hour: 10, minute: 0),
                          endTime: .from(year: 2026, month: 11, day: 14, hour: 11, minute: 30),
                          capacityMax: 20,
                          description: "Discover the secrets of Italian cuisine: fresh pasta, traditional sauces and the story behind each region's recipes, with a tasting at the end of the workshop.",
                          pictureURL: "https://picsum.photos/seed/pasta/800",
                          location: "Kitchen Room, Hall A",
                          isVegan: false,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: recipeCategoryID),
            WorkshopInput(name: "Spanish Tapas and Jamón Ibérico",
                          startTime: .from(year: 2026, month: 11, day: 14, hour: 14, minute: 0),
                          endTime: .from(year: 2026, month: 11, day: 14, hour: 15, minute: 30),
                          capacityMax: 15,
                          description: "Learn how to prepare classic Spanish tapas, from tortilla española to patatas bravas, and discover how to carve and taste a real jamón ibérico.",
                          pictureURL: "https://picsum.photos/seed/jamon/800",
                          location: "Kitchen Room, Hall B",
                          isVegan: false,
                          isPRM: true,
                          isFamilyFriendly: false,
                          categoryID: recipeCategoryID),
            WorkshopInput(name: "French Pastry Masterclass",
                          startTime: .from(year: 2026, month: 11, day: 15, hour: 9, minute: 0),
                          endTime: .from(year: 2026, month: 11, day: 15, hour: 11, minute: 0),
                          capacityMax: 12,
                          description: "Master the basics of French pastry: choux dough, light éclairs and buttery croissants, guided step by step by a professional pastry chef.",
                          pictureURL: "https://picsum.photos/seed/croissant/800",
                          location: "Pastry Studio, Hall A",
                          isVegan: false,
                          isPRM: false,
                          isFamilyFriendly: true,
                          categoryID: recipeCategoryID),
            WorkshopInput(name: "Greek Mezze Without Meat",
                          startTime: .from(year: 2026, month: 11, day: 15, hour: 15, minute: 0),
                          endTime: .from(year: 2026, month: 11, day: 15, hour: 16, minute: 30),
                          capacityMax: 25,
                          description: "Prepare a colorful, fully plant-based Greek mezze table: hummus, dolmades, spanakopita with olive oil pastry and a fresh village salad.",
                          pictureURL: "https://picsum.photos/seed/olive/800",
                          location: "Garden Kitchen, Hall C",
                          isVegan: true,
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

        let keynoteWorkshopInputs: [WorkshopInput] = [
            WorkshopInput(name: "The Future of European Gastronomy",
                          startTime: .from(year: 2026, month: 11, day: 14, hour: 9, minute: 0),
                          endTime: .from(year: 2026, month: 11, day: 14, hour: 9, minute: 45),
                          capacityMax: 300,
                          description: "Opening keynote on the trends shaping European cuisine: sustainability, local sourcing and the new generation of chefs reinventing traditional recipes.",
                          pictureURL: "https://picsum.photos/seed/future/800",
                          location: "Main Stage, Hall A",
                          isVegan: false,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: keynoteCategoryID),
            WorkshopInput(name: "From Farm to Fork: Sustainable Food Systems",
                          startTime: .from(year: 2026, month: 11, day: 14, hour: 13, minute: 0),
                          endTime: .from(year: 2026, month: 11, day: 14, hour: 14, minute: 0),
                          capacityMax: 250,
                          description: "A talk on how short supply chains, seasonal produce and reduced food waste are changing the way Europe eats, with examples from small producers across the continent.",
                          pictureURL: "https://picsum.photos/seed/farm/800",
                          location: "Main Stage, Hall A",
                          isVegan: true,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: keynoteCategoryID),
            WorkshopInput(name: "Wine and Food Pairing Across Europe",
                          startTime: .from(year: 2026, month: 11, day: 15, hour: 10, minute: 30),
                          endTime: .from(year: 2026, month: 11, day: 15, hour: 11, minute: 30),
                          capacityMax: 200,
                          description: "A renowned sommelier explores the art of pairing wines with regional dishes, from Portuguese vinho verde to Hungarian Tokaji.",
                          pictureURL: "https://picsum.photos/seed/wine/800",
                          location: "Conference Room, Hall B",
                          isVegan: false,
                          isPRM: true,
                          isFamilyFriendly: false,
                          categoryID: keynoteCategoryID),
            WorkshopInput(name: "Culinary Heritage: Preserving Traditional Recipes",
                          startTime: .from(year: 2026, month: 11, day: 15, hour: 16, minute: 0),
                          endTime: .from(year: 2026, month: 11, day: 15, hour: 17, minute: 0),
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
                          startTime: .from(year: 2026, month: 11, day: 14, hour: 11, minute: 0),
                          endTime: .from(year: 2026, month: 11, day: 14, hour: 12, minute: 0),
                          capacityMax: 30,
                          description: "Taste your way across the continent with a guided selection of cheeses: French comté, Dutch gouda, Italian pecorino and Swiss gruyère, each paired with the right bread and condiments.",
                          pictureURL: "https://picsum.photos/seed/cheese/800",
                          location: "Tasting Room, Hall B",
                          isVegan: false,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: discoveryCategoryID),
            WorkshopInput(name: "Scandinavian Smoked and Pickled Flavors",
                          startTime: .from(year: 2026, month: 11, day: 14, hour: 15, minute: 30),
                          endTime: .from(year: 2026, month: 11, day: 14, hour: 16, minute: 30),
                          capacityMax: 25,
                          description: "Discover the traditional preservation techniques of Northern Europe: cured salmon, pickled herring, rye bread and the rich flavors of the Nordic pantry.",
                          pictureURL: "https://picsum.photos/seed/salmon/800",
                          location: "Tasting Room, Hall C",
                          isVegan: false,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: discoveryCategoryID),
            WorkshopInput(name: "Central European Bread and Beer Pairing",
                          startTime: .from(year: 2026, month: 11, day: 15, hour: 11, minute: 30),
                          endTime: .from(year: 2026, month: 11, day: 15, hour: 12, minute: 30),
                          capacityMax: 30,
                          description: "Explore German, Czech and Belgian beer styles alongside freshly baked pretzels and regional breads, with tasting notes from a master brewer.",
                          pictureURL: "https://picsum.photos/seed/beer/800",
                          location: "Tasting Room, Hall B",
                          isVegan: true,
                          isPRM: true,
                          isFamilyFriendly: false,
                          categoryID: discoveryCategoryID),
            WorkshopInput(name: "Mediterranean Olive Oil and Honey Discovery",
                          startTime: .from(year: 2026, month: 11, day: 15, hour: 14, minute: 0),
                          endTime: .from(year: 2026, month: 11, day: 15, hour: 15, minute: 0),
                          capacityMax: 35,
                          description: "Learn to taste and compare olive oils from Greece, Spain and Italy, and discover the flavors of artisanal honeys from across the Mediterranean basin.",
                          pictureURL: "https://picsum.photos/seed/honey/800",
                          location: "Tasting Room, Hall C",
                          isVegan: false,
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
    }

    private func removeWorkshops(on database: any Database) async throws {
        try await database.schema(WorkshopInfos.schema)
            .delete()

        try await database.schema(Workshop.schema)
            .delete()

        try await database.schema(Category.schema)
            .delete()
    }
}

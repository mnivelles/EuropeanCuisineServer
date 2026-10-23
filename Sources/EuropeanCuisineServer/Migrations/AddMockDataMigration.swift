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

        try await addUsers(on: database)

        try await addReservations(on: database)
    }

    func revert(on database: any Database) async throws {
        try await removeBooths(on: database)

        try await removeWorkshops(on: database)

        try await removeUsers(on: database)

        try await removeReservations(on: database)
    }

    private func addBooths(on database: any Database) async throws {
        let france = BoothCountry(code: "FRA")
        let spain = BoothCountry(code: "ESP")
        let greece = BoothCountry(code: "GRC")

        try await france.create(on: database)
        try await spain.create(on: database)
        try await greece.create(on: database)

        let frCountryID = try france.requireID()
        let esCountryID = try spain.requireID()
        let grCountryID = try greece.requireID()

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

        let greeceInFrench = BoothCountryTranslation(locale: "fr",
                                                     name: "Grèce",
                                                     countryID: grCountryID)

        let greeceInEnglish = BoothCountryTranslation(locale: "en",
                                                      name: "Greece",
                                                      countryID: grCountryID)

        try await franceInFrench.create(on: database)
        try await franceInEnglish.create(on: database)
        try await spainInFrench.create(on: database)
        try await spainInEnglish.create(on: database)
        try await greeceInFrench.create(on: database)
        try await greeceInEnglish.create(on: database)

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
                  location: "Aisle D - Stand 1",
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
                  location: "Aisle D - Stand 2",
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
                  location: "Aisle D - Stand 3",
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
                  location: "Aisle E - Stand 4",
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
                  location: "Aisle E - Stand 5",
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
    }

    private func removeBooths(on database: any Database) async throws {
        try await Booth.query(on: database).delete()

        try await BoothCountryTranslation.query(on: database).delete()

        try await BoothCountry.query(on: database).delete()
    }

    private func addWorkshops(on database: any Database) async throws {
        let recipeCategory = Category(name: "Recipe")
        let fashionShowCategory = Category(name: "Fashion Show")
        let keynoteCategory = Category(name: "Keynote")
        let kidsFamilyCategory = Category(name: "Kids Family")
        let discoveryCategory = Category(name: "Discovery")

        try await recipeCategory.create(on: database)
        try await fashionShowCategory.create(on: database)
        try await keynoteCategory.create(on: database)
        try await kidsFamilyCategory.create(on: database)
        try await discoveryCategory.create(on: database)

        let recipeCategoryID = try recipeCategory.requireID()
        let fashionShowCategoryID = try fashionShowCategory.requireID()
        let keynoteCategoryID = try keynoteCategory.requireID()
        let kidsFamilyCategoryID = try kidsFamilyCategory.requireID()
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
                          capacityMax: 8,
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
            WorkshopInput(name: "Authentic Portuguese Pastéis de Nata",
                          startTime: .from(year: 2026, month: 11, day: 14, hour: 16, minute: 0),
                          endTime: .from(year: 2026, month: 11, day: 14, hour: 17, minute: 30),
                          capacityMax: 15,
                          description: "Learn to prepare authentic Portuguese custard tarts with flaky pastry and a creamy filling, guided by a pastry specialist.",
                          pictureURL: "https://picsum.photos/seed/pasteis/800",
                          location: "Pastry Studio, Hall B",
                          isVegan: false,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: recipeCategoryID),
            WorkshopInput(name: "Handmade Japanese Ramen",
                          startTime: .from(year: 2026, month: 11, day: 14, hour: 12, minute: 0),
                          endTime: .from(year: 2026, month: 11, day: 14, hour: 13, minute: 30),
                          capacityMax: 20,
                          description: "Discover the fundamentals of Japanese ramen, from preparing a flavorful broth to assembling noodles and traditional toppings.",
                          pictureURL: "https://picsum.photos/seed/ramen/800",
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

        let fashionShowWorkshopInputs: [WorkshopInput] = [
            WorkshopInput(name: "European Sustainable Fashion Show",
                          startTime: .from(year: 2026, month: 11, day: 14, hour: 10, minute: 0),
                          endTime: .from(year: 2026, month: 11, day: 14, hour: 11, minute: 0),
                          capacityMax: 200,
                          description: "Discover contemporary European designers presenting collections made with sustainable materials, ethical production methods and innovative designs.",
                          pictureURL: "https://picsum.photos/seed/sustainablefashion/800",
                          location: "Fashion Stage, Hall A",
                          isVegan: true,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: fashionShowCategoryID),
            WorkshopInput(name: "The Art of Mediterranean Couture",
                          startTime: .from(year: 2026, month: 11, day: 14, hour: 14, minute: 30),
                          endTime: .from(year: 2026, month: 11, day: 14, hour: 15, minute: 30),
                          capacityMax: 180,
                          description: "Experience a runway celebration of Mediterranean fashion, combining traditional craftsmanship, elegant silhouettes and contemporary design.",
                          pictureURL: "https://picsum.photos/seed/couture/800",
                          location: "Fashion Stage, Hall A",
                          isVegan: true,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: fashionShowCategoryID),
            WorkshopInput(name: "Traditional Textiles on the Runway",
                          startTime: .from(year: 2026, month: 11, day: 15, hour: 11, minute: 0),
                          endTime: .from(year: 2026, month: 11, day: 15, hour: 12, minute: 0),
                          capacityMax: 180,
                          description: "Explore European textile heritage through a fashion show featuring traditional embroidery, regional fabrics and modern interpretations of historic garments.",
                          pictureURL: "https://picsum.photos/seed/textilerunway/800",
                          location: "Fashion Stage, Hall B",
                          isVegan: true,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: fashionShowCategoryID),
            WorkshopInput(name: "Young European Designers",
                          startTime: .from(year: 2026, month: 11, day: 15, hour: 14, minute: 0),
                          endTime: .from(year: 2026, month: 11, day: 15, hour: 15, minute: 0),
                          capacityMax: 220,
                          description: "Meet the next generation of European fashion talent through a runway showcase of bold concepts, experimental materials and original collections.",
                          pictureURL: "https://picsum.photos/seed/youngdesigners/800",
                          location: "Fashion Stage, Hall A",
                          isVegan: true,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: fashionShowCategoryID),
        ]

        for input in fashionShowWorkshopInputs {
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
            WorkshopInput(name: "The Rise of Plant-Based European Cuisine",
                          startTime: .from(year: 2026, month: 11, day: 14, hour: 10, minute: 0),
                          endTime: .from(year: 2026, month: 11, day: 14, hour: 10, minute: 45),
                          capacityMax: 250,
                          description: "Explore how European chefs are reinventing traditional dishes with plant-based ingredients, sustainable techniques and innovative alternatives.",
                          pictureURL: "https://picsum.photos/seed/plantbased/800",
                          location: "Conference Room, Hall B",
                          isVegan: true,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: keynoteCategoryID),
            WorkshopInput(name: "European Coffee Culture and Roasting",
                          startTime: .from(year: 2026, month: 11, day: 15, hour: 10, minute: 0),
                          endTime: .from(year: 2026, month: 11, day: 15, hour: 11, minute: 0),
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
                          startTime: .from(year: 2026, month: 11, day: 14, hour: 11, minute: 0),
                          endTime: .from(year: 2026, month: 11, day: 14, hour: 12, minute: 0),
                          capacityMax: 16,
                          description: "A fun baking experience for children where little chefs decorate homemade cookies with colorful icing, sprinkles and creative designs.",
                          pictureURL: "https://picsum.photos/seed/kidscookies/800",
                          location: "Family Kitchen, Hall C",
                          isVegan: false,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: kidsFamilyCategoryID),
            WorkshopInput(name: "Little Chefs: Handmade Pizza",
                          startTime: .from(year: 2026, month: 11, day: 14, hour: 15, minute: 0),
                          endTime: .from(year: 2026, month: 11, day: 14, hour: 16, minute: 0),
                          capacityMax: 15,
                          description: "Children and their families learn to shape pizza dough, choose fresh toppings and prepare their own delicious Italian-style pizzas.",
                          pictureURL: "https://picsum.photos/seed/kidspizza/800",
                          location: "Family Kitchen, Hall A",
                          isVegan: false,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: kidsFamilyCategoryID),
            WorkshopInput(name: "Family Gingerbread Workshop",
                          startTime: .from(year: 2026, month: 11, day: 15, hour: 10, minute: 0),
                          endTime: .from(year: 2026, month: 11, day: 15, hour: 11, minute: 30),
                          capacityMax: 18,
                          description: "Families work together to bake and decorate gingerbread creations while discovering the sweet traditions of European festive baking.",
                          pictureURL: "https://picsum.photos/seed/gingerbread/800",
                          location: "Family Kitchen, Hall B",
                          isVegan: false,
                          isPRM: true,
                          isFamilyFriendly: true,
                          categoryID: kidsFamilyCategoryID),
            WorkshopInput(name: "Junior Pastry Chefs",
                          startTime: .from(year: 2026, month: 11, day: 15, hour: 13, minute: 0),
                          endTime: .from(year: 2026, month: 11, day: 15, hour: 14, minute: 0),
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
        #warning("à retirer en production")
        let passwordHash = try Bcrypt.hash("Mot2Passe#12")

        let user = User(name: "Hiroyuki Sawano",
                        email: "hiroyuki@sawano.jp",
                        passwordHash: passwordHash,
                        role: .admin)

        try await user.create(on: database)

        let userID = try user.requireID()

        let infos = UserInfos(status: .active,
                              pictureURL: "https://picsum.photos/id/189/800",
                              userID: userID)

        try await infos.create(on: database)
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

        let blogCategory = Category(name: "Blog")

        try await blogCategory.create(on: database)

        let blogCategoryID = try blogCategory.requireID()

        let workshopInput1 = WorkshopInput(name: "The Art of French Pastry",
                                           startTime: .from(year: 2026, month: 11, day: 14,
                                                            hour: 14, minute: 0),
                                           endTime: .from(year: 2026, month: 11, day: 14, hour: 15,
                                                          minute: 30),
                                           capacityMax: 15,
                                           description: "Explore the world of French pastry by learning the secrets behind classic croissants, éclairs and delicate pastries. Discover essential techniques and enjoy tasting your creations at the end of the workshop.",
                                           pictureURL: "https://picsum.photos/seed/frenchpastry/800",
                                           location: "Pastry Room, Hall B",
                                           isVegan: false,
                                           isPRM: true,
                                           isFamilyFriendly: true,
                                           categoryID: blogCategoryID)

        let workshop1 = workshopInput1.toModel()
        try await workshop1.create(on: database)

        let infos1 = try workshopInput1.toInfos(workshopID: workshop1.requireID())
        try await infos1.create(on: database)

        let workshopInput2 = WorkshopInput(name: "A Taste of Spanish Tapas",
                                           startTime: .from(year: 2026, month: 11, day: 15,
                                                            hour: 11, minute: 0),
                                           endTime: .from(year: 2026, month: 11, day: 15, hour: 12,
                                                          minute: 30),
                                           capacityMax: 20,
                                           description: "Discover the vibrant flavors of Spain through traditional tapas. Learn how to prepare patatas bravas, pan con tomate and other Spanish favorites while exploring the culinary traditions behind these iconic dishes.",
                                           pictureURL: "https://picsum.photos/seed/spanishtapas/800",
                                           location: "Cooking Room, Hall C",
                                           isVegan: false,
                                           isPRM: true,
                                           isFamilyFriendly: true,
                                           categoryID: blogCategoryID)

        let workshop2 = workshopInput2.toModel()
        try await workshop2.create(on: database)

        let infos2 = try workshopInput2.toInfos(workshopID: workshop2.requireID())
        try await infos2.create(on: database)

        let workshopInput3 = WorkshopInput(name: "The Secrets of French Cheese",
                                           startTime: .from(year: 2026, month: 11, day: 15,
                                                            hour: 14, minute: 0),
                                           endTime: .from(year: 2026, month: 11, day: 15, hour: 15,
                                                          minute: 0),
                                           capacityMax: 2,
                                           description: "Enjoy an intimate cheese-tasting experience and discover the secrets of French cheesemaking. Learn about regional specialties, explore different textures and flavors, and discover how to pair cheeses with complementary ingredients.",
                                           pictureURL: "https://picsum.photos/seed/frenchcheese/800",
                                           location: "Tasting Room, Hall A",
                                           isVegan: false,
                                           isPRM: true,
                                           isFamilyFriendly: true,
                                           categoryID: blogCategoryID)

        let workshop3 = workshopInput3.toModel()
        try await workshop3.create(on: database)

        let infos3 = try workshopInput3.toInfos(workshopID: workshop3.requireID())
        try await infos3.create(on: database)

        // Workshop with one user
        let reservation1 = try Reservation(status: .confirmed, workshopID: workshop1.requireID(),
                                           userID: userGoerID1)

        // Workshop with several user
        let reservation2A = try Reservation(status: .pending, workshopID: workshop2.requireID(),
                                            userID: userGoerID1)
        let reservation2B = try Reservation(status: .confirmed, workshopID: workshop2.requireID(),
                                            userID: userGoerID2)

        // Workshop full
        let reservation3A = try Reservation(status: .confirmed, workshopID: workshop3.requireID(),
                                            userID: userGoerID1)
        let reservation3B = try Reservation(status: .cancelled, workshopID: workshop3.requireID(),
                                            userID: userGoerID2)

        try await reservation1.create(on: database)
        try await reservation2A.create(on: database)
        try await reservation2B.create(on: database)
        try await reservation3A.create(on: database)
        try await reservation3B.create(on: database)
    }

    private func removeReservations(on database: any Database) async throws {
        try await Reservation.query(on: database).delete()
    }
}

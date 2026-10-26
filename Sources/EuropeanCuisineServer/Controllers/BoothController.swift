//
//  BoothController.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 10/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Fluent
import Vapor

struct BoothController: RouteCollection {
    private let imageFolder = "booths"

    func boot(routes: any RoutesBuilder) throws {
        let api = routes.grouped("api", "v0")

        #warning("retirer dans Public : post, put et delete")

        // Public
        let publicBooths = api.grouped("booths")
        publicBooths.get(use: list)
        publicBooths.post(use: create) // FIXME: TO DELETE

        publicBooths.group(":id") { booth in
            booth.get(use: show)
            booth.put(use: update) // FIXME: TO DELETE
            booth.delete(use: delete) // FIXME: TO DELETE
        }

        // Admin site - Role = admin || staff
        let adminBooths = api
            .grouped("admin", "booths")
            .requiring(.admin, .staff)
        adminBooths.get(use: adminTableList)
        adminBooths.on(.POST,
                       body: .collect(maxSize: Constants.Image.requestMaxSize),
                       use: adminCreate)

        adminBooths.group(":id") { booth in
            booth.get(use: adminShow)
            booth.on(.PUT,
                     body: .collect(maxSize: Constants.Image.requestMaxSize),
                     use: adminUpdate)
            booth.patch("enable", use: adminEnableBooth)
            booth.patch("disable", use: adminDisableBooth)
        }
    }

    private func list(req: Request) async throws -> [BoothOutput] {
        let locale = LocalizationUtils.getLocale(req: req)

        let booths = try await Booth.query(on: req.db)
            .filter(\.$status == .active)
            .with(\.$country) { country in
                country
                    .with(\.$translations)
            }
            .sort(\.$name, .ascending)
            .all()

        return try booths.map { booth in
            let countryName = LocalizationUtils.getCountryName(from: booth.country.translations,
                                                               locale: locale)

            return try BoothOutput(booth, countryName: countryName)
        }
    }

    private func adminTableList(req: Request) async throws -> Page<AdminBoothListItemOutput> {
        let locale = LocalizationUtils.getLocale(req: req)
        let input = try req.query.decode(AdminBoothListSortSearchInput.self)

        let query = Booth.query(on: req.db)
            .join(BoothCountry.self, on: \Booth.$country.$id == \BoothCountry.$id)
            .join(BoothCountryTranslation.self,
                  on: \BoothCountryTranslation.$country.$id == \BoothCountry.$id)
            .filter(BoothCountryTranslation.self, \.$locale == locale)
            .with(\.$country) { country in
                country
                    .with(\.$translations)
            }

        if let searchText = input.query,
           searchText.trimmed.isNotEmpty {
            query
                .filter(\.$name ~~ searchText.trimmed)
        }

        if let status = input.status {
            switch status {
            case .enabled:
                query
                    .filter(\.$status == .active)
            case .disabled:
                query
                    .filter(\.$status == .disabled)
            }
        }

        if let sort = input.sort {
            switch sort {
            case .name:
                query
                    .sort(\.$name, .ascending)
            case .location:
                query
                    .sort(\.$location, .ascending)
                    .sort(\.$name, .ascending)
            case .country:
                query
                    .sort(BoothCountryTranslation.self, \.$name, .ascending)
                    .sort(\.$name, .ascending)
            case .createdAt:
                query
                    .sort(\.$createdAt, .descending)
            case .updatedAt:
                query
                    .sort(\.$updatedAt, .descending)
            }
        } else {
            query
                .sort(\.$name, .ascending)
        }

        let booths = try await query
            .paginate(for: req)

        return try booths.map { booth in
            let countryName = LocalizationUtils.getCountryName(from: booth.country.translations,
                                                               locale: locale)

            return try AdminBoothListItemOutput(booth,
                                                countryName: countryName,
                                                locale: locale)
        }
    }

    private func create(req: Request) async throws -> Response {
        let locale = LocalizationUtils.getLocale(req: req)

        try BoothInput.validate(content: req)

        let input = try req.content.decode(BoothInput.self)

        guard try await Booth.query(on: req.db)
            .filter(\.$name == input.name.trimmed).first() == nil else {
            throw BoothError.alreadyExists
        }

        guard try await BoothCountry
            .query(on: req.db)
            .filter(\.$id == input.countryID)
            .first() != nil else {
            throw BoothCountryError.notFound
        }

        let booth = input.toModel(status: .active)

        try await booth.create(on: req.db)

        try await booth.$country.load(on: req.db)
        try await booth.country.$translations.load(on: req.db)

        let countryName = LocalizationUtils.getCountryName(from: booth.country.translations,
                                                           locale: locale)

        return try await BoothOutput(booth, countryName: countryName)
            .encodeResponse(status: .created, for: req)
    }

    private func adminCreate(req: Request) async throws -> Response {
        let locale = LocalizationUtils.getLocale(req: req)

        try AdminCreateBoothInput.validate(content: req)

        let input = try req.content.decode(AdminCreateBoothInput.self)
        let picture = input.picture

        guard try await Booth.query(on: req.db)
            .filter(\.$name == input.name.trimmed).first() == nil else {
            throw BoothError.alreadyExists
        }

        guard let country = try await BoothCountry
            .query(on: req.db)
            .filter(\.$code == input.country)
            .first() else {
            throw BoothCountryError.notFound
        }

        let booth = try input.toModel(status: .active,
                                      pictureURL: "https://picsum.photos/seed/void/800",
                                      countryID: country.requireID())

        return try await req.db.transaction { db in
            try await booth.create(on: db)

            let storage = ImageStorage()

            let url = try await storage.upload(req: req,
                                               file: picture,
                                               folder: imageFolder,
                                               id: booth.requireID())

            booth.pictureURL = url.absoluteString

            try await booth.update(on: db)

            try await booth.$country.load(on: db)
            try await booth.country.$translations.load(on: db)

            let countryName = LocalizationUtils.getCountryName(from: booth.country.translations,
                                                               locale: locale)

            return try await AdminBoothListItemOutput(booth,
                                                      countryName: countryName,
                                                      locale: locale)
                .encodeResponse(status: .created, for: req)
        }
    }

    private func show(req: Request) async throws -> BoothOutput {
        let locale = LocalizationUtils.getLocale(req: req)

        let booth = try await findBooth(req: req)

        guard booth.status == .active else {
            throw BoothError.disabled
        }

        let countryName = LocalizationUtils.getCountryName(from: booth.country.translations,
                                                           locale: locale)

        return try BoothOutput(booth, countryName: countryName)
    }

    private func update(req: Request) async throws -> BoothOutput {
        let locale = LocalizationUtils.getLocale(req: req)

        try BoothInput.validate(content: req)

        let input = try req.content.decode(BoothInput.self)

        let booth = try await findBooth(req: req)

        guard try await Booth.query(on: req.db)
            .filter(\.$name == input.name.trimmed).first() == nil
            || (input.name.trimmed == booth.name.trimmed) else {
            throw BoothError.alreadyExists
        }

        guard try await BoothCountry.query(on: req.db)
            .filter(\.$id == input.countryID)
            .first() != nil else {
            throw BoothCountryError.notFound
        }

        apply(input: input, to: booth)

        try await booth.update(on: req.db)

        let countryName = LocalizationUtils.getCountryName(from: booth.country.translations,
                                                           locale: locale)

        return try BoothOutput(booth, countryName: countryName)
    }

    private func adminShow(req: Request) async throws -> AdminShowBoothOutput {
        let booth = try await findBooth(req: req)

        return try AdminShowBoothOutput(booth)
    }

    private func adminUpdate(req: Request) async throws -> AdminShowBoothOutput {
        try AdminUpdateBoothInput.validate(content: req)

        let input = try req.content.decode(AdminUpdateBoothInput.self)

        let booth = try await findBooth(req: req)

        guard booth.status == .active else {
            throw BoothError.disabled
        }

        guard let country = try await BoothCountry
            .query(on: req.db)
            .filter(\.$code == input.country)
            .first() else {
            throw BoothCountryError.notFound
        }

        return try await req.db.transaction { db in
            apply(input: input, to: booth)

            booth.$country.id = try country.requireID()
            booth.$country.value = country

            if let picture = input.picture {
                let storage = ImageStorage()

                let url = try await storage.upload(req: req,
                                                   file: picture,
                                                   folder: imageFolder,
                                                   id: booth.requireID())

                booth.pictureURL = url.absoluteString
            }

            try await booth.update(on: db)

            return try AdminShowBoothOutput(booth)
        }
    }

    private func delete(req: Request) async throws -> HTTPStatus {
        let booth = try await findBooth(req: req)

        try await booth.delete(on: req.db)

        return .noContent
    }

    private func adminDisableBooth(req: Request) async throws -> HTTPStatus {
        let booth = try await findBooth(req: req)

        guard booth.status == .active else {
            throw BoothError.invalidAction
        }

        booth.status = .disabled
        try await booth.update(on: req.db)

        return .noContent
    }

    private func adminEnableBooth(req: Request) async throws -> HTTPStatus {
        let booth = try await findBooth(req: req)

        guard booth.status == .disabled else {
            throw BoothError.invalidAction
        }

        booth.status = .active
        try await booth.update(on: req.db)

        return .noContent
    }

    private func findBooth(req: Request) async throws -> Booth {
        let id = try req.parameters.require("id", as: UUID.self)

        let booth = try await Booth
            .query(on: req.db)
            .filter(\.$id == id)
            .with(\.$country) { country in
                country
                    .with(\.$translations)
            }
            .first()

        guard let booth else {
            throw BoothError.notFound
        }

        return booth
    }

    private func apply(input: BoothInput, to booth: Booth) {
        booth.name = input.name.trimmed
        booth.about = input.about.trimmed
        booth.pictureURL = input.pictureURL.trimmed
        booth.location = input.location.trimmed
        booth.isVegan = input.isVegan
        booth.isPRM = input.isPRM
        booth.isFamilyFriendly = input.isFamilyFriendly
        booth.allergens = input.allergens
        booth.startTime = input.startTime
        booth.endTime = input.endTime
        booth.$country.id = input.countryID
    }

    private func apply(input: AdminUpdateBoothInput, to booth: Booth) {
        booth.name = input.name
        booth.location = input.location
        booth.startTime = input.startTime
        booth.endTime = input.endTime
        booth.about = input.about
        booth.allergens = Set(input.allergens)
        booth.isVegan = input.isVegan
        booth.isPRM = input.isPRM
        booth.isFamilyFriendly = input.isFamilyFriendly
    }
}

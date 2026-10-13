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
    private let defaultLocale: String = "en"

    func boot(routes: any RoutesBuilder) throws {
        let booths = routes.grouped("api", "v0", "booths")

        booths.get(use: list)
        booths.post(use: create)

        booths.group(":id") { booth in
            booth.get(use: show)
            booth.put(use: update)
            booth.delete(use: delete)
        }
    }

    private func list(req: Request) async throws -> [BoothOutput] {
        let locale = getLocale(req: req) ?? defaultLocale

        let booths = try await Booth.query(on: req.db)
            .with(\.$country) { country in
                country
                    .with(\.$translations)
            }
            .all()

        return try booths.map { booth in
            let countryName = booth.country.translations.filter { $0.locale == locale }.first?
                .name ?? "No country name"

            return try BoothOutput(booth, countryName: countryName)
        }
    }

    private func create(req: Request) async throws -> Response {
        try BoothInput.validate(content: req)

        let input = try req.content.decode(BoothInput.self)

        guard try await Booth.query(on: req.db)
            .filter(\.$name == input.name).first() == nil else {
            throw BoothError.alreadyExists
        }

        guard try await BoothCountry.query(on: req.db)
            .filter(\.$id == input.countryID)
            .first() != nil else {
            throw BoothCountryError.notFound
        }

        let booth = input.toModel(status: .active)

        try await booth.create(on: req.db)

        return try await BoothOutput(booth)
            .encodeResponse(status: .created, for: req)
    }

    private func show(req: Request) async throws -> BoothOutput {
        let locale = getLocale(req: req) ?? defaultLocale

        let booth = try await findBooth(req: req)

        let countryName = booth.country.translations.filter { $0.locale == locale }.first?.name ?? "No country name"

        return try BoothOutput(booth, countryName: countryName)
    }

    private func update(req: Request) async throws -> BoothOutput {
        try BoothInput.validate(content: req)

        let input = try req.content.decode(BoothInput.self)

        let booth = try await findBooth(req: req)

        guard try await Booth.query(on: req.db)
            .filter(\.$name == input.name).first() == nil
            || (input.name == booth.name) else {
            throw BoothError.alreadyExists
        }

        guard try await BoothCountry.query(on: req.db)
            .filter(\.$id == input.countryID)
            .first() != nil else {
            throw BoothCountryError.notFound
        }

        apply(input: input, to: booth)

        try await booth.update(on: req.db)

        return try BoothOutput(booth)
    }

    private func delete(req: Request) async throws -> HTTPStatus {
        let booth = try await findBooth(req: req)

        try await booth.delete(on: req.db)

        return .noContent
    }

    private func getLocale(req: Request) -> String? {
        guard let input = try? req.query.decode(LocaleInput.self),
              let locale = input.locale else {
            return nil
        }

        return locale
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
        booth.name = input.name
        booth.description = input.description
        booth.pictureURL = input.pictureURL
        booth.location = input.location
        booth.isVegan = input.isVegan
        booth.isPRM = input.isPRM
        booth.isFamilyFriendly = input.isFamilyFriendly
        booth.allergens = input.allergens
        booth.startTime = input.startTime
        booth.endTime = input.endTime
        booth.$country.id = input.countryID
    }
}

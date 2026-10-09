//
//  BoothCountryTranslationController.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 09/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Fluent
import Vapor

struct BoothCountryTranslationController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let translations = routes.grouped("api", "v0", "booth-country-translations")

        translations.get(use: list)
        translations.post(use: create)

        translations.group(":id") { translation in
            translation.get(use: show)
            translation.put(use: update)
            translation.delete(use: delete)
        }
    }

    private func list(req: Request) async throws -> [BoothCountryTranslationOutput] {
        let translations = try await BoothCountryTranslation
            .query(on: req.db)
            .all()

        return try translations.map(BoothCountryTranslationOutput.init)
    }

    private func create(req: Request) async throws -> Response {
        try BoothCountryTranslationInput.validate(content: req)

        let input = try req.content.decode(BoothCountryTranslationInput.self)

        guard try await BoothCountryTranslation.query(on: req.db)
            .filter(\.$locale == input.locale)
            .filter(\.$country.$id == input.countryID)
            .first() == nil else {
            throw BoothCountryTranslationError.alreadyExists
        }

        let translation = input.toModel()

        try await translation.create(on: req.db)

        return try await BoothCountryTranslationOutput(translation)
            .encodeResponse(status: .created,
                            for: req)
    }

    private func show(req: Request) async throws -> BoothCountryTranslationOutput {
        let translation = try await findTranslation(req: req)

        return try BoothCountryTranslationOutput(translation)
    }

    private func update(req: Request) async throws -> BoothCountryTranslationOutput {
        try BoothCountryTranslationInput.validate(content: req)

        let input = try req.content.decode(BoothCountryTranslationInput.self)

        let translation = try await findTranslation(req: req)

        guard try await BoothCountryTranslation.query(on: req.db)
            .filter(\.$locale == input.locale)
            .filter(\.$country.$id == input.countryID)
            .first() == nil
            || (input.locale == translation.locale && input.countryID == translation.$country.id)
        else {
            throw BoothCountryTranslationError.alreadyExists
        }

        apply(input: input, to: translation)

        try await translation.update(on: req.db)

        return try BoothCountryTranslationOutput(translation)
    }

    private func delete(req: Request) async throws -> HTTPStatus {
        let translation = try await findTranslation(req: req)

        try await translation.delete(on: req.db)

        return .noContent
    }

    private func findTranslation(req: Request) async throws -> BoothCountryTranslation {
        let id = try req.parameters.require("id", as: UUID.self)

        guard let translation = try await BoothCountryTranslation.find(id, on: req.db) else {
            throw BoothCountryTranslationError.notFound
        }

        return translation
    }

    private func apply(input: BoothCountryTranslationInput,
                       to translation: BoothCountryTranslation) {
        translation.locale = input.locale
        translation.name = input.name
        translation.$country.id = input.countryID
    }
}

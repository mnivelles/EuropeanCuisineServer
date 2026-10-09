//
//  BoothCountryController.swift
//  EuropeanCuisineServer
//  
//  Created by Mathieu Nivelles on 09/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//  

import Fluent
import Vapor

struct BoothCountryController: RouteCollection {
    
    func boot(routes: any RoutesBuilder) throws {
        let countries = routes.grouped("api", "v0", "booth-countries")
        
        countries.get(use: list)
        countries.post(use: create)
        
        countries.group(":id") { country in
            country.get(use: show)
            country.put(use: update)
            country.delete(use: delete)
        }
    }
    
    private func list(req: Request) async throws -> [BoothCountryOutput] {
        let countries = try await BoothCountry
            .query(on: req.db)
            .all()
        
        return try countries.map(BoothCountryOutput.init)
    }
    
    private func create(req: Request) async throws -> Response {
        try BoothCountryInput.validate(content: req)
        
        let input = try req.content.decode(BoothCountryInput.self)
        
        guard try await BoothCountry.query(on: req.db).filter(\.$code == input.code).first() == nil else {
            throw BoothCountryError.alreadyExists
        }
        
        let country = input.toModel()
        
        try await country.create(on: req.db)
        
        return try await BoothCountryOutput(country)
            .encodeResponse(status: .created,
                            for: req)
    }
    
    private func show(req: Request) async throws -> BoothCountryOutput {
        let country = try await findCountry(req: req)
        
        return try BoothCountryOutput(country)
    }
    
    private func update(req: Request) async throws -> BoothCountryOutput {
        try BoothCountryInput.validate(content: req)
        
        let input = try req.content.decode(BoothCountryInput.self)
        
        let country = try await findCountry(req: req)
        
        guard try await BoothCountry.query(on: req.db).filter(\.$code == input.code).first() == nil || (input.code == country.code) else {
            throw BoothCountryError.alreadyExists
        }
        
        apply(input: input, to: country)
        
        try await country.update(on: req.db)
        
        return try BoothCountryOutput(country)
    }
    
    private func delete(req: Request) async throws -> HTTPStatus {
        let country = try await findCountry(req: req)
        
        try await country.delete(on: req.db)
        
        return .noContent
    }
    
    private func findCountry(req: Request) async throws -> BoothCountry {
        let id = try req.parameters.require("id", as: UUID.self)
        
        guard let country = try await BoothCountry.find(id, on: req.db) else {
            throw BoothCountryError.notFound
        }
        
        return country
    }
    
    private func apply(input: BoothCountryInput, to country: BoothCountry) {
        country.code = input.code
    }
}

//
//  BoothCountryTranslation.swift
//  EuropeanCuisineServer
//  
//  Created by Mathieu Nivelles on 09/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//  

import Fluent
import Vapor

final class BoothCountryTranslation: Model, @unchecked Sendable {
    static let schema: String = "booth_country_translations"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "locale")
    var locale: String
    
    @Field(key: "name")
    var name: String
    
    @Parent(key: "country_id")
    var country: BoothCountry
    
    init() {}
    
    init(
        id: UUID? = nil,
        locale: String,
        name: String,
        countryID: BoothCountry.IDValue
    ) {
        self.id = id
        self.locale = locale
        self.name = name
        self.$country.id = countryID
    }
}

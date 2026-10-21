//
//  Allergen.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 12/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

enum Allergen: String, Codable, CaseIterable {
    case cerealsContainingGluten = "cereals_containing_gluten"
    case crustaceans
    case eggs
    case fish
    case peanuts
    case soybeans
    case milk
    case nuts
    case celery
    case mustard
    case sesameSeeds = "sesame_seeds"
    case sulphurDioxideAndSulphites = "sulphur_dioxide_and_sulphites"
    case lupin
    case molluscs

    var name: String {
        switch self {
        case .cerealsContainingGluten:
            "Cereals containing gluten"
        case .crustaceans:
            "Crustaceans"
        case .eggs:
            "Eggs"
        case .fish:
            "Fish"
        case .peanuts:
            "Peanuts"
        case .soybeans:
            "Soybeans"
        case .milk:
            "Milk"
        case .nuts:
            "Tree nuts"
        case .celery:
            "Celery"
        case .mustard:
            "Mustard"
        case .sesameSeeds:
            "Sesame seeds"
        case .sulphurDioxideAndSulphites:
            "Sulphur dioxide and sulphites"
        case .lupin:
            "Lupin"
        case .molluscs:
            "Molluscs"
        }
    }
}

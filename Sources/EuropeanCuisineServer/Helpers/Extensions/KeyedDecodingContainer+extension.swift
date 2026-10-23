//
//  KeyedDecodingContainer+extension.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 23/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

extension KeyedDecodingContainer {
    /// Retourne `nil` si la clé est absente ou si sa valeur est une chaîne vide.
    func decodeIfNotEmpty<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T? {
        if let string = try? decodeIfPresent(String.self, forKey: key), string.isEmpty {
            return nil
        }
        return try decodeIfPresent(type, forKey: key)
    }
}

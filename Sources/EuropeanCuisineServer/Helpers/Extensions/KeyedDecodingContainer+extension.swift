//
//  KeyedDecodingContainer+extension.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 23/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Foundation

extension KeyedDecodingContainer {
    /// Retourne `nil` si la clé est absente ou si sa valeur est une chaîne vide.
    func decodeIfNotEmpty<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T? {
        if let string = try? decodeIfPresent(String.self, forKey: key), string.isEmpty {
            return nil
        }
        return try decodeIfPresent(type, forKey: key)
    }

    func decodeISODate(forKey key: Key) throws -> Date {
        let string = try decode(String.self, forKey: key)
        guard let date = ISO8601DateFormatter().date(from: string) else {
            throw DecodingError.dataCorruptedError(forKey: key,
                                                   in: self,
                                                   debugDescription: "\(key.stringValue) must be an ISO 8601 date (e.g. 1970-01-01T08:00:00Z)")
        }
        return date
    }
}

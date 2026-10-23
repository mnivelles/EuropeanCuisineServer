//
//  Page+extension.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 23/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Fluent

extension Page {
    func compactMap<U>(_ transform: (T) throws -> U?) rethrows -> Page<U> {
        try Page<U>(items: items.compactMap(transform),
                    metadata: metadata)
    }
}

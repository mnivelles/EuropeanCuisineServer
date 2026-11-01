//
//  UserJWTPayload.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 15/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import Fluent
import Foundation
import JWT
import Vapor

struct UserJWTPayload: JWTPayload {
    var subject: SubjectClaim
    var expiration: ExpirationClaim

    static let expirationTime: TimeInterval = 28 * 24 * 3600 // 28 days

    func verify(using algorithm: some JWTAlgorithm) async throws {
        try expiration.verifyNotExpired()
    }
}

extension UserJWTPayload {
    init(id: UUID) {
        self.subject = SubjectClaim(value: id.uuidString)
        self.expiration = .init(value: Date().addingTimeInterval(Self.expirationTime))
    }
}

extension UserJWTPayload {
    static func generateToken(for user: User, req: Request) async throws -> String {
        guard let id = user.id else {
            throw Abort(.badRequest, reason: "Token generation error")
        }

        let userJWT = UserJWTPayload(id: id)

        return try await req.jwt.sign(userJWT)
    }
}

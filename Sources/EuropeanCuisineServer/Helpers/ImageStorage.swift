//
//  ImageStorage.swift
//  EuropeanCuisineServer
//
//  Created by Mathieu Nivelles on 22/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import SotoS3
import Vapor

struct ImageStorage {
    private let bucketName: String

    init(bucketName: String = "european-cuisine-test") {
        self.bucketName = bucketName
    }

    func upload(req: Request, file: File, folder: String, id: UUID) async throws -> URL {
        let key = "\(folder)/\(id.uuidString)"

        guard file.data.readableBytes <= Constants.Image.maxSize else {
            throw ImageFileError.fileMaxSize(max: Constants.Image.maxSize)
        }

        guard Constants.Image.allowedExtensions.contains(file.extension?.lowercased() ?? "") else {
            throw ImageFileError.fileExtension(extensions: Constants.Image.allowedExtensions)
        }

        let putObjectRequest = S3.PutObjectRequest(acl: .publicRead,
                                                   body: .init(buffer: file.data),
                                                   bucket: bucketName,
                                                   contentType: file.contentType?
                                                       .description ?? "application/octet-stream",
                                                   key: key)

        let s3 = S3(client: req.services.awsClient,
                    endpoint: Environment.get("R2_ENDPOINT_URL"))

        _ = try await s3.putObject(putObjectRequest)

        return try url(for: key, region: s3.region.rawValue)
    }

    private func url(for key: String, region: String) throws -> URL {
        guard let endpoint = Environment.get("R2_PUBLIC_URL") else {
            throw Abort(.internalServerError)
        }

        let urlString = "\(endpoint)/\(key)"

        guard let url = URL(string: urlString) else {
            throw Abort(.internalServerError)
        }

        return url
    }
}

// let file = try req.content.decode(File.self)
// let key = "workshops/" + UUID().uuidString
//
// guard file.data.readableBytes <= maxImageSize else  {
//    throw Abort(.badRequest, reason: "Image size should not exceed \(Double(maxImageSize) /
//    1_000_000.0) MB")
// }
//
// guard ["png", "jpeg", "jpg", "avif", "webp"].contains(file.extension?.lowercased()) else {
//    throw Abort(.badRequest, reason: "Image must be jpg, png, avif or webp")
// }
//
// let putObjectRequest = S3.PutObjectRequest(
//    acl: .publicRead,
//    body: .init(buffer: file.data),
//    bucket: bucketName,
//    contentType: file.contentType?.description ?? "application/octet-stream",
//    key: key
// )
//
// let s3 = S3(client: req.services.awsClient,
//            endpoint: Environment.get("R2_ENDPOINT_URL"))
//
// _ = try await s3.putObject(putObjectRequest)
//
// let url = try url(for: key, region: s3.region.rawValue)
// return FileUploadResponse(url: url)

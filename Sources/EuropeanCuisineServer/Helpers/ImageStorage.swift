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

        return try url(for: key, version: String(UUID().uuidString.prefix(8)))
    }

    private func url(for key: String, version: String) throws -> URL {
        guard let endpoint = Environment.get("R2_PUBLIC_URL"),
              var components = URLComponents(string: "\(endpoint)/\(key)")
        else {
            throw Abort(.internalServerError)
        }

        components.queryItems = [URLQueryItem(name: "v", value: version)]

        guard let url = components.url else {
            throw Abort(.internalServerError)
        }

        return url
    }
}

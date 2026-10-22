//
//  Application+AWSClient.swift
//  TestUploadImage
//
//  Created by Mathieu Nivelles on 22/10/2026.
//  Copyright © 2026 Mathieu Nivelles. All rights reserved.
//

import SotoCore
import Vapor

extension Application.Services {
    var awsClient: Application.Service<AWSClient> {
        .init(application: application)
    }
}

extension Request.Services {
    var awsClient: AWSClient {
        request.application.services.awsClient.service
    }
}

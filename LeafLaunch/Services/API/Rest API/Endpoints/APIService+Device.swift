//
//  APIService+Device.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 10/8/23.
//

import Foundation

extension APIService {

    @concurrent
    func signOutCustomerDevice(installationId: String) async throws {

        _ = try await buildRequest(
            method: .delete,
            apiPath: .init(path: .customer("devices/\(installationId)")),
            headers: await customerHeaders()
        )
        try Task.checkCancellation()

    }

    @concurrent
    func registerDevice(token: String,
                        userId: String) async throws {

        let parameters: [String: Any] = await [
            "installation_id": Constants.Device.deviceId,
            "app_identifier": BusinessConfig.bundleIdentifier,
            "platform": "IOS",
            "status": "ACTIVE",
            "fcm_token": token
        ]

        let _ = try await buildRequest(
            method: .post,
            apiPath: .init(path: .customer("devices")),
            parameters: parameters,
            headers: await customerHeaders()
        )

    }

}

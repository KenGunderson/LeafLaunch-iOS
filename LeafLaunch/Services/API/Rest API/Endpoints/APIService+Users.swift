//
//  APIService+Users.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 8/24/23.
//

import Foundation
import SwiftDate

extension APIService {

    // MARK: - USERS

    @concurrent
    func getUser(id: String) async throws -> LLUser {

        let data = try await buildRequest(
            method: .get,
            apiPath: .init(path: .user("\(id)"))
        )

        let result: LLUser = try await parseData(data: data)
        return result

    }

    @concurrent
    func getUserProfile() async throws -> LLUser {

        let data = try await buildRequest(
            method: .get,
            apiPath: .init(path: .user("profile"))
        )

        let result: LLUser = try await parseData(data: data)
        return result

    }

    @concurrent
    func createUser(user: LLUser) async throws -> LLUser {

        let parameters: [String: Any] = await [
            "first_name": user.firstName,
            "last_name": user.lastName,
            "email": user.email,
            "phone_number": user.phoneNumber,
            "external_id": user.externalId,
            "image_url": user.imageURL?.absoluteString,
            "date_of_birth": user.dateOfBirth?.toISO()
        ]
            .compact()


        let data = try await buildRequest(
            method: .post,
            apiPath: .init(path: .user("")),
            parameters: parameters
        )

        let result: LLUser = try await parseData(data: data)
        return result

    }

    @concurrent
    func updateUser(user: LLUser) async throws {

        let parameters: [String: Any] = [
            "id": user.id,
            "external_id": user.externalId,
            "first_name": user.firstName,
            "last_name": user.lastName,
            "email": user.email,
            "phone_number": user.phoneNumber,
            "image_url": user.imageURL?.absoluteString,
            "date_of_birth": await user.dateOfBirth?.toISO(),
        ]
            .compact()


        _ = try await buildRequest(
            method: .put,
            apiPath: .init(path: .user("\(user.id)")),
            parameters: parameters
        )

    }

    @concurrent
    func deleteUser(user: LLUser) async throws {


        _ = try await buildRequest(
            method: .delete,
            apiPath: .init(path: .user("\(user.id)"))
        )

    }

}

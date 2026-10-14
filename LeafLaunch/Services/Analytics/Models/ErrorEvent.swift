//
//  ErrorEvent.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 10/01/23.
//

import Foundation

enum ErrorEvent: AnalyticsEvent {

    case generic(error: Error, message: String?)
    case auth(error: Error, message: String?)
    case api(error: APIError)

    var error: Error? {

        switch self {
        case .generic(let error, _): return error
        case .api(let error): return error
        case .auth(let error, _): return error
        }

    }

    var eventType: EventType {
        .error
    }

    var eventData: EventData {

        var properties = [String: Any]()

        switch self {
        case .generic(_, let message):

            properties["name"] = "generic"
            properties["message"] = message
            properties["error"] = error?.getMessageForError()

        case .auth(_, let message):

            properties["name"] = "auth"
            properties["message"] = message

        case .api(let error):

            properties["name"] = "api"
            properties["message"] = error.message

            switch error {
            case .serverError(let statusCode, let errorMessage):

                properties["status_code"] = statusCode
                properties["message"] = errorMessage

            default: break
            }

        }

        // Error

        if let nsError = self.error as? NSError {

            properties["domain"] = nsError.domain
            properties["code"] = nsError.code
            properties["description"] = nsError.getMessageForError()

        }

        return EventData(
            name: "error",
            properties: properties
        )

    }

}

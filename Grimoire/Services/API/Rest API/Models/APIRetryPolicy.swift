//
//  APIRetryPolicy.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/24/26.
//

import Foundation

internal struct APIRetryPolicy: Sendable {
    
    let maxAttempts: Int
    let rateLimitRetryDelays: [TimeInterval]
    let retryStatusCodes: Set<Int>
    let retryURLCodes: Set<URLError.Code>
    let retryableMethods: Set<HTTPRequestMethod>
    
    func shouldRetry(statusCode: Int,
                     attempt: Int,
                     method: HTTPRequestMethod) -> Bool {
        
        guard attempt < maxAttempts else { return false }
        guard retryableMethods.contains(method) else { return false }
        return retryStatusCodes.contains(statusCode)
        
    }
    
    func shouldRetry(error: Error,
                     attempt: Int,
                     method: HTTPRequestMethod) -> Bool {
        
        guard attempt < maxAttempts else { return false }
        guard retryableMethods.contains(method) else { return false }
        guard let urlError = error as? URLError else { return false }
        return retryURLCodes.contains(urlError.code)
        
    }
    
    func delay(for attempt: Int) -> TimeInterval {
        
        guard !rateLimitRetryDelays.isEmpty else { return 0 }
        
        let delayIndex = max(0, min(attempt - 1, rateLimitRetryDelays.count - 1))
        return rateLimitRetryDelays[delayIndex]
        
    }
    
    func delayNanoseconds(for attempt: Int) -> UInt64 {
        
        let nanoseconds = delay(for: attempt) * 1_000_000_000
        return UInt64(max(0, nanoseconds))
        
    }
    
    static let `default` = APIRetryPolicy(
        maxAttempts: 4,
        rateLimitRetryDelays: [1, 2, 4, 8],
        retryStatusCodes: [429, 502, 503, 504],
        retryURLCodes: [
            .timedOut,
            .cannotFindHost,
            .cannotConnectToHost,
            .networkConnectionLost,
            .notConnectedToInternet,
            .dnsLookupFailed
        ],
        retryableMethods: [.get, .put, .delete]
    )
    
    static let noRetry = APIRetryPolicy(
        maxAttempts: 1,
        rateLimitRetryDelays: [],
        retryStatusCodes: [],
        retryURLCodes: [],
        retryableMethods: []
    )
    
}

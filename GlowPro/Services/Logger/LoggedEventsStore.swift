//
//  LoggedEventsStore.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/29/25.
//

import os

final class LoggedEventsStore {
    
    static let shared = LoggedEventsStore()

    private var events: [LogEvent] = []
    private let lock = OSAllocatedUnfairLock()

    func append(_ event: LogEvent) {
        self.lock.withLock { self.events.append(event) }
    }

    func snapshot() -> [LogEvent] {
        self.lock.withLock { self.events }
    }

    func clear() {
        self.lock.withLock { self.events.removeAll(keepingCapacity: false) }
    }
    
}

final class APILogResponseStore {
    
    static let shared = APILogResponseStore()

    private var responses: [APILogResponse] = []
    private let lock = OSAllocatedUnfairLock()

    func append(_ response: APILogResponse) {
        
        self.lock.withLock {
            self.responses.append(response)
        }
        
    }

    func snapshot() -> [APILogResponse] {
        self.lock.withLock { self.responses }
    }

    func clear() {
        self.lock.withLock { self.responses.removeAll(keepingCapacity: false) }
    }
    
}

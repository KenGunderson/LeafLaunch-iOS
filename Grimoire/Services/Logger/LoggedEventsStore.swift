//
//  LoggedEventsStore.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 10/29/25.
//

import os
import Synchronization

final class LoggedEventsStore: Sendable {
    
    nonisolated static let shared = LoggedEventsStore()

    private let events: Mutex<[LogEvent]>
    
    nonisolated private init() {
        self.events = Mutex([])
    }

    nonisolated func append(_ event: LogEvent) {
        
        self.events.withLock { logs in
            logs.append(event)
        }
        
    }

    nonisolated func snapshot() -> [LogEvent] {
        self.events.withLock { return $0 }
    }

    nonisolated func clear() {
        self.events.withLock { $0.removeAll() }
    }
    
}

final class APILogResponseStore: Sendable {
    
    nonisolated static let shared = APILogResponseStore()

    private let responses: Mutex<[APILogResponse]>
    
    nonisolated private init() {
        self.responses = Mutex([])
    }

    nonisolated func append(_ response: APILogResponse) {
        
        self.responses.withLock { responses in
            responses.append(response)
        }
        
    }

    nonisolated func snapshot() -> [APILogResponse] {
        self.responses.withLock { return $0 }
    }

    nonisolated func clear() {
        self.responses.withLock { $0.removeAll() }
    }
    
}

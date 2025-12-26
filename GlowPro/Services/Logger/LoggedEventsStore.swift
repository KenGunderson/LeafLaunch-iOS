//
//  LoggedEventsStore.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/29/25.
//

import os
import Synchronization

final class LoggedEventsStore {
    
    static let shared = LoggedEventsStore()

    private let events: Mutex<[LogEvent]> = .init([])

    func append(_ event: LogEvent) {
        
        self.events.withLock { logs in
            logs.append(event)
        }
        
    }

    func snapshot() -> [LogEvent] {
        self.events.withLock { return $0 }
    }

    func clear() {
        self.events.withLock { $0.removeAll() }
    }
    
}

final class APILogResponseStore {
    
    static let shared = APILogResponseStore()

    private let responses: Mutex<[APILogResponse]> = .init([])

    func append(_ response: APILogResponse) {
        
        self.responses.withLock { responses in
            responses.append(response)
        }
        
    }

    func snapshot() -> [APILogResponse] {
        self.responses.withLock { return $0 }
    }

    func clear() {
        self.responses.withLock { $0.removeAll() }
    }
    
}

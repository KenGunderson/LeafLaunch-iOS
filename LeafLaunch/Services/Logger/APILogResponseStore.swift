import Synchronization

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

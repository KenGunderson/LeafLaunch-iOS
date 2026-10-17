//
//  ConnectivityService.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import Combine
import Network
import SwiftUI

final class ConnectivityService: ConnectivityServiceProtocol {

    internal let loggerName: String = "CONNECTIVITY_SERVICE"
    internal let loggerEmoji: String = "📡"

    private let networkMonitor = NWPathMonitor()
    private(set) var onHasNetworkConnection = CurrentValueSubject<Bool, Never>(true)

    init() {

        self.logInit()

        self.networkMonitor.pathUpdateHandler = { [weak self] path in

            let hasNetworkConnection = path.status == .satisfied

            Task { @MainActor [weak self] in
                self?.setNetworkConnection(connection: hasNetworkConnection)
            }

        }

        self.networkMonitor.start(queue: DispatchQueue.global())

    }

    deinit {

        self.networkMonitor.pathUpdateHandler = nil
        self.networkMonitor.cancel()
        self.logDeinit()

    }

    func setNetworkConnection(connection: Bool) {

        Task { @MainActor [weak self] in

            withAnimation {
                self?.onHasNetworkConnection.send(connection)
            }

        }

    }

}

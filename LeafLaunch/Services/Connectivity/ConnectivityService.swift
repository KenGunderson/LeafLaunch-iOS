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

            guard let self = self else { return }

            Task { @MainActor in
                self.setNetworkConnection(connection: path.status == .satisfied)
            }

        }

        self.networkMonitor.start(queue: DispatchQueue.global())

    }

    deinit {

        self.networkMonitor.pathUpdateHandler = nil
        self.logDeinit()

    }

    func setNetworkConnection(connection: Bool) {

        Task { @MainActor in

            withAnimation {
                onHasNetworkConnection.send(connection)
            }

        }

    }

}

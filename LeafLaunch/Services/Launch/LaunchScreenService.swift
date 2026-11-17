//
//  LaunchService.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import Combine

final class LaunchScreenService: LaunchScreenServiceProtocol {

    enum State {

        case loading
        case completed

    }

    internal let loggerName: String = "LAUNCH_SERVICE"
    internal let loggerEmoji: String = "🚀"

    private(set) var onLaunchStateChanged = CurrentValueSubject<LaunchScreenService.State, Never>(.loading)

    init() {
        self.logInit()
    }

    deinit {
        self.logDeinit()
    }

    func setState(_ state: LaunchScreenService.State) {
        self.onLaunchStateChanged.send(state)
    }

}

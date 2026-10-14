//
//  ViewLifecycleServiceProtocol.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import Combine

protocol ViewLifecycleServiceProtocol: AnyObject, Loggable {

    func reload(for key: ViewLifecycleKey)
    func reload(for keys: [ViewLifecycleKey])
    func reloadAll()
    func publisher(for key: ViewLifecycleKey) -> AnyPublisher<Void, Never>

    var onDidEnterBackground: CurrentValueSubject<String?, Never> { get }
    var onDidBecomeActive: CurrentValueSubject<String?, Never> { get }
    var onWillEnterForeground: CurrentValueSubject<String?, Never> { get }

}

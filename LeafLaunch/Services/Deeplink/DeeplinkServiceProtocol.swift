//
//  DeeplinkServiceProtocol.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 7/15/24.
//

import Foundation

protocol DeeplinkServiceProtocol: AnyObject, Loggable {

    func handle(url: URL)

    func setup(navigationService: NavigationService)

}

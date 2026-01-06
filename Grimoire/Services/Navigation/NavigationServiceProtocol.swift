//
//  NavigationServiceProtocol.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 7/15/24.
//

import SwiftUI
import Combine

protocol NavigationServiceProtocol {

    var routes: [Route] { get set }
    
    var sheet: Sheet? { get set }
    var fullScreenCover: FullScreenCover? { get set }
    
    func push(_ route: Route)
    func push(_ routes: [Route])
    func pop()
    func popWithDelay(_ delay: TimeInterval)
    func popLast(count: Int)
    func popToRoot()
    func swap(_ route: Route)
    func replaceStack(_ route: Route)
    
    func modal(sheet: Sheet)
    func dismissSheet()
    
    func modal(fullScreenCover: FullScreenCover)
    func dismissFullScreenCover()
    
}

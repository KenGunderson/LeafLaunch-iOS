//
//  DeeplinkServiceProtocol.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 7/15/24.
//

import Foundation

protocol DeeplinkServiceProtocol: AnyObject {
    
    func handle(url: URL)
    
    func setup(mainViewModel: MainViewModel?,
               tabBarNavigationService: TabBarNavigationService)
    
}

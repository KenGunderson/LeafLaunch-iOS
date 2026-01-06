//
//  Ext+UIApplication.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 11/14/25.
//

import UIKit

extension UIApplication {
    
    var topMostViewController: UIViewController? {
        
        guard let window = self.firstKeyWindow,
              var topController = window.rootViewController else {
            return nil
        }
        
        while let presented = topController.presentedViewController {
            topController = presented
        }
        
        if let nav = topController as? UINavigationController {
            return nav.visibleViewController ?? nav
        }
        
        if let tab = topController as? UITabBarController {
            return tab.selectedViewController ?? tab
        }
        
        return topController
        
    }
    
    var firstKeyWindow: UIWindow? {
        self.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
    
}

//
//  OrientationChangeModifier.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/29/25.
//

import SwiftUI

// Important Note
/// Always put this after `onAppear`
/// View needs to be shown before this works. We can always call `onAppear()` like this even though it does nothing
struct OrientationChangeModifier: ViewModifier {
    
    private let notification = UIDevice.orientationDidChangeNotification
    let onRotate: (UIDeviceOrientation) -> ()
    
    func body(content: Content) -> some View {
        
        content
            .onReceive(NotificationCenter.default.publisher(for: self.notification)) { _ in
                self.onRotate(UIDevice.current.orientation)
            }
        
    }
    
}

extension View {
    
    func detectRotation(change: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(OrientationChangeModifier(onRotate: change))
    }
    
}

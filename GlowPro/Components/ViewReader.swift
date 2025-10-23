//
//  ViewReader.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/22/25.
//

import SwiftUI

/// Inserts a transparent UIView into the SwiftUI hierarchy and hands you its superview,
/// which is the actual container UIView hosting your SwiftUI content on screen.
struct ViewReader: UIViewRepresentable {
    
    let onResolve: (UIView) -> Void
    
    func makeUIView(context: Context) -> UIView {
        
        let view = UIView(frame: .zero)
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        
        // Capture the superview after it’s in the hierarchy
        DispatchQueue.main.async { [weak view] in
            
            if let superview = view?.superview {
                onResolve(superview)
            }
            
        }
        
        return view
        
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
        // Keep the reference fresh if layout changes
        DispatchQueue.main.async { [weak uiView] in
            
            if let superview = uiView?.superview {
                onResolve(superview)
            }
            
        }
        
    }
    
}

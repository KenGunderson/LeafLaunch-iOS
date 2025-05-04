//
//  Shimmer.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/10/25.
//

import SwiftUI

public struct Shimmer: ViewModifier {
    
    public enum Mode {
        
        case mask
        case overlay(blendMode: BlendMode = .sourceAtop)
        case background
        
    }
    
    @State private var isInitialState = true
    @Environment(\.layoutDirection) private var layoutDirection
    
    private let animation: Animation
    private let gradient: Gradient
    private let min: CGFloat
    private let max: CGFloat
    private let mode: Mode
    
    public init(
        animation: Animation = Self.defaultAnimation,
        gradient: Gradient = Self.defaultGradient,
        size: CGFloat = 0.3,
        mode: Mode = .mask) {
            
        self.animation = animation
        self.gradient = gradient
        self.min = 0 - size
        self.max = 1 + size
        self.mode = mode
            
    }
    
    public static let defaultAnimation = Animation
        .linear(duration: 1.5)
        .delay(0.25)
        .repeatForever(autoreverses: false)
    
    public static let defaultGradient = Gradient(colors: [
        .black.opacity(0.3),
        .black,
        .black.opacity(0.3)
    ])
    
    var startPoint: UnitPoint {
        
        return switch self.layoutDirection {
        case .rightToLeft: self.isInitialState ? UnitPoint(x: max, y: min) : UnitPoint(x: 0, y: 1)
        case .leftToRight: self.isInitialState ? UnitPoint(x: min, y: min) : UnitPoint(x: 1, y: 1)
        default: .zero
        }
        
    }
    
    var endPoint: UnitPoint {
        
        return switch self.layoutDirection {
        case .rightToLeft: self.isInitialState ? UnitPoint(x: 1, y: 0) : UnitPoint(x: min, y: max)
        case .leftToRight: self.isInitialState ? UnitPoint(x: 0, y: 0) : UnitPoint(x: max, y: max)
        default: .zero
        }
        
    }
    
    public func body(content: Content) -> some View {
        
        applyingGradient(to: content)
            .animation(self.animation, value: self.isInitialState)
            .onAppear {
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.isInitialState = false
                }
                
            }
        
    }
    
    @ViewBuilder public func applyingGradient(to content: Content) -> some View {
        
        let gradient = LinearGradient(
            gradient: gradient,
            startPoint: startPoint,
            endPoint: endPoint
        )
        
        switch mode {
        case .mask: content.mask(gradient)
        case let .overlay(blendMode: blendMode): content.overlay(gradient.blendMode(blendMode))
        case .background: content.background(gradient)
        }
        
    }
    
}

public extension View {
    
    @ViewBuilder func shimmer(
        _ active: Bool = true,
        animation: Animation = Shimmer.defaultAnimation,
        gradient: Gradient = Shimmer.defaultGradient,
        size: CGFloat = 0.3,
        mode: Shimmer.Mode = .mask) -> some View {
            
            if active {
                
                modifier(Shimmer(
                    animation: animation,
                    gradient: gradient,
                    size: size,
                    mode: mode
                ))
                
            } else {
                self
            }
            
    }

}

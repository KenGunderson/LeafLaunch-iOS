//
//  AppBackgroundStyle.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/1/25.
//

import SwiftUI

enum ColorSource: Hashable {
    
    case color(ColorWrapper)
    case material(MaterialWrapper)
    case linearGradient(GradientWrapper)
    
    func source() -> AnyShapeStyle {
        
        switch self {
        case .color(let wrapper): return AnyShapeStyle(wrapper.color)
        case .material(let wrapper): return AnyShapeStyle(wrapper.material)
        case .linearGradient(let wrapper): return AnyShapeStyle(wrapper.gradient)
        }
        
    }
    
    func view() -> some View {
        
        switch self {
        case .color(let wrapper): return AnyView(Rectangle().fill(wrapper.color))
        case .material(let wrapper): return AnyView(Rectangle().fill(wrapper.material))
        case .linearGradient(let wrapper): return AnyView(Rectangle().fill(wrapper.gradient))
        }
        
    }
    
}

extension ColorSource {
    
    static func color(_ color: Color) -> ColorSource {
        .color(ColorWrapper(color))
    }
    
    static func material(_ material: Material) -> ColorSource {
        .material(MaterialWrapper(material))
    }
    
    static func linearGradient(_ gradient: LinearGradient) -> ColorSource {
        .linearGradient(GradientWrapper(gradient))
    }
    
}

struct ColorWrapper: Hashable {
    
    let color: Color
    private let id = UUID()
    
    init(_ color: Color) {
        self.color = color
    }
    
}

struct MaterialWrapper: Hashable {
    
    static func == (lhs: MaterialWrapper, rhs: MaterialWrapper) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    let material: Material
    private let id = UUID()
    
    init(_ material: Material) {
        self.material = material
    }
    
}

struct GradientWrapper: Hashable {
    
    static func == (lhs: GradientWrapper, rhs: GradientWrapper) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    let gradient: LinearGradient
    private let id = UUID()
    
    init(_ gradient: LinearGradient) {
        self.gradient = gradient
    }
    
}

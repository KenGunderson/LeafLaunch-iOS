//
//  AppBackgroundStyle.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/1/25.
//

import SwiftUI

enum AppBackgroundStyle: Hashable {
    
    case color(ColorWrapper)
    case material(MaterialWrapper)
    case linearGradient(GradientWrapper)
    
    func backgroundStyle() -> AnyShapeStyle {
        
        switch self {
        case .color(let wrapper): return AnyShapeStyle(wrapper.color)
        case .material(let wrapper): return AnyShapeStyle(wrapper.material)
        case .linearGradient(let wrapper): return AnyShapeStyle(wrapper.gradient)
        }
        
    }
    
    func viewStyle() -> some View {
        
        switch self {
        case .color(let wrapper): return AnyView(Rectangle().fill(wrapper.color))
        case .material(let wrapper): return AnyView(Rectangle().fill(wrapper.material))
        case .linearGradient(let wrapper): return AnyView(Rectangle().fill(wrapper.gradient))
        }
        
    }
    
}

extension AppBackgroundStyle {
    
    static func color(_ color: Color) -> AppBackgroundStyle {
        .color(ColorWrapper(color))
    }
    
    static func material(_ material: Material) -> AppBackgroundStyle {
        .material(MaterialWrapper(material))
    }
    
    static func linearGradient(_ gradient: LinearGradient) -> AppBackgroundStyle {
        .linearGradient(GradientWrapper(gradient))
    }
    
}

enum AppForegroundStyle: Hashable {
    
    case color(ColorWrapper)
    case material(MaterialWrapper)
    case linearGradient(GradientWrapper)
    
    func foregroundStyle() -> AnyShapeStyle {
        
        switch self {
        case .color(let wrapper): return AnyShapeStyle(wrapper.color)
        case .material(let wrapper): return AnyShapeStyle(wrapper.material)
        case .linearGradient(let wrapper): return AnyShapeStyle(wrapper.gradient)
        }
        
    }
    
    func viewStyle() -> some View {
        
        switch self {
        case .color(let wrapper): return AnyView(Rectangle().fill(wrapper.color))
        case .material(let wrapper): return AnyView(Rectangle().fill(wrapper.material))
        case .linearGradient(let wrapper): return AnyView(Rectangle().fill(wrapper.gradient))
        }
        
    }
    
}

extension AppForegroundStyle {
    
    static func color(_ color: Color) -> AppForegroundStyle {
        .color(ColorWrapper(color))
    }
    
    static func material(_ material: Material) -> AppForegroundStyle {
        .material(MaterialWrapper(material))
    }
    
    static func linearGradient(_ gradient: LinearGradient) -> AppForegroundStyle {
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

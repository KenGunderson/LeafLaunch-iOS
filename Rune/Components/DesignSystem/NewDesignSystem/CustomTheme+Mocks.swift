//
//  NewAppShadow.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/10/25.
//

import SwiftUI

extension CustomTheme {
    
    static let `default` = CustomTheme(
        id: "DEFAULT",
        accentColor: .color(.blue),
        accentColorSecondary: .color(.cyan),
        background: .init(
            primary: .color(Color(uiColor: .systemGray6)),
            secondary: .color(Color(.secondarySystemBackground)),
            tertiary: .color(Color(.tertiarySystemBackground)),
            quaternary: .color(Color(.quaternarySystemFill))
        ),
        textColor: .init(
            title: .color(.primary),
            titleInverted: .color(.white),
            body: .color(.gray),
            bodyInverted: .color(.gray)
        ),
        spacing: .default,
        radius: .default,
        fonts: .init(
            title: .system(size: 28, weight: .bold),
            subtitle: .system(size: 20, weight: .medium),
            body: .system(size: 16, weight: .regular),
            caption: .system(size: 12, weight: .light)
        ),
        shadow: .init(
            card: DecodableShadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4),
            subtle: DecodableShadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2),
            offset: DecodableShadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10),
            neon: DecodableShadow(color: Color.blue.opacity(0.7), radius: 20, x: 0, y: 0),
            hard: DecodableShadow(color: Color.black.opacity(0.25), radius: 0, x: 0, y: 2),
            inner: DecodableShadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
        )
    )

    static let alternate = CustomTheme(
        id: "ALTERNATE",
        accentColor: .color(.orange),
        accentColorSecondary: .color(.pink),
        background: .init(
            primary: .color(.black),
            secondary: .color(.gray),
            tertiary: .color(.blue),
            quaternary: .color(.init(white: 0.1))
        ),
        textColor: .init(
            title: .color(.white),
            titleInverted: .color(.black),
            body: .color(.init(white: 0.8)),
            bodyInverted: .color(.init(white: 0.2))
        ),
        spacing: .default,
        radius: .default,
        fonts: .init(
            title: .system(size: 20, weight: .semibold),
            subtitle: .system(size: 18, weight: .medium),
            body: .system(size: 15, weight: .regular),
            caption: .system(size: 11, weight: .light)
        ),
        shadow: .init(
            card: DecodableShadow(color: Color.green.opacity(0.1), radius: 8, x: 0, y: 4),
            subtle: DecodableShadow(color: Color.green.opacity(0.05), radius: 4, x: 0, y: 2),
            offset: DecodableShadow(color: Color.green.opacity(0.2), radius: 10, x: 10, y: 10),
            neon: DecodableShadow(color: Color.green.opacity(0.7), radius: 20, x: 0, y: 0),
            hard: DecodableShadow(color: Color.green.opacity(0.25), radius: 0, x: 0, y: 2),
            inner: DecodableShadow(color: Color.green.opacity(0.3), radius: 4, x: 0, y: 2)
        )
    )
    
}

extension CustomTheme.Spacing {
    
    static let `default` = CustomTheme.Spacing(
        extraSmall: 4,
        small: 8,
        small2: 12,
        medium: 16,
        medium2: 20,
        large: 24,
        extraLarge: 32
    )
    
}

extension CustomTheme.Radius {
    
    static let `default` = CustomTheme.Radius(
        extraSmall: 2,
        small: 4,
        small2: 6,
        medium: 8,
        medium2: 10,
        large: 12,
        extraLarge: 16
    )
    
}

struct NewAppShadow: ViewModifier {
    
    let style: CustomTheme.DecodableShadow
    
    func body(content: Content) -> some View {
        
        content
            .shadow(
                color: self.style.color,
                radius: self.style.radius,
                x: self.style.x,
                y: self.style.y
            )
        
    }
    
}

// MARK: - Preview

fileprivate struct ThemeAppTestView: View {
    
    @Environment(\.designSystem) private var theme
    
    var body: some View {
        
        VStack(spacing: theme.spacing(.medium)) {
            
            Text("Design System Theme")
                .font(theme.font(.title))
                .foregroundStyle(theme.theme.textColor.title.source())
                .contentTransition(.interpolate)
                .newAppShadow(theme.shadow(.hard))
            
            Text("Design System Theme")
                .font(theme.font(.title))
                .foregroundStyle(theme.theme.textColor.title.source())
                .contentTransition(.interpolate)
                .newAppShadow(theme.shadow(.inner))
            
            Text("Design System Theme")
                .font(theme.font(.title))
                .foregroundStyle(theme.theme.textColor.title.source())
                .contentTransition(.interpolate)
                .newAppShadow(theme.shadow(.neon))
            
            Text("Design System Theme")
                .font(theme.font(.title))
                .foregroundStyle(theme.theme.textColor.title.source())
                .contentTransition(.interpolate)
                .newAppShadow(theme.shadow(.offset))
            
            Button("Toggle Theme") {
                theme.toggleTheme()
            }
            .padding(theme.spacing(.small))
            .background(theme.accent.source())
            .clipShape(.rect(cornerRadius: theme.radius(.small2)))
            .newAppShadow(theme.shadow(.subtle))
            .foregroundColor(.white)
            .contentTransition(.interpolate)
            
        }
        .padding(theme.spacing(.large))
        .background(theme.background(.primary).source())
        .clipShape(.rect(cornerRadius: theme.radius(.medium2)))
        .newAppShadow(theme.shadow(.card))
        .compositingGroup()
        .contentTransition(.interpolate)
        .animation(.easeOut(duration: 1.2), value: self.theme.theme.id)
        
    }
    
}

#Preview {
    
    ThemeAppTestView()
        .environment(ThemeManager.shared)
    
}


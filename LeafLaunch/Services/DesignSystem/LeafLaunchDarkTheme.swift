//
//  LeafLaunchDarkTheme.swift
//  LeafLaunch
//

import SwiftUI

// Resolved from LeafLaunch-Web/src/app/theme.css, including its final Leaf Launch overrides.
// Rune foreground roles drive brand controls; background.primary is the app canvas.
public extension Theme {

    @MainActor
    static let leafLaunchDark = Theme(
        id: "leafLaunchDark",
        isLightMode: false,
        foreground: .init(
            primary: .color(Color(hex: "#70E69B")),
            secondary: .color(Color(hex: "#81E9A7")),
            tertiary: .color(Color(hex: "#65CE8D")),
            quaternary: .color(Color(hex: "#56AD7A")),
            disabled: .color(Color(hex: "#85888E"))
        ),
        background: .init(
            primary: .color(Color(hex: "#0D141B")),
            secondary: .color(Color(hex: "#141C24")),
            tertiary: .color(Color(hex: "#242B33")),
            quaternary: .color(Color(hex: "#2F363E")),
            quinary: .color(Color(hex: "#12191F")),
            border: .color(Color(hex: "#3C434B"))
        ),
        textColor: .init(
            title: .color(Color(hex: "#F2F6FB")),
            titleInverted: .color(Color(hex: "#0D141B")),
            body: .color(Color(hex: "#B4B9BF")),
            bodyInverted: .color(Color(hex: "#1B312D")),
            button: .color(Color(hex: "#0D141B")),
            placeholder: .color(Color(hex: "#85888E"))
        ),
        palette: .init(
            success: .color(Color(hex: "#47CD89")),
            warning: .color(Color(hex: "#F79009")),
            error: .color(Color(hex: "#FF8A8A")),
            info: .color(Color(hex: "#53B1FD")),
            link: .color(Color(hex: "#70E69B")),
            highlight: .color(Color(hex: "#70E69B")),
            premium: .color(Color(hex: "#F79009")),
            destructive: .color(Color(hex: "#FF8A8A")),
            online: .color(Color(hex: "#47CD89")),
            offline: .color(Color(hex: "#85888E")),
            skeleton: .color(Color(hex: "#2F363E"))
        ),
        spacing: LeafLaunchThemeTokens.spacing,
        radius: LeafLaunchThemeTokens.radius,
        fonts: .leafLaunch,
        shadow: LeafLaunchThemeTokens.darkShadow,
        buttonBounceStyle: LeafLaunchThemeTokens.buttonBounceStyle,
        alertStyle: .default
    )

}

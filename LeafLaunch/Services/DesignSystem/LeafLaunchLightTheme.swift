//
//  LeafLaunchLightTheme.swift
//  LeafLaunch
//

import SwiftUI

// Resolved from LeafLaunch-Web/src/app/theme.css, including its final Leaf Launch overrides.
// Rune foreground roles drive brand controls; background.primary is the app canvas.
public extension Theme {

    @MainActor
    static let leafLaunchLight = Theme(
        id: "leafLaunchLight",
        isLightMode: true,
        foreground: .init(
            primary: .color(Color(hex: "#16803C")),
            secondary: .color(Color(hex: "#136E34")),
            tertiary: .color(Color(hex: "#78B58E")),
            quaternary: .color(Color(hex: "#A6CFB5")),
            disabled: .color(Color(hex: "#A4A7AE"))
        ),
        background: .init(
            primary: .color(Color(hex: "#F7FAFB")),
            secondary: .color(Color(hex: "#FFFFFF")),
            tertiary: .color(Color(hex: "#E3EFEA")),
            quaternary: .color(Color(hex: "#D8E9E0")),
            quinary: .color(Color(hex: "#F3F8F7")),
            border: .color(Color(hex: "#CBD3DF"))
        ),
        textColor: .init(
            title: .color(Color(hex: "#111827")),
            titleInverted: .color(Color(hex: "#FFFFFF")),
            body: .color(Color(hex: "#596579")),
            bodyInverted: .color(Color(hex: "#DAEBE0")),
            button: .color(Color(hex: "#FFFFFF")),
            placeholder: .color(Color(hex: "#717680"))
        ),
        palette: .init(
            success: .color(Color(hex: "#079455")),
            warning: .color(Color(hex: "#DC6803")),
            error: .color(Color(hex: "#C62838")),
            info: .color(Color(hex: "#1570EF")),
            link: .color(Color(hex: "#16803C")),
            highlight: .color(Color(hex: "#16803C")),
            premium: .color(Color(hex: "#DC6803")),
            destructive: .color(Color(hex: "#C62838")),
            online: .color(Color(hex: "#079455")),
            offline: .color(Color(hex: "#A4A7AE")),
            skeleton: .color(Color(hex: "#D8E9E0"))
        ),
        spacing: LeafLaunchThemeTokens.spacing,
        radius: LeafLaunchThemeTokens.radius,
        fonts: .leafLaunch,
        shadow: LeafLaunchThemeTokens.lightShadow,
        buttonBounceStyle: LeafLaunchThemeTokens.buttonBounceStyle,
        alertStyle: .default
    )

}
